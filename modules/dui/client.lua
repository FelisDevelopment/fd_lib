local available = {}
local registered = {}
local count = 0

function FD.dui.get(url, width, height)
    width = width or 256
    height = height or 256

    local size = ('%sx%s'):format(width, height)

    if available[size] and #available[size] > 0 then
        local firstKey, FirstValue = pairs(available[size])
        local key, value = firstKey(FirstValue)

        local id = value
        local dict = registered[id].dict
        local txt = registered[id].txt

        table.remove(available[size], key)
        SetDuiUrl(registered[id].object, url)

        return {
            id = id,
            dict = dict,
            txt = txt
        }
    end

    count = count + 1
    local generated = {
        dict = ('%s_dict_%s'):format(size, count),
        txt = ('%s_txt_%s'):format(size, count)
    }

    local duiObj = CreateDui(url, width, height)
    local dictObj = CreateRuntimeTxd(generated.dict)
    local duiHandle = GetDuiHandle(duiObj)
    local txtObj = CreateRuntimeTextureFromDuiHandle(dictObj, generated.txt, duiHandle)

    registered[count] = {
        size = size,
        objects = {
            dui = duiObj,
            dict = dictObj,
            txt = txtObj
        },
        generated = generated,
        handle = duiHandle,
    }

    return {
        id = count,
        dict = generated.dict,
        txt = generated.txt
    }
end

function FD.dui.change(id, url)
    if (not registered[id]) then
        return
    end

    local settings = registered[id]
    SetDuiUrl(settings.duiObject, url)
end

function FD.dui.remove(id)
    if not registered[id] then
        return
    end

    local size = registered[id].size

    SetDuiUrl(registered[id].objects.dui, 'about:blank')

    if not available[size] then
        available[size] = {}
    end

    table.insert(available[size], id)
end
