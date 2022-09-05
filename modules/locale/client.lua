local dict

function loadInternalLocale()
    local locale = GetConvar("fd:locale", "en")

    local dictionary = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(locale)) or
        LoadResourceFile('fd_lib', ('locales/en.json'):format(locale))

    dict = json.decode(dictionary)
end

function locale(str, ...)
    local lstr = dict[str]

    if lstr then
        if ... then
            return lstr and lstr:format(...)
        end

        return lstr
    end

    return ("Translation for '%s' does not exist"):format(str)
end

function setLocaleKey(key, value)
    dict[key] = value
end

RegisterNUICallback('getLocale', function(_, cb)
    cb(dict)
end)

loadInternalLocale()
