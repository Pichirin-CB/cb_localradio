AntennaClient = {
    list = {},
    byId = {},
    entities = {},
    blips = {},
    networks = {}
}

local function colorForState(state)
    if state == 'active' then return Config.Blips.colors.active end
    if state == 'maintenance' then return Config.Blips.colors.maintenance end
    if state == 'broken' then return Config.Blips.colors.broken end
    return Config.Blips.colors.offline
end

local function labelForState(state)
    if state == 'active' then return 'ACTIVA' end
    if state == 'maintenance' then return 'MANTENIMIENTO' end
    if state == 'broken' then return 'ROTA' end
    return 'FUERA DE SERVICIO'
end

local function createBlip(a)
    if not Config.Blips.enabled then return end
    if a.type == 'world' and not Config.Blips.showWorldAntennas then return end
    if a.type == 'player' and not Config.Blips.showPlayerAntennas then return end

    local blip = AddBlipForCoord(a.x, a.y, a.z)
    SetBlipSprite(blip, Config.Blips.sprite)
    SetBlipScale(blip, Config.Blips.scale)
    SetBlipColour(blip, colorForState(a.state))
    SetBlipAsShortRange(false)

    if Config.Blips.showName then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(('Antena de radio - %s'):format(labelForState(a.state)))
        EndTextCommandSetBlipName(blip)
    end

    return blip
end

local function updateBlips()
    for _, b in pairs(AntennaClient.blips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    AntennaClient.blips = {}

    for id, a in pairs(AntennaClient.byId) do
        local b = createBlip(a)
        if b then AntennaClient.blips[id] = b end
    end
end

local function spawnPlayerProp(a)
    if a.type ~= 'player' then return end
    if AntennaClient.entities[a.id] and DoesEntityExist(AntennaClient.entities[a.id]) then return end

    local model = joaat(a.model)
    RequestModel(model)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(model) then return end

    local object = CreateObject(model, a.x, a.y, a.z, false, false, false)
    SetEntityHeading(object, a.heading or 0.0)
    FreezeEntityPosition(object, true)
    SetEntityInvincible(object, true)
    SetEntityAsMissionEntity(object, true, true)

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

RegisterNetEvent('cb_localradio:client:syncAntennas', function(list)
    for id, entity in pairs(AntennaClient.entities) do
        local stillExists = false
        for _, a in ipairs(list or {}) do
            if a.id == id then
                stillExists = true
                break
            end
        end
        if not stillExists then removePlayerProp(id) end
    end

    AntennaClient.list = list or {}
    AntennaClient.byId = {}

    for _, a in ipairs(AntennaClient.list) do
        AntennaClient.byId[a.id] = a
        spawnPlayerProp(a)
    end

    updateBlips()
end)

RegisterNetEvent('cb_localradio:client:syncNetworks', function(networks)
    AntennaClient.networks = networks or {}
end)

local function drawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 230)
    SetTextCentre(true)
    SetTextOutline()

    BeginTextCommandDisplayText('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayText(x, y)
end

local function openAntennaActions(a)
    local canRemove = a.type == 'player'
    local text = ('[E] Reparar  [G] Mantenimiento%s'):format(canRemove and '  [H] Retirar' or '')

    CreateThread(function()
        local start = GetGameTimer()

        while GetGameTimer() - start < 8000 do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local d = #(coords - vector3(a.x, a.y, a.z))

            if d > Config.Antenna.interactionDistance + 1.5 then return end

            drawText3D(vector3(a.x, a.y, a.z + 1.5), text)

            if IsControlJustReleased(0, 38) then
                if a.state == 'broken' then
                    Bridge.Progress(
                        'cb_localradio_repair',
                        'Reparando antena...',
                        Config.Antenna.repair.duration,
                        Config.Antenna.repair.animation,
                        function()
                            TriggerServerEvent('cb_localradio:server:repair', a.id)
                        end
                    )
                    return
                else
                    Bridge.Progress(
                        'cb_localradio_repair',
                        'Reparando antena...',
                        Config.Antenna.repair.duration,
                        Config.Antenna.repair.animation,
                        function()
                            TriggerServerEvent('cb_localradio:server:repair', a.id)
                        end
                    )
                    return
                end
            end

            if IsControlJustReleased(0, 47) then
                Bridge.Progress(
                    'cb_localradio_maintenance',
                    'Realizando mantenimiento...',
                    Config.Antenna.maintenance.duration,
                    Config.Antenna.maintenance.animation,
                    function()
                        TriggerServerEvent('cb_localradio:server:maintain', a.id)
                    end
                )
                return
            end

            if canRemove and IsControlJustReleased(0, 74) then
                TriggerServerEvent('cb_localradio:server:removeAntenna', a.id)
                return
            end

            Wait(0)
        end
    end)
end

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, a in pairs(AntennaClient.list) do
            local d = #(coords - vector3(a.x, a.y, a.z))

            if d < Config.Antenna.interactionDistance + 1.5 then
                wait = 0

                local status = ('ANTENA %s | %d%% | %s'):format(
                    a.type == 'world' and 'FIJA' or 'PROPIA',
                    math.floor(a.health),
                    labelForState(a.state)
                )

                drawText3D(vector3(a.x, a.y, a.z + 1.8), status)

                if not IsPauseMenuActive() then
                    if not IsEntityDead(ped) and not IsPedInAnyVehicle(ped, false) then
                        if IsControlJustReleased(0, 38) then
                            openAntennaActions(a)
                        end
                    end
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

            for _, a in pairs(AntennaClient.list) do
                local d = #(coords - vector3(a.x, a.y, a.z))
                if d < Config.Radius.drawDistance then
                    local c = Config.Radius.color.active
                    if a.state == 'maintenance' then c = Config.Radius.color.maintenance end
                    if a.state == 'broken' then c = Config.Radius.color.broken end

                    DrawMarker(
                        1,
                        a.x, a.y, a.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        a.radius * 2.0, a.radius * 2.0, 0.5,
                        c.r, c.g, c.b, c.a,
                        false, false, 2, false, nil, nil, false
                    )
                end
            end
        end

        Wait(Config.Radius.enabled and 0 or 1000)
    end
end)
