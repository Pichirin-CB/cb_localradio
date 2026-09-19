ServerBridge = {}

CreateThread(function()
    while GetResourceState('hate-bridge') ~= 'started' do
        Wait(250)
    end

    local ok, bridge = pcall(function()
        return exports['hate-bridge']:getBridgeServer()
    end)

    if ok and bridge then
        ServerBridge.API = bridge
    end
end)

function ServerBridge.ready()
    return ServerBridge.API ~= nil
end

function ServerBridge.itemCount(source, item, amount)
    if not ServerBridge.API or not ServerBridge.API.GetItemCount then return 0 end
    return ServerBridge.API.GetItemCount(source, item)
end

function ServerBridge.hasItem(source, item, amount)
    return ServerBridge.itemCount(source, item, amount) >= (amount or 1)
end

function ServerBridge.removeItem(source, item, amount)
    if not ServerBridge.API or not ServerBridge.API.RemoveItem then return false end
    return ServerBridge.API.RemoveItem(source, item, amount or 1)
end

function ServerBridge.addItem(source, item, amount)
    if not ServerBridge.API or not ServerBridge.API.AddItem then return false end
    return ServerBridge.API.AddItem(source, item, amount or 1)
end

function ServerBridge.identifier(source)
    if not ServerBridge.API or not ServerBridge.API.GetPlayerIdentifier then
        return ('source:%s'):format(source)
    end
    return ServerBridge.API.GetPlayerIdentifier(source) or ('source:%s'):format(source)
end

function ServerBridge.notify(source, message, type)
    if ServerBridge.API and ServerBridge.API.ShowNotification then
        ServerBridge.API.ShowNotification(source, message, type or 'info', 5000)
    else
        TriggerClientEvent('cb_localradio:client:notify', source, message, type or 'info')
    end
end

function ServerBridge.query(query, params)
    if ServerBridge.API and ServerBridge.API.ExecuteQuery then
        return ServerBridge.API.ExecuteQuery(query, params or {})
    end
    return MySQL.query.await(query, params or {})
end

function ServerBridge.insert(query, params)
    if ServerBridge.API and ServerBridge.API.ExecuteInsert then
        return ServerBridge.API.ExecuteInsert(query, params or {})
    end
    return MySQL.insert.await(query, params or {})
end

function ServerBridge.update(query, params)
    if ServerBridge.API and ServerBridge.API.ExecuteUpdate then
        return ServerBridge.API.ExecuteUpdate(query, params or {})
    end
    return MySQL.update.await(query, params or {})
end
