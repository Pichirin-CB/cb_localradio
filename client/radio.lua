Radio = {
    open = false,
    on = false,
    frequency = 0,
    volume = Config.Radio.defaultVolume,
    hasSignal = false,
    signalNetwork = nil
}

local function pma()
    return GetResourceState('pma-voice') == 'started'
end

local function closeUI()
    Radio.open = false

    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'close'
    })
end

local function openUI()
    Radio.open = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        frequency = Radio.frequency,
        volume = Radio.volume,
        signal = Radio.hasSignal,
        maxFrequency = Config.Radio.maxFrequency
    })
end

local function setPmaChannel(channel)
    if not pma() then
        Bridge.Notify(
            'pma-voice no esta iniciado.',
            'error'
        )

        return false
    end

    exports['pma-voice']:setRadioChannel(channel)

    exports['pma-voice']:setRadioVolume(
        Radio.volume
    )

    return true
end

local function leaveChannel(silent)
    if pma() then
        exports['pma-voice']:setRadioChannel(0)
    end

    Radio.frequency = 0
    Radio.on = false

    SendNUIMessage({
        action = 'state',
        frequency = 0,
        signal = Radio.hasSignal,
        volume = Radio.volume
    })

    if not silent then
        Bridge.Notify(
            Config.Messages.left,
            'info'
        )
    end
end

local function joinChannel(channel)
    channel = tonumber(channel)

    if not channel
        or channel < Config.Radio.minFrequency
        or channel > Config.Radio.maxFrequency then

        Bridge.Notify(
            Config.Messages.invalidFrequency,
            'error'
        )

        return
    end

    if Config.Radio.requireSignal
        and not Radio.hasSignal then

        Bridge.Notify(
            Config.Messages.noSignal,
            'error'
        )

        return
    end

    if Radio.on
        and Radio.frequency == channel then

        Bridge.Notify(
            Config.Messages.alreadyRadio,
            'error'
        )

        return
    end

    if setPmaChannel(channel) then

        Radio.frequency = channel
        Radio.on = true

        SendNUIMessage({
            action = 'state',
            frequency = channel,
            signal = Radio.hasSignal,
            volume = Radio.volume
        })

        Bridge.Notify(
            Config.Messages.joined:format(channel),
            'success'
        )
    end
end

local function updateSignal()
    local coords = GetEntityCoords(
        PlayerPedId()
    )

    local found = false
    local networkId = nil

    for _, network in pairs(
        AntennaClient.networks or {}
    ) do

        for _, coverage in ipairs(
            network.coverage or {}
        ) do

            local d = #(
                coords -
                vector3(
                    coverage.x,
                    coverage.y,
                    coverage.z
                )
            )

            if d <= coverage.radius then
                found = true
                networkId = network.id
                break
            end
        end

        if found then
            break
        end
    end

    local changed =
        found ~= Radio.hasSignal
        or networkId ~= Radio.signalNetwork

    Radio.hasSignal = found
    Radio.signalNetwork = networkId

    if changed then

        SendNUIMessage({
            action = 'signal',
            signal = found,
            frequency = Radio.frequency
        })

    end

    if Radio.on
        and Config.Radio.leaveWhenOutOfCoverage
        and not found then

        leaveChannel(true)

        Bridge.Notify(
            Config.Messages.outOfCoverage,
            'error'
        )
    end
end

RegisterNetEvent(
    'cb_localradio:client:openRadio',
    function()

        if not Bridge.HasItem(
            Config.Items.radio,
            1
        ) then

            Bridge.Notify(
                Config.Messages.noRadio,
                'error'
            )

            return
        end

        if Radio.open then
            closeUI()
        else
            openUI()
        end
    end
)

RegisterCommand(
    Config.Radio.command,
    function()

        if not Config.Radio.enabled then
            return
        end

        if not Bridge.HasItem(
            Config.Items.radio,
            1
        ) then

            Bridge.Notify(
                Config.Messages.noRadio,
                'error'
            )

            return
        end

        if Radio.open then
            closeUI()
        else
            openUI()
        end
    end,
    false
)

RegisterKeyMapping(
    Config.Radio.command,
    'Abrir radio local',
    'keyboard',
    Config.Radio.key
)

-- ============================================================
-- NUI
-- ============================================================

RegisterNUICallback(
    'close',
    function(_, cb)

        closeUI()

        cb('ok')
    end
)

RegisterNUICallback(
    'join',
    function(data, cb)

        joinChannel(
            data.frequency
        )

        cb('ok')
    end
)

RegisterNUICallback(
    'leave',
    function(_, cb)

        leaveChannel(false)

        cb('ok')
    end
)

RegisterNUICallback(
    'volume',
    function(data, cb)

        local volume = math.max(
            0,
            math.min(
                100,
                tonumber(data.volume)
                or Radio.volume
            )
        )

        Radio.volume = volume

        if pma() then

            exports['pma-voice']:setRadioVolume(
                volume
            )

        end

        cb('ok')
    end
)

RegisterNUICallback(
    'frequency',
    function(data, cb)

        joinChannel(
            data.frequency
        )

        cb('ok')
    end
)

RegisterNUICallback(
    'ready',
    function(_, cb)

        cb({
            frequency = Radio.frequency,
            volume = Radio.volume,
            signal = Radio.hasSignal
        })

    end
)

RegisterNetEvent(
    'cb_localradio:client:notify',
    function(message, type)

        Bridge.Notify(
            message,
            type
        )

    end
)

-- ============================================================
-- SIGNAL
-- ============================================================

CreateThread(function()

    Wait(2000)

    TriggerServerEvent(
        'cb_localradio:server:requestSync'
    )

    while true do

        Wait(
            Config.Network.playerCheckSeconds
            * 1000
        )

        updateSignal()
    end
end)

-- ============================================================
-- RADIO STATE CHECK
-- ============================================================

CreateThread(function()

    while true do

        Wait(1000)

        if Radio.on then

            if not Bridge.HasItem(
                Config.Items.radio,
                1
            ) then

                leaveChannel(true)

                if Radio.open then
                    closeUI()
                end
            end

            if IsEntityDead(
                PlayerPedId()
            ) then

                leaveChannel(true)

                if Radio.open then
                    closeUI()
                end
            end
        end

        if Radio.open then

            if not Bridge.HasItem(
                Config.Items.radio,
                1
            ) then

                leaveChannel(true)

                closeUI()
            end

            if IsEntityDead(
                PlayerPedId()
            ) then

                leaveChannel(true)

                closeUI()
            end
        end
    end
end)

-- ============================================================
-- RESOURCE STOP
-- ============================================================

AddEventHandler(
    'onClientResourceStop',
    function(resource)

        if resource ~= GetCurrentResourceName() then
            return
        end

        if pma() then
            exports['pma-voice']:setRadioChannel(0)
        end
    end
)

-- ============================================================
-- EXPORTS
-- ============================================================

exports(
    'IsRadioOn',
    function()
        return Radio.on
    end
)

exports(
    'HasSignal',
    function()
        return Radio.hasSignal
    end
)

exports(
    'GetFrequency',
    function()
        return Radio.frequency
    end
)
