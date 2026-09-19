CreateThread(function()
    while not ServerBridge.ready() do
        Wait(250)
    end

    if ServerBridge.API and ServerBridge.API.CreateUseableItem then
        ServerBridge.API.CreateUseableItem(Config.Items.radio, function(source)
            TriggerClientEvent('cb_localradio:client:openRadio', source)
        end)

        ServerBridge.API.CreateUseableItem(Config.Items.antennaKit, function(source)
            TriggerClientEvent('cb_localradio:client:startPlacement', source)
        end)
    end

    if Config.Debug then
        print('[cb_localradio] Server bridge ready.')
    end
end)


exports('useRadio', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local source = inventory and inventory.id
        if source then
            TriggerClientEvent('cb_localradio:client:openRadio', source)
        end
    end
end)

exports('useAntenna', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local source = inventory and inventory.id
        if source then
            TriggerClientEvent('cb_localradio:client:startPlacement', source)
        end
    end
end)
