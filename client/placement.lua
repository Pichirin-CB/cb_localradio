Placement = {
    active = false,
    object = nil,
    coords = nil,
    heading = 0.0
}

local function loadModel(model)
    local hash = joaat(model)
    RequestModel(hash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(0)
    end

    return HasModelLoaded(hash), hash
end

local function rotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local cosX = math.abs(math.cos(x))
    return vector3(-math.sin(z) * cosX, math.cos(z) * cosX, math.sin(x))
end

local function raycastFromCamera(distance)
    local camRot = GetGameplayCamRot(2)
    local camCoord = GetGameplayCamCoord()
    local direction = rotationToDirection(camRot)
    local destination = camCoord + direction * distance

    local ray = StartShapeTestRay(
        camCoord.x, camCoord.y, camCoord.z,
        destination.x, destination.y, destination.z,
        1,
        PlayerPedId(),
        0
    )

    local _, hit, endCoords = GetShapeTestResult(ray)
    return hit == 1, endCoords
end

local function stopPlacement()
    if Placement.object and DoesEntityExist(Placement.object) then
        DeleteEntity(Placement.object)
    end

    Placement.object = nil
    Placement.active = false
    Placement.coords = nil
end

function StartAntennaPlacement()
    if Placement.active then return end

    if not Bridge.HasItem(Config.Items.antennaKit, 1) then
        Bridge.Notify(Config.Messages.noItems, 'error')
        return
    end

    local loaded, model = loadModel(Config.Antenna.playerModel)
    if not loaded then
        Bridge.Notify('No se pudo cargar el modelo de la antena.', 'error')
        return
    end

    Placement.active = true
    Placement.heading = GetEntityHeading(PlayerPedId())

    local object = CreateObject(model, 0.0, 0.0, 0.0, false, false, false)
    Placement.object = object

    SetEntityAlpha(object, 150, false)
    SetEntityCollision(object, false, false)
    FreezeEntityPosition(object, true)

    SetModelAsNoLongerNeeded(model)

    Bridge.Notify('Coloca la antena. E confirma, G cancela, Q/E rota.', 'info')

    CreateThread(function()
        while Placement.active do
            Wait(0)

            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            local hit, coords = raycastFromCamera(10.0)

            if hit then
                local ground, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, false)

                if ground then
                    coords = vector3(coords.x, coords.y, groundZ)
                end

                Placement.coords = coords

                SetEntityCoordsNoOffset(
                    object,
                    coords.x,
                    coords.y,
                    coords.z,
                    false,
                    false,
                    false
                )

                SetEntityHeading(object, Placement.heading)

                DrawMarker(
                    1,
                    coords.x, coords.y, coords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.4, 0.4, 0.15,
                    80, 220, 120, 120,
                    false, false, 2, false, nil, nil, false
                )
            end

            if IsControlJustReleased(0, 44) then
                Placement.heading = Placement.heading - 5.0
            elseif IsControlJustReleased(0, 38) then
                if not IsControlPressed(0, 21) then
                    Placement.heading = Placement.heading + 5.0
                end
            end

            if IsControlJustReleased(0, 38) and IsControlPressed(0, 21) then
                if Placement.coords then
                    local finalCoords = Placement.coords
                    local finalHeading = Placement.heading

                    stopPlacement()

                    Bridge.Progress(
                        'cb_localradio_construction',
                        'Construyendo antena...',
                        Config.Antenna.construction.duration,
                        Config.Antenna.construction.animation,
                        function()
                            TriggerServerEvent('cb_localradio:server:placeAntenna', {
                                coords = {
                                    x = finalCoords.x,
                                    y = finalCoords.y,
                                    z = finalCoords.z
                                },
                                heading = finalHeading
                            })
                        end,
                        function()
                            Bridge.Notify(Config.Messages.constructionCancelled, 'error')
                        end
                    )
                end
            end

            if IsControlJustReleased(0, 47) then
                stopPlacement()
                Bridge.Notify(Config.Messages.constructionCancelled, 'error')
            end
        end
    end)
end

RegisterNetEvent('cb_localradio:client:startPlacement', function()
    StartAntennaPlacement()
end)

RegisterCommand('placeantenna', function()
    StartAntennaPlacement()
end, false)
