local enabled = false
local wait = 0
local followCamHeading = false
local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

local function getCrossroads()
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(cache.ped)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return lastCrossroadCheck[1] or '', lastCrossroadCheck[2] or ''
end

local function compassLoop()
    local lastHeading = 0
    local heading = 0

    Citizen.CreateThread(function()
        while enabled do
            local camRot = GetGameplayCamRot(0)

            if followCamHeading then
                heading = round(360.0 - ((camRot.z + 360.0) % 360.0))
            else
                heading = round(360.0 - GetEntityHeading(cache.ped))
            end

            if heading == 360 then heading = 0 end

            local street1, street2 = getCrossroads()

            if lastHeading ~= heading then
                SendNUIMessage({
                    app = 'compass',
                    show = 'update',
                    data = {
                        degress = heading,
                        street1 = street1,
                        street2 = street2
                    }
                })
            end

            lastHeading = heading

            Wait(wait)
        end
    end)
end

function FD.ui.enableCompass(follow, wait)
    if enabled then return end

    enabled = true
    wait = wait or 0
    followCamHeading = follow ~= nil and follow or false

    SendNUIMessage({
        app = 'compass',
        show = true,
        data = true
    })

    compassLoop()
end

function FD.ui.disableCompass()
    wait = 0
    follow = false
    enabled = false

    SendNUIMessage({
        app = 'compass',
        show = false,
        data = true
    })
end
