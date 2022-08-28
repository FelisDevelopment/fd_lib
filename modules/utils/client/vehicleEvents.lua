local CurrentVehicle, PreviousVehicle, CurrentSeat, PreviousSeat, IsEnteringVehicle, IsInVehicle, IsEngineOn, IsSpeeding, CurrentBodyHealth, PreviousBodyHealth, CurrentSpeed, PreviousSpeed, CurrentVelocity, PreviousVelocity

-- Extend baseevents resource and add more vehicle events /w client side events
Citizen.CreateThread(function()
    while true do
        if not IsInVehicle then
            local vehicle = GetVehiclePedIsIn(cache.get('ped'))
            local vehicleIsTryingToEnter = vehicle == 0 and GetVehiclePedIsTryingToEnter(cache.get('ped')) or 0

            if vehicleIsTryingToEnter ~= 0 and not IsEnteringVehicle then
                IsEnteringVehicle = true

                TriggerEvent('baseevents:enteringVehicle', vehicleIsTryingToEnter,
                    GetSeatPedIsTryingToEnter(cache.get('ped')),
                    GetVehicleClass(vehicleIsTryingToEnter), GetEntityModel(vehicleIsTryingToEnter))
            elseif IsEnteringVehicle and vehicleIsTryingToEnter == 0 and vehicle == 0 then
                IsEnteringVehicle = false

                TriggerEvent('baseevents:enteringAborted')
                TriggerServerEvent('baseevents:enteringAborted')
            elseif vehicle ~= 0 then
                IsInVehicle = true
                IsEnteringVehicle = false

                CurrentBodyHealth, PreviousBodyHealth, CurrentSpeed, PreviousSpeed, CurrentVelocity, PreviousVelocity = nil

                CurrentVehicle = vehicle
                CurrentSeat = GetPedVehicleSeat(cache.get('ped'))

                TriggerEvent('baseevents:enteredVehicle', vehicle, CurrentSeat, GetDisplayNameFromVehicleModel(model),
                    GetVehicleClass(vehicle), GetEntityModel(vehicle))
            end
        elseif IsInVehicle then
            PreviousVehicle = CurrentVehicle
            PreviousSeat = CurrentSeat

            CurrentVehicle = GetVehiclePedIsIn(cache.get('ped'))
            CurrentSeat = GetPedVehicleSeat(cache.get('ped'))

            if CurrentVehicle == 0 then
                IsLeavingVehicle = false
                IsInVehicle = false
                IsEngineOn = false

                TriggerEvent('baseevents:leftVehicle', PreviousVehicle, PreviousSeat,
                    GetDisplayNameFromVehicleModel(model), GetVehicleClass(PreviousVehicle),
                    GetEntityModel(PreviousVehicle))
            elseif PreviousVehicle and PreviousVehicle ~= 0 and PreviousVehicle ~= CurrentVehicle then
                IsEngineOn = false

                CurrentBodyHealth, PreviousBodyHealth, CurrentSpeed, PreviousSpeed, CurrentVelocity, PreviousVelocity = nil

                TriggerEvent('baseevents:leftVehicle', PreviousVehicle, PreviousSeat,
                    GetDisplayNameFromVehicleModel(previousModel), GetVehicleClass(PreviousVehicle),
                    GetEntityModel(PreviousVehicle))

                TriggerEvent('baseevents:enteredVehicle', CurrentVehicle, CurrentSeat,
                    GetDisplayNameFromVehicleModel(currentModel), GetVehicleClass(CurrentVehicle),
                    GetEntityModel(CurrentVehicle))
            elseif PreviousSeat and PreviousSeat ~= -2 and CurrentSeat ~= PreviousSeat then
                local netId = NetworkGetNetworkIdFromEntity(CurrentVehicle)
                TriggerEvent('baseevents:vehicleChangedSeat', CurrentVehicle, CurrentSeat, PreviousSeat)
                TriggerServerEvent('baseevents:vehicleChangedSeat', netId, CurrentSeat, PreviousSeat)
            elseif not IsEngineOn and IsVehicleEngineOn(CurrentVehicle) then
                IsEngineOn = true
                TriggerEvent('baseevents:vehicleEngineOn', CurrentVehicle, CurrentSeat)
            elseif IsEngineOn and not IsVehicleEngineOn(CurrentVehicle) then
                IsEngineOn = false
                TriggerEvent('baseevents:vehicleEngineOff', CurrentVehicle, CurrentSeat)
            elseif not IsLeavingVehicle and GetIsTaskActive(cache.get('ped'), 2) then
                IsLeavingVehicle = true
                TriggerEvent('baseevents:leavingVehicle', CurrentVehicle, CurrentSeat)
            elseif IsLeavingVehicle and not GetIsTaskActive(cache.get('ped'), 2) then
                IsLeavingVehicle = false
                TriggerEvent('baseevents:leavingAborted', CurrentVehicle, CurrentSeat)
            end
        end

        Citizen.Wait(100)
    end
end)

-- This adds vehicle crash/speeding events
Citizen.CreateThread(function()
    local airTime = 0

    while true do
        local idle = 1000

        if CurrentVehicle and CurrentVehicle ~= 0 and CurrentSeat == -1 and
            not IsThisModelABicycle(GetEntityModel(CurrentVehicle)) then
            PreviousSpeed = CurrentSpeed
            PreviousVelocity = CurrentVelocity
            PreviousBodyHealth = CurrentBodyHealth

            CurrentSpeed = GetEntitySpeed(CurrentVehicle)
            CurrentVelocity = GetEntityVelocity(CurrentVehicle)
            CurrentBodyHealth = GetVehicleBodyHealth(CurrentVehicle)

            local healthChange = PreviousBodyHealth ~= nil and (PreviousBodyHealth - CurrentBodyHealth) or 0.0
            local heavyImpact = (PreviousSpeed and PreviousSpeed > 25.0 and CurrentSpeed < (PreviousSpeed * 0.75))
            local minorImpact = (
                (healthChange >= 4 or CurrentBodyHealth < 150.0) and HasEntityCollidedWithAnything(CurrentVehicle))

            if IsEntityInAir(CurrentVehicle) and
                (
                IsThisModelABike(GetEntityModel(CurrentVehicle)) or IsThisModelAQuadbike(GetEntityModel(CurrentVehicle))
                ) then
                airTime = airTime + 1

                heavyImpact = (
                    PreviousSpeed and PreviousSpeed > 25.0 and CurrentSpeed < (PreviousSpeed * 0.75) and airTime > 40)
            elseif airTime ~= 0 then
                airTime = 0
            end

            if heavyImpact or minorImpact then
                local velocity = { x = PreviousVelocity.x, y = PreviousVelocity.y, z = PreviousVelocity.z }
                TriggerEvent('baseevents:vehicleCrashed', CurrentVehicle, CurrentSeat, CurrentSpeed, PreviousSpeed,
                    velocity, healthChange, heavyImpact, minorImpact)
            end

            if CurrentSpeed > 28 and not IsSpeeding then
                IsSpeeding = true
                TriggerEvent('baseevents:vehicleSpeeding', true, CurrentVehicle, CurrentSeat, CurrentSpeed)
            elseif IsSpeeding and CurrentSpeed < 28 then
                IsSpeeding = false
                TriggerEvent('baseevents:vehicleSpeeding', false, CurrentVehicle, CurrentSeat, CurrentSpeed)
            end

            idle = 100
        end

        Citizen.Wait(idle)
    end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)

    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end
