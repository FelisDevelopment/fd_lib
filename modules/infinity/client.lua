local entityPromises, entityCoords = {}, {}
local playerCoords = {}

RegisterNetEvent('fd_lib:infinity:playerCoords', function(coords)
    playerCoords = coords
end)

RegisterNetEvent('np:infinity:entity:promise')
AddEventHandler('np:infinity:entity:promise', function(netId, coords)
    if entityPromises[netId] then
        entityPromises[netId]:resolve(coords)
    end
end)

function FD.infinity.getEntityCoords(netId)
    local p = promise:new()
    local timeout = FD.utils.promiseTimeout(2000)

    entityPromises[netId] = p

    TriggerServerEvent('fd_lib:infinity:entity:get', id)

    local coords = Citizen.Await(promise.first({ timeout, p }))

    entityCoords[netId] = coords
    entityPromises[netId] = nil

    return coords
end

function FD.infinity.getNetworkedPlayerCoords(netId)
    local index = GetPlayerFromServerId(netId)

    if index ~= -1 then
        return GetEntityCoords(GetPlayerPed(netId))
    end

    return playerCoords[netId] or vec3(0.0, 0.0, 0.0)
end

function FD.infinity.getNetworkedEntityCoords(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(entity) then
        return GetEntityCoords(entity)
    end

    return entityCoords[netId] or FD.infinity.getEntityCoords(netId)
end

function FD.infinity.getPlayerCoords(netId)
    return playerCoords[netId] or vec3(0.0, 0.0, 0.0)
end

function FD.infinity.playerExistsInRange(netId)
    local playerId = GetPlayerFromServerId(tonumber(netId))

    if playerId ~= -1 then
        return true
    end
end

function FD.infinity.isPlayerActive(netId)
    return playerCoords[tonumber(netId)] ~= nil
end

function FD.infinity.getPlayerList()
    return playerCoords
end

function FD.infinity.getLocalPlayer(netId)
    local index = GetPlayerFromServerId(netId)

    return index ~= -1 and GetPlayerPed(index) or 0
end

function FD.infinity.getLocalEntity(netId)
    return NetworkGetEntityFromNetworkId(netId)
end
