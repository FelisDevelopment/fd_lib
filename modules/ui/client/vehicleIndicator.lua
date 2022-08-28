local threadActive

function FD.ui.vehicleIndicator(o)
    local self = o or {}

    self.uuid = FD.utils.uuid()
    self.shown = false
    self.lastValues = {}

    SendNUIMessage({
        app = 'vehicleIndicator',
        show = 'indicator:register',
        data = self
    })

    function self.show()
        if not self.shown then
            SendNUIMessage({
                app = 'vehicleIndicator',
                show = 'indicator:open',
                data = {
                    uuid = self.uuid
                }
            })

            self.shown = true
        end
    end

    function self.update(key, value)
        if self.lastValues[key] ~= value then
            SendNUIMessage({
                app = 'vehicleIndicator',
                show = 'indicator:update',
                data = {
                    uuid = self.uuid,
                    key = key,
                    value = value
                }
            })

            self.lastValues[key] = value
        end
    end

    function self.hide()
        if self.shown then
            SendNUIMessage({
                app = 'vehicleIndicator',
                show = 'indicator:close',
                data = {
                    uuid = self.uuid
                }
            })
        end

        self.shown = false
    end

    function self.delete()
        SendNUIMessage({
            app = 'vehicleIndicator',
            show = 'indicator:delete',
            data = {
                uuid = self.uuid
            }
        })
    end

    function self.isShown()
        return self.shown
    end

    function self.getLastValue(key)
        return self.lastValues[key]
    end

    return self
end

local function vehicleThread(isKmh, delayed)
    local multiplier = isKmh and 3.6 or 2.236936

    Citizen.CreateThread(function()
        local isAircraft = IsPedInAnyPlane(cache.ped) or IsPedInAnyHeli(cache.ped)

        while threadActive do
            local vehicle = cache.get('vehicle')

            if not vehicle then
                goto continue
            end

            SendNUIMessage({
                app = 'vehicleIndicator',
                show = 'update',
                data = {
                    rpm = GetVehicleCurrentRpm(vehicle),
                    speed = GetEntitySpeed(vehicle) * multiplier,
                    gear = GetVehicleCurrentGear(vehicle),
                    isKmh = isKmh,
                    isAircraft = isAircraft,
                    altitude = isAircraft and GetEntityHeightAboveGround(vehicle) or 0
                }
            })

            ::continue::
            Wait(delayed and 200 or 100)
        end
    end)
end

function FD.ui.toggleVehicleHud(isKmh, delayed)
    if threadActive then
        SendNUIMessage({
            app = 'vehicleIndicator',
            show = false,
            data = false
        })

        threadActive = false

        return
    end

    threadActive = true

    SendNUIMessage({
        app = 'vehicleIndicator',
        show = true,
        data = false
    })

    if type(isKmh) == 'boolean' then
        isKmh = isKmh
    else
        isKmh = ShouldUseMetricMeasurements()
    end

    vehicleThread(isKmh, delayed or false)
end
