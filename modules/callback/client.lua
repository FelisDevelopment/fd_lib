-- https://github.com/overextended/ox_lib/blob/master/imports/callback/client.lua

local events = {}
local timers = {}
local registered = {}
local cbEvent = ('__fd_cb_%s')

RegisterNetEvent(cbEvent:format(resource), function(key, ...)
    local cb = events[key]
    return cb and cb(...)
end)

---@param event string
---@param delay number prevent the event from being called for the given time
local function eventTimer(event, delay)
    if delay and type(delay) == 'number' and delay > 0 then
        local time = GetGameTimer()

        if (timers[event] or 0) > time then
            return false
        end

        timers[event] = time + delay
    end

    return true
end

---@param _ any
---@param event string
---@param delay number
---@param cb function|false
---@param ... any
---@return unknown?
local function triggerServerCallback(_, event, delay, cb, ...)
    if not eventTimer(event, delay) then return end

    local key

    repeat
        key = ('%s:%s'):format(event, math.random(0, 100000))
    until not events[key]

    TriggerServerEvent(cbEvent:format(event), resource, key, ...)

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

---@overload fun(event: string, delay: number, cb: function, ...)
function FD.callback.execute(event, delay, cb, ...)
    triggerServerCallback(false, event, delay, cb, ...)
end

---@param event string
---@param delay number prevent the event from being called for the given time
--- Sends an event to the server and halts the current thread until a response is returned.
function FD.callback.await(event, delay, ...)
    return triggerServerCallback(_, event, delay, false, ...)
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
--- Registers an event handler and callback function to respond to server requests.
function FD.callback.register(name, cb)
    if registered[cbEvent:format(name)] then
        RemoveEventHandler(registered[cbEvent:format(name)])
    end

    registered[cbEvent:format(name)] = RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
        TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(cb, ...)))
    end)
end
