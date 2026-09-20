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
local operationRequestPending = false
local pendingOperation = nil

local function normalizeId(id)
    if id == nil then
        return nil
    end

    return tostring(id)
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

local function localeText(key, fallback)
    local locale = getLocale()

    if locale[key] ~= nil then
        return tostring(locale[key])
    end

    return fallback or key
end

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
        return localeText(
            'antenna_active',
            'ACTIVE'
        )
    end

    if state == 'maintenance' then
        return localeText(
            'antenna_maintenance_state',
            'MAINTENANCE'
        )
    end

    if state == 'broken' then
        return localeText(
            'antenna_broken_state',
            'BROKEN'
        )
    end

    return localeText(
        'antenna_network_offline',
        'OFFLINE'
    )
end

local function typeLabel(antenna)
    if antenna.type == 'world' then
        return localeText(
            'antenna_world',
            'FIXED'
        )
    end

    return localeText(
        'antenna_player',
        'PERSONAL'
    )
end

local function getAntennaById(id)
    local normalizedId = normalizeId(id)

    if not normalizedId then
        return nil
    end

    return AntennaClient.byId[normalizedId]
end

local function setAntenna(antenna)
    if type(antenna) ~= 'table' or not antenna.id then
        return
    end

    local id = normalizeId(antenna.id)

    antenna.id = id

    AntennaClient.byId[id] = antenna

    for index, current in ipairs(AntennaClient.list) do
        if normalizeId(current.id) == id then
            AntennaClient.list[index] = antenna
            return
        end
    end

    AntennaClient.list[#AntennaClient.list + 1] = antenna
end

local function createBlip(antenna)
    if not Config.Blips.enabled then
        return nil
    end

    if antenna.type == 'world'
        and not Config.Blips.showWorldAntennas then

        return nil
    end

    if antenna.type == 'player'
        and not Config.Blips.showPlayerAntennas then

        return nil
    end

    local blip = AddBlipForCoord(
        antenna.x,
        antenna.y,
        antenna.z
    )

    SetBlipSprite(
        blip,
        Config.Blips.sprite
    )

    SetBlipScale(
        blip,
        Config.Blips.scale
    )

    SetBlipColour(
        blip,
        colorForState(antenna.state)
    )

    SetBlipAsShortRange(
        blip,
        false
    )

    if Config.Blips.showName then
        BeginTextCommandSetBlipName('STRING')

        AddTextComponentString(
            localeText(
                'antenna_blip_name',
                'Radio Antenna'
            ) .. ' - ' .. labelForState(
                antenna.state
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

local function spawnPlayerProp(antenna)
    if antenna.type ~= 'player' then
        return
    end

    local id = normalizeId(antenna.id)

    if AntennaClient.entities[id]
        and DoesEntityExist(
            AntennaClient.entities[id]
        ) then

        return
    end

    local model = joaat(antenna.model)

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
        antenna.x,
        antenna.y,
        antenna.z,
        false,
        false,
        false
    )

    if not DoesEntityExist(object) then
        SetModelAsNoLongerNeeded(model)
        return
    end

    SetEntityHeading(
        object,
        antenna.heading or 0.0
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

    AntennaClient.entities[id] = object

    SetModelAsNoLongerNeeded(model)
end

local function removePlayerProp(id)
    local normalizedId = normalizeId(id)

    if not normalizedId then
        return
    end

    local entity = AntennaClient.entities[
        normalizedId
    ]

    if entity and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end

    AntennaClient.entities[
        normalizedId
    ] = nil
end

local function closeAntennaUI()
    AntennaClient.uiOpen = false
    AntennaClient.selectedId = nil

    interactionActive = false
    operationRequestPending = false
    pendingOperation = nil

    SetNuiFocus(
        false,
        false
    )

    SendNUIMessage({
        action = 'antennaClose'
    })
end

local function openAntennaUI(antenna)
    if type(antenna) ~= 'table'
        or not antenna.id then

        return
    end

    local id = normalizeId(
        antenna.id
    )

    antenna.id = id

    AntennaClient.uiOpen = true
    AntennaClient.selectedId = id

    interactionActive = false
    operationRequestPending = false
    pendingOperation = nil

    AntennaClient.byId[id] = antenna

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

    local antenna = getAntennaById(
        AntennaClient.selectedId
    )

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

local function getClosestAntenna(maxDistance)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local closest = nil
    local closestDistance = nil

    for _, antenna in ipairs(
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

local function requestAntennaTerminal()
    if interactionActive
        or operationRequestPending
        or pendingOperation then

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

local function isPlayerNearAntenna(antenna)
    if not antenna then
        return false
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local antennaCoords = vector3(
        antenna.x,
        antenna.y,
        antenna.z
    )

    local distance = #(
        coords - antennaCoords
    )

    return distance <= (
        Config.Antenna.interactionDistance + 1.5
    )
end

local function startAntennaOperation(
    operation,
    antenna
)
    if interactionActive then
        return
    end

    if type(antenna) ~= 'table'
        or not antenna.id then

        return
    end

    if not isPlayerNearAntenna(antenna) then
        return
    end

    interactionActive = true
    pendingOperation = operation

    if operation == 'remove' then
        TriggerServerEvent(
            'cb_localradio:server:removeAntenna',
            antenna.id
        )

        interactionActive = false
        pendingOperation = nil

        return
    end

    local duration
    local label
    local animation
    local eventName

    if operation == 'repair' then
        duration = Config.Antenna.repair.duration

        label = localeText(
            'antenna_repair_progress',
            'Repairing antenna...'
        )

        animation = Config.Antenna.repair.animation
        eventName = 'cb_localradio:server:repair'

    elseif operation == 'maintenance' then
        duration = Config.Antenna.maintenance.duration

        label = localeText(
            'antenna_maintenance_progress',
            'Performing maintenance...'
        )

        animation = Config.Antenna.maintenance.animation
        eventName = 'cb_localradio:server:maintain'

    else
        interactionActive = false
        pendingOperation = nil
        return
    end

    Bridge.Progress(
        ('cb_localradio_%s'):format(
            operation
        ),
        label,
        duration,
        animation,

        function()
            TriggerServerEvent(
                eventName,
                antenna.id
            )

            interactionActive = false
            pendingOperation = nil
            operationRequestPending = false
        end,

        function()
            interactionActive = false
            pendingOperation = nil
            operationRequestPending = false
        end
    )
end

RegisterNetEvent(
    'cb_localradio:client:openAntennaUI',
    function(data)
        if type(data) ~= 'table'
            or type(data.antenna) ~= 'table' then

            return
        end

        openAntennaUI(
            data.antenna
        )
    end
)

RegisterNetEvent(
    'cb_localradio:client:updateAntennaUI',
    function(antenna)
        if type(antenna) ~= 'table'
            or not antenna.id then

            return
        end

        setAntenna(antenna)

        pendingOperation = nil
        operationRequestPending = false
        interactionActive = false

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
            or type(antenna) ~= 'table'
            or not antenna.id then

            interactionActive = false
            operationRequestPending = false
            pendingOperation = nil

            return
        end

        operationRequestPending = false
        pendingOperation = operation

        local currentAntenna = getAntennaById(
            antenna.id
        )

        if currentAntenna then
            antenna = currentAntenna
        end

        if operation == 'repair' then
            startAntennaOperation(
                'repair',
                antenna
            )

            return
        end

        if operation == 'maintenance' then
            startAntennaOperation(
                'maintenance',
                antenna
            )

            return
        end

        if operation == 'remove' then
            startAntennaOperation(
                'remove',
                antenna
            )

            return
        end

        interactionActive = false
        pendingOperation = nil
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

        if interactionActive
            or operationRequestPending
            or pendingOperation then

            cb({
                ok = false
            })

            return
        end

        local antenna = getAntennaById(id)

        if not antenna then
            cb({
                ok = false
            })

            return
        end

        operationRequestPending = true

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

        if interactionActive
            or operationRequestPending
            or pendingOperation then

            cb({
                ok = false
            })

            return
        end

        local antenna = getAntennaById(id)

        if not antenna then
            cb({
                ok = false
            })

            return
        end

        operationRequestPending = true

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

        if interactionActive
            or operationRequestPending
            or pendingOperation then

            cb({
                ok = false
            })

            return
        end

        local antenna = getAntennaById(id)

        if not antenna then
            cb({
                ok = false
            })

            return
        end

        operationRequestPending = true

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
        list = list or {}

        local incoming = {}

        for _, antenna in ipairs(list) do
            if type(antenna) == 'table'
                and antenna.id then

                local id = normalizeId(
                    antenna.id
                )

                antenna.id = id
                incoming[id] = true
            end
        end

        for id, entity in pairs(
            AntennaClient.entities
        ) do

            if not incoming[id] then
                if DoesEntityExist(entity) then
                    DeleteEntity(entity)
                end

                AntennaClient.entities[id] = nil
            end
        end

        AntennaClient.list = {}
        AntennaClient.byId = {}

        for _, antenna in ipairs(list) do
            if type(antenna) == 'table'
                and antenna.id then

                local id = normalizeId(
                    antenna.id
                )

                antenna.id = id

                AntennaClient.list[
                    #AntennaClient.list + 1
                ] = antenna

                AntennaClient.byId[id] = antenna

                spawnPlayerProp(antenna)
            end
        end

        updateBlips()

        if AntennaClient.uiOpen then
            local selected = getAntennaById(
                AntennaClient.selectedId
            )

            if not selected then
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
        AntennaClient.networks =
            networks or {}
    end
)

local function drawText3D(
    coords,
    text
)
    local onScreen, x, y =
        World3dToScreen2d(
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

local function drawAntennaStatus(
    antenna
)
    local health = math.floor(
        tonumber(
            antenna.health
        ) or 0
    )

    local status = (
        '%s %s | %d%% | %s'
    ):format(
        localeText(
            'antenna_label',
            'ANTENNA'
        ),
        typeLabel(antenna),
        health,
        labelForState(
            antenna.state
        )
    )

    drawText3D(
        vector3(
            antenna.x,
            antenna.y,
            antenna.z + 1.8
        ),
        status
    )
end

local function drawAntennaInteraction(
    antenna
)
    if AntennaClient.uiOpen then
        return
    end

    drawText3D(
        vector3(
            antenna.x,
            antenna.y,
            antenna.z + 1.45
        ),
        localeText(
            'antenna_interact',
            '[E] INTERACT'
        )
    )
end

local function handleAntennaInteraction(
    antenna
)
    if interactionActive
        or operationRequestPending
        or pendingOperation then

        return
    end

    if AntennaClient.uiOpen then
        return
    end

    if not isPlayerNearAntenna(antenna) then
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

            for _, antenna in ipairs(
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

            for _, antenna in ipairs(
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

                if distance <
                    Config.Radius.drawDistance then

                    local color =
                        Config.Radius.color.active

                    if antenna.state ==
                        'maintenance' then

                        color =
                            Config.Radius.color.maintenance

                    elseif antenna.state ==
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

            Wait(0)
        else
            Wait(1000)
        end
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
                getAntennaById(
                    AntennaClient.selectedId
                )

            if not antenna then
                closeAntennaUI()
            else
                local ped = PlayerPedId()
                local coords =
                    GetEntityCoords(ped)

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

        AntennaClient.entities = {}

        for _, blip in pairs(
            AntennaClient.blips or {}
        ) do

            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end

        AntennaClient.blips = {}
    end
)