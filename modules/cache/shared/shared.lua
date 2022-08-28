FD.cache = {}

function FD.cache.new(o)
    local self = o or {}
    self._entries = {}

    function self.has(key)
        local item = self._entries[key]

        if not item then
            return false
        end

        return true
    end

    function self.get(key)
        local item = self._entries[key]

        if item == nil then return end

        return item
    end

    function self.set(key, value)
        if self._entries[key] ~= value then
            self._entries[key] = value

            TriggerEvent(('fd_lib:cache:%s'):format(key), value)
        end
    end

    function self.find(cb)
        for key, value in pairs(self._entries) do
            if cb(value, key) then return value end
        end
    end

    function self.clear(key)
        if not key then self._entries = {} end

        self._entries[key] = nil
    end

    function self.onChange(key, cb)
        AddEventHandler(('fd_lib:cache:%s'):format(key), cb)
    end

    return self
end
