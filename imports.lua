local resource = 'fd_lib'

if not _VERSION:find('5.4') then
    error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

if not GetResourceState(resource):find('start') then
    error(("^1%s should be started before this resource^0"):format(resource), 2)
end

-- Cache API
-- Most credits go to https://github.com/overextended/ox_lib/blob/master/init.lua#L129 for this API

cache = {
    resource = GetCurrentResourceName(),
    onChange = function(key, cb)
        AddEventHandler(('fd_lib:cache:%s'):format(key), cb)
    end
}

setmetatable(cache, {
    __index = function(self, key)
        AddEventHandler(('fd_lib:cache:%s'):format(key), function(value)
            self[key] = value
        end)

        return rawset(self, key, exports[resource].cache(self, key) or false)[key]
    end,
})

if not IsDuplicityVersion() then
    cache.playerId = PlayerId()
    cache.serverId = GetPlayerServerId(cache.playerId)
end
