local playerCoords, playerCoordsChanged = {}, false

Citizen.CreateThread(function()
    while true do
        for _, ply in pairs(GetPlayers()) do
            local entity = GetPlayerPed(ply)
            local newCoords = GetEntityCoords(entity)

            if playerCoords[ply] ~= newCoords then
                playerCoords[ply] = newCoords

                -- most likely someone will move, probably this is redundant
                playerCoordsChanged = true
            end
        end

        Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        if playerCoordsChanged then
            TriggerClientEvent('fd_lib:infinity:playerCoords', -1, playerCoords)
            playerCoordsChanged = false
        end

        Wait(1000)
    end
end)

AddEventHandler('playerDropped', function()
    if playerCoords[source] then
        playerCoords[source] = nil
    end
end)
