RadioAntennas = {}
RadioNetworks = {}

local ActiveOperations = {}

local function newId()
    return ('ant_%s_%s'):format(
        os.time(),
        math.random(100000, 999999)
    )
end

local function stateForHealth(health)
    health = tonumber(health) or 0

    if health <= Config.Antenna.brokenAt then
        return 'broken'
    end

    if health < Config.Antenna.maintenanceAt then
        return 'maintenance'
    end

    return 'active'
end

local function serialize(antenna)
    return {
        id = antenna.id,

        type = antenna.type,
        owner = antenna.owner,
        model = antenna.model,

        x = antenna.x,
        y = antenna.y,
        z = antenna.z,

        heading = antenna.heading,
        radius = antenna.radius,

        health = tonumber(antenna.health) or 0,
        state = antenna.state
    }
end

local function getPlayerCoords(source)
    local ped = GetPlayerPed(source)

    if not ped or ped <= 0 then
        return nil
    end

    local coords = GetEntityCoords(ped)

    if not coords then
        return nil
    end

    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }
end

local function isPlayerNearAntenna(source, antenna)
    local coords = getPlayerCoords(source)

    if not coords then
        return false
    end

    return RadioUtils.distance(
        coords,
        antenna
    ) <= (Config.Antenna.interactionDistance + 1.5)
end

local function normalizeCost(amount)
    amount = tonumber(amount) or 0

    if amount < 0 then
        amount = 0
    end

    return math.floor(amount)
end

local function buildCosts(operation)
    local configured =
        Config.Antenna.Costs
        and Config.Antenna.Costs[operation]

    if type(configured) ~= 'table' then
        return {}
    end

    local required = {}

    for key, amount in pairs(configured) do
        amount = normalizeCost(amount)

        if amount > 0 then
            local item = Config.Items[key]

            if type(item) ~= 'string'
                or item == '' then

                return nil
            end

            required[#required + 1] = {
                key = key,
                item = item,
                amount = amount
            }
        end
    end

    table.sort(
        required,
        function(a, b)
            return a.key < b.key
        end
    )

    return required
end

local function checkItemCosts(source, operation)
    local required = buildCosts(operation)

    if not required then
        return false, nil
    end

    for _, cost in ipairs(required) do
        if not ServerBridge.hasItem(
            source,
            cost.item,
            cost.amount
        ) then
            return false, required
        end
    end

    return true, required
end

local function consumeItemCosts(source, required)
    local consumed = {}

    for _, cost in ipairs(required or {}) do
        if not ServerBridge.removeItem(
            source,
            cost.item,
            cost.amount
        ) then

            for _, rollback in ipairs(consumed) do
                ServerBridge.addItem(
                    source,
                    rollback.item,
                    rollback.amount
                )
            end

            return false
        end

        consumed[#consumed + 1] = {
            item = cost.item,
            amount = cost.amount
        }
    end

    return true
end

local function consumeCosts(source, operation)
    local available, required =
        checkItemCosts(
            source,
            operation
        )

    if not available then
        return false
    end

    return consumeItemCosts(
        source,
        required
    )
end

local function buildUICosts(source, operation)
    local required = buildCosts(operation)

    if not required then
        return {}
    end

    local result = {}

    for _, cost in ipairs(required) do
        result[#result + 1] = {
            key = cost.key,
            item = cost.item,
            amount = cost.amount,

            available = ServerBridge.hasItem(
                source,
                cost.item,
                cost.amount
            )
        }
    end

    return result
end

local function hasAllUICosts(costs)
    if type(costs) ~= 'table' then
        return true
    end

    for _, cost in ipairs(costs) do
        if not cost.available then
            return false
        end
    end

    return true
end

local function buildAntennaUIData(source, antenna)
    local repairCosts =
        buildUICosts(
            source,
            'repair'
        )

    local maintenanceCosts =
        buildUICosts(
            source,
            'maintenance'
        )

    local canRepair =
        antenna.state == 'broken'
        and hasAllUICosts(repairCosts)

    local canMaintain =
        antenna.state == 'maintenance'
        and hasAllUICosts(maintenanceCosts)

    local canRemove =
        antenna.type == 'player'
        and antenna.owner ==
            ServerBridge.identifier(source)

    return {
        id = antenna.id,

        type = antenna.type,
        owner = antenna.owner,

        model = antenna.model,

        x = antenna.x,
        y = antenna.y,
        z = antenna.z,

        heading = antenna.heading,
        radius = antenna.radius,

        health = tonumber(antenna.health) or 0,
        state = antenna.state,

        canRepair = canRepair,
        canMaintain = canMaintain,
        canRemove = canRemove,

        repairCosts = repairCosts,
        maintenanceCosts = maintenanceCosts
    }
end

local function sendAntennaUIUpdate(source, antenna)
    if not source
        or source <= 0
        or not antenna then
        return
    end

    TriggerClientEvent(
        'cb_localradio:client:updateAntennaUI',
        source,
        buildAntennaUIData(
            source,
            antenna
        )
    )
end

local function loadWorld()
    for _, worldAntenna in ipairs(
        Config.WorldAntennas or {}
    ) do

        local existing =
            MySQL.single.await(
                [[
                    SELECT
                        id,
                        health,
                        state
                    FROM cb_localradio_antennas
                    WHERE id = ?
                ]],
                {
                    worldAntenna.id
                }
            )

        if not existing then
            MySQL.insert.await(
                [[
                    INSERT INTO cb_localradio_antennas
                    (
                        id,
                        type,
                        owner,
                        model,
                        x,
                        y,
                        z,
                        heading,
                        radius,
                        health,
                        state,
                        last_maintenance,
                        last_degradation
                    )
                    VALUES
                    (
                        ?,
                        'world',
                        NULL,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        100,
                        'active',
                        NOW(),
                        NOW()
                    )
                ]],
                {
                    worldAntenna.id,
                    worldAntenna.model,

                    worldAntenna.coords.x,
                    worldAntenna.coords.y,
                    worldAntenna.coords.z,

                    worldAntenna.heading or 0,
                    worldAntenna.radius
                        or Config.Antenna.defaultRadius
                }
            )
        end
    end
end

local function loadDatabase()
    RadioAntennas = {}

    local rows =
        MySQL.query.await(
            'SELECT * FROM cb_localradio_antennas'
        )

    for _, row in ipairs(rows or {}) do
        local health =
            tonumber(row.health) or 0

        local state =
            row.state

        if state ~= 'active'
            and state ~= 'maintenance'
            and state ~= 'broken' then

            state =
                stateForHealth(
                    health
                )
        end

        RadioAntennas[row.id] = {
            id = row.id,

            type = row.type,
            owner = row.owner,
            model = row.model,

            x = tonumber(row.x) or 0,
            y = tonumber(row.y) or 0,
            z = tonumber(row.z) or 0,

            heading =
                tonumber(row.heading) or 0,

            radius =
                tonumber(row.radius)
                or Config.Antenna.defaultRadius,

            health = health,
            state = state
        }
    end
end

local function saveAntenna(
    antenna,
    updateMaintenance
)
    if updateMaintenance then
        MySQL.update.await(
            [[
                UPDATE cb_localradio_antennas
                SET
                    health = ?,
                    state = ?,
                    last_maintenance = NOW(),
                    last_degradation = NOW()
                WHERE id = ?
            ]],
            {
                antenna.health,
                antenna.state,
                antenna.id
            }
        )

        return
    end

    MySQL.update.await(
        [[
            UPDATE cb_localradio_antennas
            SET
                health = ?,
                state = ?
            WHERE id = ?
        ]],
        {
            antenna.health,
            antenna.state,
            antenna.id
        }
    )
end

local function buildAntennaList()
    local list = {}

    for _, antenna in pairs(
        RadioAntennas
    ) do
        list[#list + 1] =
            serialize(antenna)
    end

    table.sort(
        list,
        function(a, b)
            return tostring(a.id)
                < tostring(b.id)
        end
    )

    return list
end

local function rebuildNetworks()
    RadioNetworks = {}

    local active = {}

    for _, antenna in pairs(
        RadioAntennas
    ) do

        if antenna.state == 'active'
            or antenna.state == 'maintenance' then

            active[#active + 1] =
                antenna
        end
    end

    local visited = {}
    local networkIndex = 0

    for _, start in ipairs(active) do
        if not visited[start.id] then
            networkIndex =
                networkIndex + 1

            local queue = {
                start
            }

            local component = {}

            visited[start.id] = true

            while #queue > 0 do
                local current =
                    table.remove(
                        queue,
                        1
                    )

                component[#component + 1] =
                    current.id

                for _, other in ipairs(active) do
                    if not visited[other.id]
                        and RadioUtils.distance(
                            current,
                            other
                        ) <=
                        Config.Network.linkDistance then

                        visited[other.id] =
                            true

                        queue[#queue + 1] =
                            other
                    end
                end
            end

            RadioNetworks[networkIndex] =
                component
        end
    end
end

local function buildNetworkPayload()
    local payload = {}

    for networkId, ids in pairs(
        RadioNetworks
    ) do

        local network = {
            id = networkId,
            antennas = ids,
            coverage = {}
        }

        for _, id in ipairs(ids) do
            local antenna =
                RadioAntennas[id]

            if antenna then
                network.coverage[#network.coverage + 1] = {
                    x = antenna.x,
                    y = antenna.y,
                    z = antenna.z,
                    radius = antenna.radius
                }
            end
        end

        payload[#payload + 1] =
            network
    end

    table.sort(
        payload,
        function(a, b)
            return a.id < b.id
        end
    )

    return payload
end

local function broadcast()
    TriggerClientEvent(
        'cb_localradio:client:syncAntennas',
        -1,
        buildAntennaList()
    )

    TriggerClientEvent(
        'cb_localradio:client:syncNetworks',
        -1,
        buildNetworkPayload()
    )
end

local function getAntenna(id)
    if id == nil then
        return nil
    end

    return RadioAntennas[
        tostring(id)
    ]
end

-- ============================================================================
-- SYNC
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:requestSync',
    function()
        local src = source

        TriggerClientEvent(
            'cb_localradio:client:syncAntennas',
            src,
            buildAntennaList()
        )

        TriggerClientEvent(
            'cb_localradio:client:syncNetworks',
            src,
            buildNetworkPayload()
        )
    end
)

-- ============================================================================
-- OPEN ANTENNA TERMINAL
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:openAntenna',
    function(id)
        local src = source

        if not ServerBridge.ready() then
            return
        end

        local antenna =
            getAntenna(id)

        if not antenna then
            return
        end

        if not isPlayerNearAntenna(
            src,
            antenna
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.tooFar,
                'error'
            )

            return
        end

        TriggerClientEvent(
            'cb_localradio:client:openAntennaUI',
            src,
            {
                antenna =
                    buildAntennaUIData(
                        src,
                        antenna
                    )
            }
        )
    end
)

-- ============================================================================
-- OPERATION REQUEST
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:requestAntennaOperation',
    function(operation, id)
        local src = source

        if not ServerBridge.ready() then
            return
        end

        if operation ~= 'repair'
            and operation ~= 'maintenance'
            and operation ~= 'remove' then
            return
        end

        if ActiveOperations[src] then
            return
        end

        local antenna =
            getAntenna(id)

        if not antenna then
            return
        end

        if not isPlayerNearAntenna(
            src,
            antenna
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.tooFar,
                'error'
            )

            return
        end

        if operation == 'repair' then
            if antenna.state ~= 'broken' then
                return
            end

            if not checkItemCosts(
                src,
                'repair'
            ) then

                ServerBridge.notify(
                    src,
                    Config.Messages.noItems,
                    'error'
                )

                sendAntennaUIUpdate(
                    src,
                    antenna
                )

                return
            end
        end

        if operation == 'maintenance' then
            if antenna.state ~= 'maintenance' then

                ServerBridge.notify(
                    src,
                    RadioUtils.locale(
                        'antenna_no_maintenance'
                    ),
                    'info'
                )

                sendAntennaUIUpdate(
                    src,
                    antenna
                )

                return
            end

            if not checkItemCosts(
                src,
                'maintenance'
            ) then

                ServerBridge.notify(
                    src,
                    Config.Messages.noItems,
                    'error'
                )

                sendAntennaUIUpdate(
                    src,
                    antenna
                )

                return
            end
        end

        if operation == 'remove' then
            if antenna.type ~= 'player' then

                ServerBridge.notify(
                    src,
                    Config.Messages.notOwner,
                    'error'
                )

                return
            end

            local owner =
                ServerBridge.identifier(src)

            if antenna.owner ~= owner then

                ServerBridge.notify(
                    src,
                    Config.Messages.notOwner,
                    'error'
                )

                return
            end
        end

        ActiveOperations[src] = {
            operation = operation,
            antennaId = antenna.id,
            createdAt = os.time()
        }

        TriggerClientEvent(
            'cb_localradio:client:antennaOperation',
            src,
            operation,
            serialize(antenna)
        )
    end
)

-- ============================================================================
-- CONSTRUCTION
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:placeAntenna',
    function(data)
        local src = source

        if not ServerBridge.ready() then
            return
        end

        if type(data) ~= 'table'
            or type(data.coords) ~= 'table' then
            return
        end

        local coords =
            data.coords

        local x =
            tonumber(coords.x)

        local y =
            tonumber(coords.y)

        local z =
            tonumber(coords.z)

        if not x or not y or not z then
            return
        end

        local heading =
            tonumber(data.heading) or 0.0

        local available, required =
            checkItemCosts(
                src,
                'construction'
            )

        if not available then

            ServerBridge.notify(
                src,
                Config.Messages.noItems,
                'error'
            )

            return
        end

        local proposed = {
            x = x,
            y = y,
            z = z
        }

        for _, antenna in pairs(
            RadioAntennas
        ) do

            if RadioUtils.distance(
                proposed,
                antenna
            ) < Config.Antenna.minimumDistance then

                ServerBridge.notify(
                    src,
                    Config.Messages.tooClose,
                    'error'
                )

                return
            end
        end

        local id =
            newId()

        local owner =
            ServerBridge.identifier(src)

        local antenna = {
            id = id,

            type = 'player',
            owner = owner,

            model =
                Config.Antenna.playerModel,

            x = x,
            y = y,
            z = z,

            heading = heading,

            radius =
                Config.Antenna.defaultRadius,

            health = 100.0,
            state = 'active'
        }

        local inserted =
            MySQL.insert.await(
                [[
                    INSERT INTO cb_localradio_antennas
                    (
                        id,
                        type,
                        owner,
                        model,
                        x,
                        y,
                        z,
                        heading,
                        radius,
                        health,
                        state,
                        last_maintenance,
                        last_degradation
                    )
                    VALUES
                    (
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        NOW(),
                        NOW()
                    )
                ]],
                {
                    antenna.id,
                    antenna.type,
                    antenna.owner,
                    antenna.model,

                    antenna.x,
                    antenna.y,
                    antenna.z,

                    antenna.heading,
                    antenna.radius,

                    antenna.health,
                    antenna.state
                }
            )

        if not inserted then

            ServerBridge.notify(
                src,
                'No se pudo guardar la antena.',
                'error'
            )

            return
        end

        if not consumeItemCosts(
            src,
            required
        ) then

            MySQL.update.await(
                [[
                    DELETE FROM cb_localradio_antennas
                    WHERE id = ?
                ]],
                {
                    antenna.id
                }
            )

            ServerBridge.notify(
                src,
                Config.Messages.noItems,
                'error'
            )

            return
        end

        RadioAntennas[
            antenna.id
        ] = antenna

        rebuildNetworks()
        broadcast()

        ServerBridge.notify(
            src,
            Config.Messages.antennaPlaced,
            'success'
        )
    end
)

-- ============================================================================
-- REPAIR
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:repair',
    function(id)
        local src = source

        local operation =
            ActiveOperations[src]

        if not operation
            or operation.operation ~= 'repair'
            or tostring(operation.antennaId)
                ~= tostring(id) then

            return
        end

        ActiveOperations[src] = nil

        local antenna =
            getAntenna(id)

        if not antenna then
            return
        end

        if not isPlayerNearAntenna(
            src,
            antenna
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.tooFar,
                'error'
            )

            return
        end

        if antenna.state ~= 'broken' then
            return
        end

        if not consumeCosts(
            src,
            'repair'
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.noItems,
                'error'
            )

            sendAntennaUIUpdate(
                src,
                antenna
            )

            return
        end

        antenna.health =
            math.min(
                100.0,
                (tonumber(
                    antenna.health
                ) or 0)
                + Config.Antenna.repair.health
            )

        antenna.state =
            stateForHealth(
                antenna.health
            )

        saveAntenna(
            antenna,
            false
        )

        rebuildNetworks()
        broadcast()

        sendAntennaUIUpdate(
            src,
            antenna
        )

        ServerBridge.notify(
            src,
            RadioUtils.locale(
                'antenna_repaired',
                math.floor(
                    antenna.health
                )
            ),
            'success'
        )
    end
)

-- ============================================================================
-- MAINTENANCE
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:maintain',
    function(id)
        local src = source

        local operation =
            ActiveOperations[src]

        if not operation
            or operation.operation ~= 'maintenance'
            or tostring(operation.antennaId)
                ~= tostring(id) then

            return
        end

        ActiveOperations[src] = nil

        local antenna =
            getAntenna(id)

        if not antenna then
            return
        end

        if not isPlayerNearAntenna(
            src,
            antenna
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.tooFar,
                'error'
            )

            return
        end

        if antenna.state ~= 'maintenance' then

            ServerBridge.notify(
                src,
                RadioUtils.locale(
                    'antenna_no_maintenance'
                ),
                'info'
            )

            sendAntennaUIUpdate(
                src,
                antenna
            )

            return
        end

        if not consumeCosts(
            src,
            'maintenance'
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.noItems,
                'error'
            )

            sendAntennaUIUpdate(
                src,
                antenna
            )

            return
        end

        antenna.health =
            math.min(
                100.0,
                (tonumber(
                    antenna.health
                ) or 0)
                + Config.Antenna.maintenance.health
            )

        antenna.state =
            stateForHealth(
                antenna.health
            )

        saveAntenna(
            antenna,
            true
        )

        rebuildNetworks()
        broadcast()

        sendAntennaUIUpdate(
            src,
            antenna
        )

        ServerBridge.notify(
            src,
            RadioUtils.locale(
                'antenna_maintained',
                math.floor(
                    antenna.health
                )
            ),
            'success'
        )
    end
)

-- ============================================================================
-- REMOVE ANTENNA
-- ============================================================================

RegisterNetEvent(
    'cb_localradio:server:removeAntenna',
    function(id)
        local src = source

        local operation =
            ActiveOperations[src]

        if not operation
            or operation.operation ~= 'remove'
            or tostring(operation.antennaId)
                ~= tostring(id) then

            return
        end

        ActiveOperations[src] = nil

        local antenna =
            getAntenna(id)

        if not antenna
            or antenna.type ~= 'player' then
            return
        end

        if not isPlayerNearAntenna(
            src,
            antenna
        ) then

            ServerBridge.notify(
                src,
                Config.Messages.tooFar,
                'error'
            )

            return
        end

        local owner =
            ServerBridge.identifier(src)

        if antenna.owner ~= owner then

            ServerBridge.notify(
                src,
                Config.Messages.notOwner,
                'error'
            )

            return
        end

        local affected =
            MySQL.update.await(
                [[
                    DELETE FROM cb_localradio_antennas
                    WHERE id = ?
                ]],
                {
                    antenna.id
                }
            )

        if not affected
            or affected < 1 then
            return
        end

        RadioAntennas[
            antenna.id
        ] = nil

        if Config.Antenna.construction
            and Config.Antenna.construction
                .itemReturnOnRemove then

            local returnPercent =
                tonumber(
                    Config.Antenna.construction
                        .returnPercent
                ) or 0

            returnPercent =
                math.max(
                    0,
                    math.min(
                        100,
                        returnPercent
                    )
                )

            if returnPercent > 0
                and math.random(
                    1,
                    100
                ) <= returnPercent then

                ServerBridge.addItem(
                    src,
                    Config.Items.antennaKit,
                    1
                )
            end
        end

        rebuildNetworks()
        broadcast()

        TriggerClientEvent(
            'cb_localradio:client:closeAntennaUI',
            src
        )

        ServerBridge.notify(
            src,
            Config.Messages.antennaRemoved,
            'success'
        )
    end
)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    while not ServerBridge.ready() do
        Wait(500)
    end

    Wait(1000)

    loadWorld()
    loadDatabase()

    rebuildNetworks()
    broadcast()
end)

-- ============================================================================
-- NETWORK REFRESH
-- ============================================================================

CreateThread(function()
    while not ServerBridge.ready() do
        Wait(500)
    end

    while true do
        Wait(
            Config.Network.refreshSeconds * 1000
        )

        rebuildNetworks()

        TriggerClientEvent(
            'cb_localradio:client:syncNetworks',
            -1,
            buildNetworkPayload()
        )
    end
end)

-- ============================================================================
-- ANTENNA DEGRADATION
-- ============================================================================

CreateThread(function()
    while not ServerBridge.ready() do
        Wait(500)
    end

    while true do
        Wait(60000)

        if Config.Antenna.degradation.enabled then

            local changed = false

            for _, antenna in pairs(
                RadioAntennas
            ) do

                if antenna.state ~= 'broken' then

                    local row =
                        MySQL.single.await(
                            [[
                                SELECT
                                    TIMESTAMPDIFF(
                                        MINUTE,
                                        COALESCE(
                                            last_degradation,
                                            NOW()
                                        ),
                                        NOW()
                                    ) AS minutes
                                FROM cb_localradio_antennas
                                WHERE id = ?
                            ]],
                            {
                                antenna.id
                            }
                        )

                    local minutes =
                        row
                        and tonumber(
                            row.minutes
                        )
                        or 0

                    local interval =
                        tonumber(
                            Config.Antenna
                                .degradation
                                .intervalMinutes
                        ) or 60

                    local amount =
                        tonumber(
                            Config.Antenna
                                .degradation
                                .amount
                        ) or 0

                    if interval > 0
                        and minutes >= interval
                        and amount > 0 then

                        local cycles =
                            math.floor(
                                minutes / interval
                            )

                        antenna.health =
                            math.max(
                                0,
                                (
                                    tonumber(
                                        antenna.health
                                    ) or 0
                                )
                                - (
                                    amount
                                    * cycles
                                )
                            )

                        antenna.state =
                            stateForHealth(
                                antenna.health
                            )

                        MySQL.update.await(
                            [[
                                UPDATE cb_localradio_antennas
                                SET
                                    health = ?,
                                    state = ?,
                                    last_degradation = NOW()
                                WHERE id = ?
                            ]],
                            {
                                antenna.health,
                                antenna.state,
                                antenna.id
                            }
                        )

                        changed = true
                    end
                end
            end

            if changed then
                rebuildNetworks()
                broadcast()
            end
        end
    end
end)

-- ============================================================================
-- PLAYER CLEANUP
-- ============================================================================

AddEventHandler(
    'playerDropped',
    function()
        local src = source

        ActiveOperations[src] = nil
    end
)