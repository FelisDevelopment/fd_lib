cache = FD.cache.new()
cache.set('playerId', PlayerId())
cache.set('serverId', GetPlayerServerId(cache.get('playerId')))
cache.set('gameTimer', GetGameTimer())

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        cache.set('ped', ped)
        cache.set('gameTimer', GetGameTimer())

        local vehicle = GetVehiclePedIsUsing(ped)

        if vehicle > 0 then
            cache.set('vehicle', vehicle)

            if not cache.seat or GetPedInVehicleSeat(vehicle, cache.seat) ~= ped then
                for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                    if GetPedInVehicleSeat(vehicle, i) == ped then
                        cache.set('seat', i)
                        break
                    end
                end
            end
        else
            cache.set('vehicle', false)
            cache.set('seat', false)
        end

        Wait(100)
    end
end)

_ENV.cache = cache

exports('cache', function(key)
    return cache.get(key)
end)
