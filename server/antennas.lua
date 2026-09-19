RadioAntennas = {}
RadioNetworks = {}

local function newId()
    return ('ant_%s_%s'):format(os.time(), math.random(100000, 999999))
end

local function stateForHealth(health)
    if health <= Config.Antenna.brokenAt then
        return 'broken'
    elseif health < Config.Antenna.maintenanceAt then
        return 'maintenance'
    end
    return 'active'
end

local function serialize(a)
    return {
        id = a.id,
        type = a.type,
        owner = a.owner,
        model = a.model,
        x = a.x,
        y = a.y,
        z = a.z,
        heading = a.heading,
        radius = a.radius,
        health = a.health,
        state = a.state
    }
end

local function loadWorld()
    for _, w in ipairs(Config.WorldAntennas) do
        local existing = MySQL.single.await(
            'SELECT id, health, state FROM cb_localradio_antennas WHERE id = ?',
            { w.id }
        )

        if not existing then
            MySQL.insert.await([[
                INSERT INTO cb_localradio_antennas
                (id, type, owner, model, x, y, z, heading, radius, health, state, last_maintenance, last_degradation)
                VALUES (?, 'world', NULL, ?, ?, ?, ?, ?, ?, 0, 'broken', NOW(), NOW())
            ]], {
                w.id, w.model, w.coords.x, w.coords.y, w.coords.z, w.heading or 0, w.radius
            })
        end
    end
end

local function loadDatabase()
    RadioAntennas = {}

    local rows = MySQL.query.await('SELECT * FROM cb_localradio_antennas')
    for _, row in ipairs(rows or {}) do
        RadioAntennas[row.id] = {
            id = row.id,
            type = row.type,
            owner = row.owner,
            model = row.model,
            x = row.x,
            y = row.y,
            z = row.z,
            heading = row.heading,
            radius = row.radius,
            health = row.health,
            state = row.state
        }
    end
end

local function saveAntenna(a)
    MySQL.update.await([[
        UPDATE cb_localradio_antennas
        SET health = ?, state = ?, last_maintenance = NOW(), last_degradation = NOW()
        WHERE id = ?
    ]], { a.health, a.state, a.id })
end

local function broadcast()
    local list = {}
    for _, antenna in pairs(RadioAntennas) do
        list[#list + 1] = serialize(antenna)
    end

    TriggerClientEvent('cb_localradio:client:syncAntennas', -1, list)
end

local function rebuildNetworks()
    RadioNetworks = {}

    local active = {}
    for _, a in pairs(RadioAntennas) do
        if a.state == 'active' or a.state == 'maintenance' then
            active[#active + 1] = a
        end
    end

    local visited = {}
    local networkIndex = 0

    for _, start in ipairs(active) do
        if not visited[start.id] then
            networkIndex = networkIndex + 1
            local queue = { start }
            local component = {}
            visited[start.id] = true

            while #queue > 0 do
                local current = table.remove(queue, 1)
                component[#component + 1] = current.id

                for _, other in ipairs(active) do
                    if not visited[other.id] and RadioUtils.distance(current, other) <= Config.Network.linkDistance then
                        visited[other.id] = true
                        queue[#queue + 1] = other
                    end
                end
            end

            RadioNetworks[networkIndex] = component
        end
    end
end

local function buildNetworkPayload()
    local payload = {}

    for networkId, ids in pairs(RadioNetworks) do
        local network = {
            id = networkId,
            antennas = ids,
            coverage = {}
        }

        for _, id in ipairs(ids) do
            local a = RadioAntennas[id]
            if a then
                network.coverage[#network.coverage + 1] = {
                    x = a.x,
                    y = a.y,
                    z = a.z,
                    radius = a.radius
                }
            end
        end

        payload[#payload + 1] = network
    end

    return payload
end

RegisterNetEvent('cb_localradio:server:requestSync', function()
    local src = source
    local list = {}
    for _, antenna in pairs(RadioAntennas) do
        list[#list + 1] = serialize(antenna)
    end
    TriggerClientEvent('cb_localradio:client:syncAntennas', src, list)
    TriggerClientEvent('cb_localradio:client:syncNetworks', src, buildNetworkPayload())
end)

RegisterNetEvent('cb_localradio:server:placeAntenna', function(data)
    local src = source

    if type(data) ~= 'table' or not data.coords then return end
    if not ServerBridge.ready() then return end

    local coords = data.coords
    local heading = tonumber(data.heading) or 0

    if not ServerBridge.hasItem(src, Config.Items.antennaKit, 1) then
        ServerBridge.notify(src, Config.Messages.noItems, 'error')
        return
    end

    for _, a in pairs(RadioAntennas) do
        if RadioUtils.distance(coords, a) < Config.Antenna.minimumDistance then
            ServerBridge.notify(src, Config.Messages.tooClose, 'error')
            return
        end
    end

    local id = newId()
    local owner = ServerBridge.identifier(src)

    if not ServerBridge.removeItem(src, Config.Items.antennaKit, 1) then
        ServerBridge.notify(src, Config.Messages.noItems, 'error')
        return
    end

    local antenna = {
        id = id,
        type = 'player',
        owner = owner,
        model = Config.Antenna.playerModel,
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading,
        radius = Config.Antenna.defaultRadius,
        health = 100.0,
        state = 'active'
    }

    RadioAntennas[id] = antenna

    MySQL.insert.await([[
        INSERT INTO cb_localradio_antennas
        (id, type, owner, model, x, y, z, heading, radius, health, state, last_maintenance, last_degradation)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
    ]], {
        id, antenna.type, antenna.owner, antenna.model,
        antenna.x, antenna.y, antenna.z, antenna.heading,
        antenna.radius, antenna.health, antenna.state
    })

    rebuildNetworks()
    broadcast()
    TriggerClientEvent('cb_localradio:client:syncNetworks', -1, buildNetworkPayload())
    ServerBridge.notify(src, Config.Messages.antennaPlaced, 'success')
end)

local function getAntenna(id)
    return RadioAntennas[tostring(id)]
end

RegisterNetEvent('cb_localradio:server:repair', function(id)
    local src = source
    local antenna = getAntenna(id)
    if not antenna then return end

    if antenna.type == 'world' or antenna.type == 'player' then
        local ped = GetPlayerPed(src)
        if ped <= 0 then return end

        local p = GetEntityCoords(ped)
        if RadioUtils.distance({x = p.x, y = p.y, z = p.z}, antenna) > Config.Antenna.interactionDistance + 1.5 then
            ServerBridge.notify(src, Config.Messages.tooFar, 'error')
            return
        end

        if antenna.state == 'broken' then
            if not ServerBridge.hasItem(src, Config.Items.repairKit, 1) then
                ServerBridge.notify(src, Config.Messages.noItems, 'error')
                return
            end

            if not ServerBridge.removeItem(src, Config.Items.repairKit, 1) then return end
            antenna.health = math.min(100.0, antenna.health + Config.Antenna.repair.health)
        else
            if not ServerBridge.hasItem(src, Config.Items.maintenanceKit, 1) then
                ServerBridge.notify(src, Config.Messages.noItems, 'error')
                return
            end

            if not ServerBridge.removeItem(src, Config.Items.maintenanceKit, 1) then return end
            antenna.health = math.min(100.0, antenna.health + Config.Antenna.maintenance.health)
        end

        antenna.state = stateForHealth(antenna.health)
        saveAntenna(antenna)
        rebuildNetworks()
        broadcast()
        TriggerClientEvent('cb_localradio:client:syncNetworks', -1, buildNetworkPayload())
    end
end)

RegisterNetEvent('cb_localradio:server:maintain', function(id)
    local src = source
    local antenna = getAntenna(id)
    if not antenna then return end

    local ped = GetPlayerPed(src)
    local p = GetEntityCoords(ped)
    if RadioUtils.distance({x = p.x, y = p.y, z = p.z}, antenna) > Config.Antenna.interactionDistance + 1.5 then
        ServerBridge.notify(src, Config.Messages.tooFar, 'error')
        return
    end

    if antenna.health >= Config.Antenna.degradation.minimumHealthBeforeMaintenance then
        ServerBridge.notify(src, 'La antena no necesita mantenimiento todavia.', 'info')
        return
    end

    if not ServerBridge.hasItem(src, Config.Items.maintenanceKit, 1) then
        ServerBridge.notify(src, Config.Messages.noItems, 'error')
        return
    end

    if not ServerBridge.removeItem(src, Config.Items.maintenanceKit, 1) then return end

    antenna.health = math.min(100.0, antenna.health + Config.Antenna.maintenance.health)
    antenna.state = stateForHealth(antenna.health)

    saveAntenna(antenna)
    rebuildNetworks()
    broadcast()
    TriggerClientEvent('cb_localradio:client:syncNetworks', -1, buildNetworkPayload())
end)

RegisterNetEvent('cb_localradio:server:removeAntenna', function(id)
    local src = source
    local antenna = getAntenna(id)
    if not antenna or antenna.type ~= 'player' then return end

    local ped = GetPlayerPed(src)
    local p = GetEntityCoords(ped)
    if RadioUtils.distance({x = p.x, y = p.y, z = p.z}, antenna) > Config.Antenna.interactionDistance + 1.5 then
        ServerBridge.notify(src, Config.Messages.tooFar, 'error')
        return
    end

    local owner = ServerBridge.identifier(src)
    if antenna.owner ~= owner then
        ServerBridge.notify(src, Config.Messages.notOwner, 'error')
        return
    end

    RadioAntennas[id] = nil
    MySQL.update.await('DELETE FROM cb_localradio_antennas WHERE id = ?', { id })

    if Config.Antenna.construction.itemReturnOnRemove then
        if Config.Antenna.construction.returnPercent >= 1 then
            ServerBridge.addItem(src, Config.Items.antennaKit, 1)
        end
    end

    rebuildNetworks()
    broadcast()
    TriggerClientEvent('cb_localradio:client:syncNetworks', -1, buildNetworkPayload())
    ServerBridge.notify(src, Config.Messages.antennaRemoved, 'success')
end)

CreateThread(function()
    while not ServerBridge.ready() do
        Wait(500)
    end

    Wait(1000)
    loadWorld()
    loadDatabase()
    rebuildNetworks()
    broadcast()

    while true do
        Wait(Config.Network.refreshSeconds * 1000)
        rebuildNetworks()
        TriggerClientEvent('cb_localradio:client:syncNetworks', -1, buildNetworkPayload())
    end
end)

CreateThread(function()
    while not ServerBridge.ready() do
        Wait(500)
    end

    while true do
        Wait(60000)

        if Config.Antenna.degradation.enabled then
            local now = os.time()

            for _, antenna in pairs(RadioAntennas) do
                if antenna.state ~= 'broken' then
                    local row = MySQL.single.await(
                        'SELECT TIMESTAMPDIFF(MINUTE, COALESCE(last_degradation, NOW()), NOW()) AS minutes FROM cb_localradio_antennas WHERE id = ?',
                        { antenna.id }
                    )

                    local minutes = row and tonumber(row.minutes) or 0

                    if minutes >= Config.Antenna.degradation.intervalMinutes then
                        local cycles = math.floor(minutes / Config.Antenna.degradation.intervalMinutes)
                        antenna.health = math.max(0, antenna.health - (Config.Antenna.degradation.amount * cycles))
                        antenna.state = stateForHealth(antenna.health)

                        MySQL.update.await([[
                            UPDATE cb_localradio_antennas
                            SET health = ?, state = ?, last_degradation = NOW()
                            WHERE id = ?
                        ]], { antenna.health, antenna.state, antenna.id })
                    end
                end
            end

            rebuildNetworks()
            broadcast()
            TriggerClientEvent('cb_localradio:client:syncNetworks', -1, buildNetworkPayload())
        end
    end
end)
