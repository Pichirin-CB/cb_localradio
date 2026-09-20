Radio = {
    open = false,
    on = false,
    frequency = 0,
    volume = Config.Radio.defaultVolume,
    hasSignal = false,
    signalNetwork = nil
}

-- ============================================================
-- PHYSICAL RADIO / ANIMATION SYSTEM
-- ============================================================

local PhysicalRadio = {
    prop = nil,

    state = 'closed',
    talking = false,

    animation = {
        idle = {
            dict = 'cellphone@',
            anim = 'cellphone_text_read_base',
            flag = 49
        },

        talk = {
            dict = 'random@arrests',
            anim = 'generic_radio_chatter',
            flag = 49
        },

        open = {
            dict = 'cellphone@',
            anim = 'cellphone_text_in',
            flag = 49
        },

        close = {
            dict = 'cellphone@',
            anim = 'cellphone_text_out',
            flag = 49
        }
    }
}

local function pma()
    return GetResourceState('pma-voice') == 'started'
end

local function loadAnimDict(dict)
    if not dict then
        return false
    end

    if HasAnimDictLoaded(dict) then
        return true
    end

    RequestAnimDict(dict)

    local timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) do
        Wait(0)

        if GetGameTimer() > timeout then
            return false
        end
    end

    return true
end

local function loadModel(model)
    local hash = joaat(model)

    if HasModelLoaded(hash) then
        return hash
    end

    RequestModel(hash)

    local timeout = GetGameTimer() + 5000

    while not HasModelLoaded(hash) do
        Wait(0)

        if GetGameTimer() > timeout then
            return nil
        end
    end

    return hash
end

local function deleteRadioProp()
    if PhysicalRadio.prop
        and DoesEntityExist(PhysicalRadio.prop) then

        DetachEntity(
            PhysicalRadio.prop,
            true,
            true
        )

        SetEntityAsMissionEntity(
            PhysicalRadio.prop,
            true,
            true
        )

        DeleteEntity(
            PhysicalRadio.prop
        )
    end

    PhysicalRadio.prop = nil
end

local function attachRadioProp(mode)
    if not Config.RadioAnimation.enabled then
        return false
    end

    local ped = PlayerPedId()

    if not DoesEntityExist(ped) then
        return false
    end

    local bone
    local offset
    local rotation

    if mode == 'talk' then

        bone = Config.RadioAnimation.talking.bone

        offset = Config.RadioAnimation.talking.offset

        rotation = Config.RadioAnimation.talking.rotation

    else

        bone = Config.RadioAnimation.idle.bone

        offset = Config.RadioAnimation.idle.offset

        rotation = Config.RadioAnimation.idle.rotation
    end

    if not PhysicalRadio.prop
        or not DoesEntityExist(
            PhysicalRadio.prop
        ) then

        local model = loadModel(
            Config.RadioAnimation.prop
        )

        if not model then
            return false
        end

        PhysicalRadio.prop = CreateObject(
            model,
            0.0,
            0.0,
            0.0,
            true,
            true,
            false
        )

        if not DoesEntityExist(
            PhysicalRadio.prop
        ) then

            PhysicalRadio.prop = nil

            return false
        end

        SetEntityCollision(
            PhysicalRadio.prop,
            false,
            false
        )

        SetEntityCompletelyDisableCollision(
            PhysicalRadio.prop,
            true,
            true
        )

        SetEntityAsMissionEntity(
            PhysicalRadio.prop,
            true,
            true
        )

        SetModelAsNoLongerNeeded(model)
    end

    AttachEntityToEntity(
        PhysicalRadio.prop,
        ped,
        GetPedBoneIndex(
            ped,
            bone
        ),

        offset.x,
        offset.y,
        offset.z,

        rotation.x,
        rotation.y,
        rotation.z,

        false,
        false,
        false,
        false,
        2,
        true
    )

    return true
end

local function stopPhysicalAnimation()
    local ped = PlayerPedId()

    if DoesEntityExist(ped) then

        for _, animation in pairs(
            PhysicalRadio.animation
        ) do

            if animation.dict
                and animation.anim
                and HasAnimDictLoaded(
                    animation.dict
                ) then

                StopAnimTask(
                    ped,
                    animation.dict,
                    animation.anim,
                    -4.0
                )
            end
        end
    end
end

local function playPhysicalAnimation(
    animation,
    restart
)

    local ped = PlayerPedId()

    if not DoesEntityExist(ped) then
        return false
    end

    if not loadAnimDict(
        animation.dict
    ) then

        return false
    end

    if restart
        or not IsEntityPlayingAnim(
            ped,
            animation.dict,
            animation.anim,
            3
        ) then

        TaskPlayAnim(
            ped,
            animation.dict,
            animation.anim,
            8.0,
            -8.0,
            -1,
            animation.flag,
            0.0,
            false,
            false,
            false
        )
    end

    return true
end

local function disablePmaRadioAnimation()
    if not pma() then
        return
    end

    pcall(function()
        exports['pma-voice']:setDisableRadioAnim(true)
    end)
end

local function enablePmaRadioAnimation()
    if not pma() then
        return
    end

    pcall(function()
        exports['pma-voice']:setDisableRadioAnim(false)
    end)
end

local function physicalRadioIdle()
    if not Radio.open then
        return
    end

    PhysicalRadio.talking = false
    PhysicalRadio.state = 'idle'

    stopPhysicalAnimation()

    if attachRadioProp('idle') then
        playPhysicalAnimation(
            PhysicalRadio.animation.idle,
            true
        )
    end
end

local function physicalRadioTalking()
    if not Radio.open then
        return
    end

    if not Config.RadioAnimation.enabled then
        return
    end

    PhysicalRadio.talking = true
    PhysicalRadio.state = 'talking'

    stopPhysicalAnimation()

    if attachRadioProp('talk') then
        playPhysicalAnimation(
            PhysicalRadio.animation.talk,
            true
        )
    end
end

local function openPhysicalRadio()
    if not Config.RadioAnimation.enabled then
        return
    end

    if PhysicalRadio.state ~= 'closed' then
        return
    end

    local ped = PlayerPedId()

    if IsEntityDead(ped) then
        return
    end

    disablePmaRadioAnimation()

    PhysicalRadio.state = 'opening'
    PhysicalRadio.talking = false

    stopPhysicalAnimation()

    attachRadioProp('idle')

    playPhysicalAnimation(
        PhysicalRadio.animation.open,
        true
    )

    CreateThread(function()

        Wait(
            Config.RadioAnimation.openDuration
        )

        if not Radio.open then
            return
        end

        if PhysicalRadio.talking then
            physicalRadioTalking()
        else
            physicalRadioIdle()
        end
    end)
end

local function closePhysicalRadio()
    if PhysicalRadio.state == 'closed' then
        return
    end

    local ped = PlayerPedId()

    PhysicalRadio.talking = false

    if DoesEntityExist(ped)
        and not IsEntityDead(ped)
        and Config.RadioAnimation.enabled then

        PhysicalRadio.state = 'closing'

        stopPhysicalAnimation()

        playPhysicalAnimation(
            PhysicalRadio.animation.close,
            true
        )

        CreateThread(function()

            Wait(
                Config.RadioAnimation.closeDuration
            )

            stopPhysicalAnimation()
            deleteRadioProp()

            PhysicalRadio.state = 'closed'

            enablePmaRadioAnimation()
        end)

    else

        stopPhysicalAnimation()
        deleteRadioProp()

        PhysicalRadio.state = 'closed'

        enablePmaRadioAnimation()
    end
end

-- ============================================================
-- PMA-VOICE RADIO TALK STATE
-- ============================================================

RegisterNetEvent(
    'pma-voice:radioActive',
    function(active)

        PhysicalRadio.talking = active == true

        if not Radio.open then
            return
        end

        if PhysicalRadio.state == 'closing'
            or PhysicalRadio.state == 'closed' then

            return
        end

        if PhysicalRadio.talking then
            physicalRadioTalking()
        else
            physicalRadioIdle()
        end
    end
)

-- ============================================================
-- UI
-- ============================================================

local function closeUI()
    Radio.open = false

    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'close'
    })

    closePhysicalRadio()
end

local function openUI()
    Radio.open = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',

        frequency = Radio.frequency,
        volume = Radio.volume,

        signal = Radio.hasSignal,
        on = Radio.on,

        maxFrequency = Config.Radio.maxFrequency,

        locale = RadioUtils.getLocale(),
        translations = RadioUtils.localeTable()
    })

    openPhysicalRadio()
end

-- ============================================================
-- PMA CHANNEL
-- ============================================================

local function setPmaChannel(channel)

    if not pma() then

        Bridge.Notify(
            RadioUtils.locale(
                'pma_not_started'
            ),
            'error'
        )

        return false
    end

    exports['pma-voice']:setRadioChannel(
        channel
    )

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
        on = false,

        volume = Radio.volume
    })

    if not silent then

        Bridge.Notify(
            RadioUtils.locale('left'),
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
            RadioUtils.locale(
                'invalid_frequency'
            ),
            'error'
        )

        return
    end

    if Config.Radio.requireSignal
        and not Radio.hasSignal then

        Bridge.Notify(
            RadioUtils.locale(
                'no_radio_signal'
            ),
            'error'
        )

        return
    end

    if Radio.on
        and Radio.frequency == channel then

        Bridge.Notify(
            RadioUtils.locale(
                'already_radio'
            ),
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
            on = true,

            volume = Radio.volume
        })

        Bridge.Notify(
            RadioUtils.locale(
                'joined',
                channel
            ),
            'success'
        )
    end
end

-- ============================================================
-- SIGNAL
-- ============================================================

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
            on = Radio.on,

            frequency = Radio.frequency
        })
    end

    if Radio.on
        and Config.Radio.leaveWhenOutOfCoverage
        and not found then

        leaveChannel(true)

        Bridge.Notify(
            RadioUtils.locale(
                'out_of_coverage'
            ),
            'error'
        )
    end
end

-- ============================================================
-- OPEN RADIO EVENT
-- ============================================================

RegisterNetEvent(
    'cb_localradio:client:openRadio',
    function()

        if not Bridge.HasItem(
            Config.Items.radio,
            1
        ) then

            Bridge.Notify(
                RadioUtils.locale(
                    'no_radio'
                ),
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

-- ============================================================
-- COMMAND
-- ============================================================

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
                RadioUtils.locale(
                    'no_radio'
                ),
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
    RadioUtils.locale(
        'radio_open'
    ),
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

            signal = Radio.hasSignal,
            on = Radio.on,

            locale = RadioUtils.getLocale(),
            translations = RadioUtils.localeTable()
        })
    end
)

-- ============================================================
-- SERVER NOTIFICATIONS
-- ============================================================

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
-- SIGNAL THREAD
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

        local ped = PlayerPedId()

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

            if IsEntityDead(ped) then

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

            if IsEntityDead(ped) then

                leaveChannel(true)

                closeUI()
            end
        end
    end
end)

-- ============================================================
-- PHYSICAL RADIO SAFETY
-- ============================================================

CreateThread(function()

    while true do

        Wait(250)

        if not Radio.open then
            goto continue
        end

        local ped = PlayerPedId()

        if IsEntityDead(ped) then

            if PhysicalRadio.state ~= 'closed' then

                stopPhysicalAnimation()
                deleteRadioProp()

                PhysicalRadio.state = 'closed'
                PhysicalRadio.talking = false

                enablePmaRadioAnimation()
            end

            goto continue
        end

        if PhysicalRadio.state == 'idle' then

            if not IsEntityPlayingAnim(
                ped,
                PhysicalRadio.animation.idle.dict,
                PhysicalRadio.animation.idle.anim,
                3
            ) then

                physicalRadioIdle()
            end

        elseif PhysicalRadio.state == 'talking' then

            if not IsEntityPlayingAnim(
                ped,
                PhysicalRadio.animation.talk.dict,
                PhysicalRadio.animation.talk.anim,
                3
            ) then

                physicalRadioTalking()
            end
        end

        ::continue::
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

        stopPhysicalAnimation()
        deleteRadioProp()

        PhysicalRadio.state = 'closed'
        PhysicalRadio.talking = false

        if pma() then

            pcall(function()
                exports['pma-voice']:setDisableRadioAnim(false)
            end)

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