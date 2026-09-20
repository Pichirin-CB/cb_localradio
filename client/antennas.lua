AntennaClient = {
    list = {},
    byId = {},
    entities = {},
    blips = {},
    networks = {},
    uiOpen = false,
    selectedId = nil
}

local interactionActive = false

local function colorForState(state)
    if state == 'active' then
        return Config.Blips.colors.active
    end

    if state == 'maintenance' then
        return Config.Blips.colors.maintenance
    end

    if state == 'broken' then
        return Config.Blips.colors.broken
    end

    return Config.Blips.colors.offline
end

local function labelForState(state)
    if state == 'active' then
        return 'ACTIVA'
    end

    if state == 'maintenance' then
        return 'MANTENIMIENTO'
    end

    if state == 'broken' then
        return 'ROTA'
    end

    return 'FUERA DE SERVICIO'
end

local function typeLabel(a)
    if a.type == 'world' then
        return 'FIJA'
    end

    return 'PROPIA'
end

local function createBlip(a)
    if not Config.Blips.enabled then
        return
    end

    if a.type == 'world' and not Config.Blips.showWorldAntennas then
        return
    end

    if a.type == 'player' and not Config.Blips.showPlayerAntennas then
        return
    end

    local blip = AddBlipForCoord(a.x, a.y, a.z)

    SetBlipSprite(blip, Config.Blips.sprite)
    SetBlipScale(blip, Config.Blips.scale)
    SetBlipColour(blip, colorForState(a.state))
    SetBlipAsShortRange(false)

    if Config.Blips.showName then
        BeginTextCommandSetBlipName('STRING')

        AddTextComponentString(
            ('Antena de radio - %s'):format(
                labelForState(a.state)
            )
        )

        EndTextCommandSetBlipName(blip)
    end

    return blip
end

local function updateBlips()
    for _, blip in pairs(AntennaClient.blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end

    AntennaClient.blips = {}

    for id, antenna in pairs(AntennaClient.byId) do
        local blip = createBlip(antenna)

        if blip then
            AntennaClient.blips[id] = blip
        end
    end
end

local function spawnPlayerProp(a)
    if a.type ~= 'player' then
        return
    end

    if AntennaClient.entities[a.id]
        and DoesEntityExist(AntennaClient.entities[a.id]) then

        return
    end

    local model = joaat(a.model)

    RequestModel(model)

    local timeout = GetGameTimer() + 5000

    while not HasModelLoaded(model)
        and GetGameTimer() < timeout do

        Wait(0)
    end

    if not HasModelLoaded(model) then
        return
    end

    local object = CreateObject(
        model,
        a.x,
        a.y,
        a.z,
        false,
        false,
        false
    )

    SetEntityHeading(
        object,
        a.heading or 0.0
    )

    FreezeEntityPosition(
        object,
        true
    )

    SetEntityInvincible(
        object,
        true
    )

    SetEntityAsMissionEntity(
        object,
        true,
        true
    )

    AntennaClient.entities[a.id] = object

    SetModelAsNoLongerNeeded(model)
end

local function removePlayerProp(id)
    local entity = AntennaClient.entities[id]

    if entity and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end

    AntennaClient.entities[id] = nil
end

local function getLocale()
    local locale = Config.Locales
        and Config.Locales[Config.Locale]

    if locale then
        return locale
    end

    return Config.Locales
        and Config.Locales.en
        or {}
end

local function getClosestAntenna(maxDistance)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local closest = nil
    local closestDistance = nil

    for _, antenna in pairs(AntennaClient.list) do
        local antennaCoords = vector3(
            antenna.x,
            antenna.y,
            antenna.z
        )

        local distance = #(
            coords - antennaCoords
        )

        if distance <= maxDistance then
            if not closestDistance
                or distance < closestDistance then

                closest = antenna
                closestDistance = distance
            end
        end
    end

    return closest, closestDistance
end

local function closeAntennaUI()
    if not AntennaClient.uiOpen then
        return
    end

    AntennaClient.uiOpen = false
    AntennaClient.selectedId = nil

    SetNuiFocus(
        false,
        false
    )

    SendNUIMessage({
        action = 'antennaClose'
    })
end

local function openAntennaUI(antenna)
    if not antenna then
        return
    end

    if AntennaClient.uiOpen then
        return
    end

    AntennaClient.uiOpen = true
    AntennaClient.selectedId = antenna.id

    SetNuiFocus(
        true,
        true
    )

    SendNUIMessage({
        action = 'antennaOpen',

        antenna = antenna,

        locale = Config.Locale,

        translations = getLocale()
    })
end

local function refreshAntennaUI()
    if not AntennaClient.uiOpen
        or not AntennaClient.selectedId then

        return
    end

    local antenna = AntennaClient.byId[
        AntennaClient.selectedId
    ]

    if not antenna then
        closeAntennaUI()
        return
    end

    SendNUIMessage({
        action = 'antennaUpdate',

        antenna = antenna,

        translations = getLocale()
    })
end

local function requestAntennaTerminal()
    if interactionActive then
        return
    end

    if AntennaClient.uiOpen then
        return
    end

    local antenna = getClosestAntenna(
        Config.Antenna.interactionDistance + 1.5
    )

    if not antenna then
        return
    end

    TriggerServerEvent(
        'cb_localradio:server:openAntenna',
        antenna.id
    )
end

RegisterNetEvent(
    'cb_localradio:client:openAntennaUI',
    function(data)
        if type(data) ~= 'table'
            or not data.antenna then

            return
        end

        local antenna = data.antenna

        AntennaClient.byId[antenna.id] = antenna

        openAntennaUI(antenna)
    end
)

RegisterNetEvent(
    'cb_localradio:client:updateAntennaUI',
    function(antenna)
        if type(antenna) ~= 'table'
            or not antenna.id then

            return
        end

        AntennaClient.byId[antenna.id] = antenna

        for index, current in ipairs(
            AntennaClient.list
        ) do

            if current.id == antenna.id then
                AntennaClient.list[index] = antenna
                break
            end
        end

        refreshAntennaUI()
        updateBlips()
    end
)

RegisterNetEvent(
    'cb_localradio:client:closeAntennaUI',
    function()
        closeAntennaUI()
    end
)

RegisterNetEvent(
    'cb_localradio:client:antennaOperation',
    function(operation, antenna)
        if type(operation) ~= 'string'
            or type(antenna) ~= 'table' then

            return
        end

        if operation == 'repair' then
            if interactionActive then
                return
            end

            interactionActive = true

            Bridge.Progress(
                'cb_localradio_repair',
                'Reparando antena...',
                Config.Antenna.repair.duration,
                Config.Antenna.repair.animation,

                function()
                    TriggerServerEvent(
                        'cb_localradio:server:repair',
                        antenna.id
                    )

                    interactionActive = false
                end,

                function()
                    interactionActive = false
                end
            )

            return
        end

        if operation == 'maintenance' then
            if interactionActive then
                return
            end

            interactionActive = true

            Bridge.Progress(
                'cb_localradio_maintenance',
                'Realizando mantenimiento...',
                Config.Antenna.maintenance.duration,
                Config.Antenna.maintenance.animation,

                function()
                    TriggerServerEvent(
                        'cb_localradio:server:maintain',
                        antenna.id
                    )

                    interactionActive = false
                end,

                function()
                    interactionActive = false
                end
            )

            return
        end

        if operation == 'remove' then
            if interactionActive then
                return
            end

            TriggerServerEvent(
                'cb_localradio:server:removeAntenna',
                antenna.id
            )

            return
        end
    end
)

RegisterNUICallback(
    'antennaClose',
    function(_, cb)
        closeAntennaUI()

        cb({
            ok = true
        })
    end
)

RegisterNUICallback(
    'antennaRepair',
    function(data, cb)
        local id = data
            and data.id

        if not id then
            cb({
                ok = false
            })

            return
        end

        local antenna = AntennaClient.byId[
            tostring(id)
        ]

        if not antenna then
            cb({
                ok = false
            })

            return
        end

        TriggerServerEvent(
            'cb_localradio:server:requestAntennaOperation',
            'repair',
            antenna.id
        )

        cb({
            ok = true
        })
    end
)

RegisterNUICallback(
    'antennaMaintenance',
    function(data, cb)
        local id = data
            and data.id

        if not id then
            cb({
                ok = false
            })

            return
        end

        local antenna = AntennaClient.byId[
            tostring(id)
        ]

        if not antenna then
            cb({
                ok = false
            })

            return
        end

        TriggerServerEvent(
            'cb_localradio:server:requestAntennaOperation',
            'maintenance',
            antenna.id
        )

        cb({
            ok = true
        })
    end
)

RegisterNUICallback(
    'antennaRemove',
    function(data, cb)
        local id = data
            and data.id

        if not id then
            cb({
                ok = false
            })

            return
        end

        local antenna = AntennaClient.byId[
            tostring(id)
        ]

        if not antenna then
            cb({
                ok = false
            })

            return
        end

        TriggerServerEvent(
            'cb_localradio:server:requestAntennaOperation',
            'remove',
            antenna.id
        )

        cb({
            ok = true
        })
    end
)

RegisterNUICallback(
    'antennaRefresh',
    function(data, cb)
        local id = data
            and data.id

        if not id then
            cb({
                ok = false
            })

            return
        end

        TriggerServerEvent(
            'cb_localradio:server:openAntenna',
            id
        )

        cb({
            ok = true
        })
    end
)

RegisterNUICallback(
    'antennaReady',
    function(_, cb)
        cb({
            ok = true
        })
    end
)

RegisterNetEvent(
    'cb_localradio:client:syncAntennas',
    function(list)
        for id, entity in pairs(
            AntennaClient.entities
        ) do

            local stillExists = false

            for _, antenna in ipairs(list or {}) do
                if antenna.id == id then
                    stillExists = true
                    break
                end
            end

            if not stillExists then
                removePlayerProp(id)
            end
        end

        AntennaClient.list = list or {}
        AntennaClient.byId = {}

        for _, antenna in ipairs(
            AntennaClient.list
        ) do

            AntennaClient.byId[
                antenna.id
            ] = antenna

            spawnPlayerProp(antenna)
        end

        updateBlips()

        if AntennaClient.uiOpen then
            if AntennaClient.selectedId
                and not AntennaClient.byId[
                    AntennaClient.selectedId
                ] then

                closeAntennaUI()
            else
                refreshAntennaUI()
            end
        end
    end
)

RegisterNetEvent(
    'cb_localradio:client:syncNetworks',
    function(networks)
        AntennaClient.networks = networks or {}
    end
)

local function drawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(
        coords.x,
        coords.y,
        coords.z
    )

    if not onScreen then
        return
    end

    SetTextScale(
        0.30,
        0.30
    )

    SetTextFont(4)
    SetTextProportional(1)

    SetTextColour(
        255,
        255,
        255,
        230
    )

    SetTextCentre(true)
    SetTextOutline()

    BeginTextCommandDisplayText(
        'STRING'
    )

    AddTextComponentString(text)

    EndTextCommandDisplayText(
        x,
        y
    )
end

local function drawAntennaStatus(a)
    local status = ('ANTENA %s | %d%% | %s'):format(
        typeLabel(a),
        math.floor(
            tonumber(a.health) or 0
        ),
        labelForState(a.state)
    )

    drawText3D(
        vector3(
            a.x,
            a.y,
            a.z + 1.8
        ),
        status
    )
end

local function drawAntennaInteraction(a)
    if AntennaClient.uiOpen then
        return
    end

    drawText3D(
        vector3(
            a.x,
            a.y,
            a.z + 1.45
        ),
        '[E] INTERACTUAR'
    )
end

local function isPlayerNearAntenna(a)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local distance = #(
        coords - vector3(
            a.x,
            a.y,
            a.z
        )
    )

    return distance <= (
        Config.Antenna.interactionDistance + 1.5
    )
end

local function handleAntennaInteraction(a)
    if interactionActive then
        return
    end

    if AntennaClient.uiOpen then
        return
    end

    if not isPlayerNearAntenna(a) then
        return
    end

    if IsControlJustReleased(
        0,
        38
    ) then

        requestAntennaTerminal()
    end
end

CreateThread(function()
    while true do
        local wait = 1000

        local ped = PlayerPedId()

        if not IsEntityDead(ped)
            and not IsPedInAnyVehicle(
                ped,
                false
            )
            and not IsPauseMenuActive()
            and not AntennaClient.uiOpen then

            local coords = GetEntityCoords(ped)

            for _, antenna in pairs(
                AntennaClient.list
            ) do

                local antennaCoords = vector3(
                    antenna.x,
                    antenna.y,
                    antenna.z
                )

                local distance = #(
                    coords - antennaCoords
                )

                if distance <= (
                    Config.Antenna.interactionDistance
                    + 1.5
                ) then

                    wait = 0

                    drawAntennaStatus(
                        antenna
                    )

                    drawAntennaInteraction(
                        antenna
                    )

                    handleAntennaInteraction(
                        antenna
                    )
                end
            end
        end

        Wait(wait)
    end
end)

CreateThread(function()
    while true do
        if Config.Radius.enabled then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            for _, antenna in pairs(
                AntennaClient.list
            ) do

                local antennaCoords = vector3(
                    antenna.x,
                    antenna.y,
                    antenna.z
                )

                local distance = #(
                    coords - antennaCoords
                )

                if distance < Config.Radius.drawDistance then
                    local color =
                        Config.Radius.color.active

                    if antenna.state ==
                        'maintenance' then

                        color =
                            Config.Radius.color.maintenance
                    end

                    if antenna.state ==
                        'broken' then

                        color =
                            Config.Radius.color.broken
                    end

                    DrawMarker(
                        1,

                        antenna.x,
                        antenna.y,
                        antenna.z - 1.0,

                        0.0,
                        0.0,
                        0.0,

                        0.0,
                        0.0,
                        0.0,

                        antenna.radius * 2.0,
                        antenna.radius * 2.0,
                        0.5,

                        color.r,
                        color.g,
                        color.b,
                        color.a,

                        false,
                        false,
                        2,
                        false,
                        nil,
                        nil,
                        false
                    )
                end
            end
        end

        Wait(
            Config.Radius.enabled
            and 0
            or 1000
        )
    end
end)

RegisterNetEvent(
    'cb_localradio:client:antennaInteraction',
    function()
        requestAntennaTerminal()
    end
)

CreateThread(function()
    while true do
        if AntennaClient.uiOpen then
            local antenna =
                AntennaClient.byId[
                    AntennaClient.selectedId
                ]

            if not antenna then
                closeAntennaUI()
            else
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)

                local distance = #(
                    coords - vector3(
                        antenna.x,
                        antenna.y,
                        antenna.z
                    )
                )

                if distance > (
                    Config.Antenna.interactionDistance
                    + 2.0
                ) then

                    closeAntennaUI()
                end
            end

            Wait(500)
        else
            Wait(1000)
        end
    end
end)

AddEventHandler(
    'onClientResourceStop',
    function(resource)
        if resource ~= GetCurrentResourceName() then
            return
        end

        closeAntennaUI()

        for _, entity in pairs(
            AntennaClient.entities or {}
        ) do

            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end

        for _, blip in pairs(
            AntennaClient.blips or {}
        ) do

            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
)