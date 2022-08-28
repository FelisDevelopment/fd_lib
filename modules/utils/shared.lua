local random = math.random
FD.utils = {}

function FD.utils.uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function FD.utils.convertToPixel(x, y)
    return (x / 1920), (y / 1080)
end

function FD.utils.convertToRes(x, y)
    return (x * 1920), (y * 1080)
end

function FD.utils.is_array(t)
    if not t then return false end
    local i = 0

    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end

    return true
end

function FD.utils.unpack(tbl)
    if FD.utils.is_array(tbl) then return table.unpack(tbl) end

    return tbl
end

-- Necessary stuff
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if not IsDuplicityVersion then
        SetNuiFocus(false, false)
    end
end)
