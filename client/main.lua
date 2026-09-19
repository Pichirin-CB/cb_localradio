CreateThread(function()
    while GetResourceState('hate-bridge') ~= 'started' do
        Wait(250)
    end

    Wait(1500)
    TriggerServerEvent('cb_localradio:server:requestSync')
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1500)
        TriggerServerEvent('cb_localradio:server:requestSync')
    end
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for _, entity in pairs(AntennaClient.entities or {}) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
end)
