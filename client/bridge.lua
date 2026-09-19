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
        local ok = pcall(function()
            Bridge.API.ShowNotification(
                message,
                type or 'info',
                duration or 5000
            )
        end)

        if ok then
            return
        end
    end

    if type(lib) == 'table' and type(lib.notify) == 'function' then
        lib.notify({
            description = message,
            type = type == 'error'
                and 'error'
                or (type == 'success' and 'success' or 'inform')
        })

        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

function Bridge.HasItem(item, amount)
    if Bridge.API and Bridge.API.HasItem then
        local ok, result = pcall(function()
            return Bridge.API.HasItem(
                item,
                amount or 1
            )
        end)

        if ok then
            return result == true
        end
    end

    return false
end

local function loadAnimation(animation)
    if not animation then
        return false
    end

    if not animation.dict or not animation.clip then
        return false
    end

    RequestAnimDict(animation.dict)

    local timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(animation.dict)
        and GetGameTimer() < timeout do

        Wait(0)
    end

    if not HasAnimDictLoaded(animation.dict) then
        return false
    end

    return true
end

local function startAnimation(ped, animation)
    if not loadAnimation(animation) then
        return false
    end

    TaskPlayAnim(
        ped,
        animation.dict,
        animation.clip,
        8.0,
        -8.0,
        -1,
        animation.flags or 49,
        0.0,
        false,
        false,
        false
    )

    return true
end

local function stopAnimation(ped, animation)
    if animation
        and animation.dict
        and animation.clip then

        StopAnimTask(
            ped,
            animation.dict,
            animation.clip,
            2.0
        )
    end

    ClearPedTasks(ped)
end

local function drawProgressText(label, progress)
    BeginTextCommandDisplayHelp('STRING')

    AddTextComponentSubstringPlayerName(
        ('%s~n~%d%%'):format(
            label,
            math.floor(progress * 100.0)
        )
    )

    EndTextCommandDisplayHelp(
        0,
        false,
        false,
        1
    )
end

local function fallbackProgress(
    name,
    label,
    duration,
    animation,
    onFinish,
    onCancel
)
    CreateThread(function()
        local ped = PlayerPedId()

        local startTime = GetGameTimer()
        local endTime = startTime + duration

        local animationPlaying = startAnimation(
            ped,
            animation
        )

        while GetGameTimer() < endTime do
            Wait(0)

            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)

            DisableControlAction(0, 44, true)
            DisableControlAction(0, 75, true)

            local elapsed = GetGameTimer() - startTime

            local progress = elapsed / duration

            if progress < 0.0 then
                progress = 0.0
            elseif progress > 1.0 then
                progress = 1.0
            end

            drawProgressText(
                label,
                progress
            )

            -- X cancela la accion.
            if IsControlJustReleased(0, 73) then
                if animationPlaying then
                    stopAnimation(
                        ped,
                        animation
                    )
                end

                if onCancel then
                    onCancel()
                end

                return
            end
        end

        if animationPlaying then
            stopAnimation(
                ped,
                animation
            )
        end

        if onFinish then
            onFinish()
        end
    end)
end

function Bridge.Progress(
    name,
    label,
    duration,
    animation,
    onFinish,
    onCancel
)
    duration = tonumber(duration) or 1000

    -- ============================================================
    -- IMPORTANTE
    --
    -- No llamamos directamente a hate-bridge cuando ox_lib esta
    -- iniciado, porque la implementacion QB del bridge actualmente
    -- puede terminar ejecutando:
    --
    --     lib.progressBar(...)
    --
    -- aunque 'lib' no exista en ese recurso.
    --
    -- Primero comprobamos si existe un progressbar nativo compatible
    -- que el bridge pueda utilizar sin esa ruta de ox_lib.
    -- ============================================================

    local bridgeProgressAvailable = false

    if GetResourceState('qb-progressbar') == 'started' then
        bridgeProgressAvailable = true
    elseif GetResourceState('esx_progressbar') == 'started' then
        bridgeProgressAvailable = true
    end

    if bridgeProgressAvailable
        and Bridge.API
        and Bridge.API.ProgressBar then

        local bridgeAnimation = nil

        if animation
            and animation.dict
            and animation.clip then

            bridgeAnimation = {
                dict = animation.dict,
                anim = animation.clip,
                flags = animation.flags or 49
            }
        end

        local ok = pcall(function()
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
                bridgeAnimation,
                nil,
                onFinish,
                onCancel
            )
        end)

        if ok then
            return
        end
    end

    -- ============================================================
    -- OX_LIB
    --
    -- Solo lo utilizamos si 'lib' realmente existe.
    --
    -- Tener ox_lib iniciado NO garantiza por si solo que el global
    -- 'lib' este disponible dentro de este recurso.
    -- ============================================================

    if type(lib) == 'table'
        and type(lib.progressBar) == 'function' then

        local oxAnimation = nil

        if animation
            and animation.dict
            and animation.clip then

            oxAnimation = {
                dict = animation.dict,
                clip = animation.clip,
                flag = animation.flags or 49
            }
        end

        local ok, result = pcall(function()
            return lib.progressBar({
                duration = duration,
                label = label,

                useWhileDead = false,
                canCancel = true,

                disable = {
                    move = true,
                    car = true,
                    combat = true
                },

                anim = oxAnimation
            })
        end)

        if ok then
            if result then
                if onFinish then
                    onFinish()
                end
            else
                if onCancel then
                    onCancel()
                end
            end

            return
        end
    end

    -- ============================================================
    -- FALLBACK INTERNO
    --
    -- No depende de:
    --     ox_lib
    --     qb-progressbar
    --     esx_progressbar
    --
    -- Esto garantiza que cb_localradio pueda ejecutar la accion
    -- aunque ninguno de esos sistemas este disponible.
    -- ============================================================

    fallbackProgress(
        name,
        label,
        duration,
        animation,
        onFinish,
        onCancel
    )
end