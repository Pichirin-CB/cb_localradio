Bridge = {}

CreateThread(function()
    while GetResourceState('hate-bridge') ~= 'started' do
        Wait(250)
    end

    local ok, bridge = pcall(function()
        return exports['hate-bridge']:getBridge()
    end)

    if ok and bridge then
        Bridge.API = bridge
    end
end)

function Bridge.Notify(message, type, duration)
    if Bridge.API and Bridge.API.ShowNotification then
        Bridge.API.ShowNotification(message, type or 'info', duration or 5000)
    elseif GetResourceState('ox_lib') == 'started' then
        lib.notify({
            description = message,
            type = type == 'error' and 'error' or (type == 'success' and 'success' or 'inform')
        })
    end
end

function Bridge.HasItem(item, amount)
    if Bridge.API and Bridge.API.HasItem then
        return Bridge.API.HasItem(item, amount or 1)
    end
    return false
end

function Bridge.Progress(name, label, duration, animation, onFinish, onCancel)
    if Bridge.API and Bridge.API.ProgressBar then
        Bridge.API.ProgressBar(
            name,
            label,
            duration,
            false,
            true,
            {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            },
            animation,
            nil,
            onFinish,
            onCancel
        )
        return
    end

    if GetResourceState('ox_lib') == 'started' then
        local ok = lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true
            },
            anim = animation and {
                dict = animation.dict,
                clip = animation.clip,
                flag = animation.flags or 49
            } or nil
        })

        if ok then
            if onFinish then onFinish() end
        elseif onCancel then
            onCancel()
        end
        return
    end

    SetTimeout(duration, function()
        if onFinish then onFinish() end
    end)
end
