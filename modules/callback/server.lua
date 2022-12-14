-- https://github.com/overextended/ox_lib/blob/master/imports/callback/server.lua

local events = {}
local registered = {}
local cbEvent = ('__fd_cb_%s')

RegisterNetEvent(cbEvent:format(resource), function(key, ...)
    local cb = events[key]
    return cb and cb(...)
end)

---@param _ any
---@param event string
---@param playerId number
---@param cb function|false
---@param ... any
---@return unknown?
local function triggerClientCallback(_, event, playerId, cb, ...)
    local key

    repeat
        key = ('%s:%s:%s'):format(event, math.random(0, 100000), playerId)
    until not events[key]

    TriggerClientEvent(cbEvent:format(event), playerId, resource, key, ...)

    ---@type promise | false
    local promise = not cb and promise.new()

    events[key] = function(response)
        events[key] = nil

        if promise then
            return promise:resolve(response or {})
        end

        return cb and cb(table.unpack(response or {}))
    end

    if promise then
        return table.unpack(Citizen.Await(promise))
    end
end

---@overload fun(event: string, playerId: number, cb: function, ...)
function FD.callback.execute(event, playerId, cb, ...)
    triggerServerCallback(false, event, playerId, cb, ...)
end

---@param event string
---@param playerId number
--- Sends an event to a client and halts the current thread until a response is returned.
function FD.callback.await(event, playerId, ...)
    return triggerClientCallback(_, event, playerId, false, ...)
end

local function callbackResponse(success, result, ...)
    if not success then
        if result then
            return print(('^1SCRIPT ERROR: %s^0\n%s'):format(result,
                Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
        end

        return false
    end

    return { result, ... }
end

local pcall = pcall

---@param name string
---@param cb function
--- Registers an event handler and callback function to respond to client requests.
function FD.callback.register(name, cb)
    if registered[cbEvent:format(name)] then
        RemoveEventHandler(registered[cbEvent:format(name)])
    end

    registered[cbEvent:format(name)] = RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
        TriggerClientEvent(cbEvent:format(resource), source, key, callbackResponse(pcall(cb, source, ...)))
    end)
end
