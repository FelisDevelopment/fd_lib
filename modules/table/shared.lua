-- Expand table library
FD.table = table

local pairs = pairs
local ipairs = ipairs

function FD.table.contains(tbl, value)
    if type(value) ~= 'table' then
        for _, v in pairs(tbl) do
            if v == value then return true end
        end
    else
        local matched_values = 0
        local values = 0
        for _, v1 in pairs(value) do
            values += 1

            for _, v2 in pairs(tbl) do
                if v1 == v2 then matched_values += 1 end
            end
        end
        if matched_values == values then return true end
    end
    return false
end

function FD.table.matches(t1, t2)
    local type1, type2 = type(t1), type(t2)
    if type1 ~= type2 then return false end
    if type1 ~= 'table' and type2 ~= 'table' then return t1 == t2 end

    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not FD.table.matches(v1, v2) then return false end
    end

    for k2, v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not FD.table.matches(v1, v2) then return false end
    end
    return true
end

function FD.table.deepclone(tbl)
    tbl = FD.table.clone(tbl)

    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            tbl[k] = FD.utils.deepclone(v)
        end
    end

    return tbl
end

function FD.table.irange(n, begin)
    local t = {}

    for i = begin or 1, n do
        table.insert(t, i)
    end

    return t
end

function FD.table.range(n, begin, value)
    local t = {}

    for i = begin or 1, n do
        t[i] = value or true
    end

    return t
end

function FD.table.ishuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end

    return t
end

function FD.table.length(t)
    local length = 0

    for _ in pairs(t) do
        length = length + 1
    end

    return length
end

function FD.table.empty(t)
    return next(t) == nil
end

function FD.table.clear(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end

function FD.table.foreach(t, func)
    for k, v in pairs(t) do
        func(v, k)
    end
end

function FD.table.iforeach(t, func)
    for k, v in ipairs(t) do
        func(v, k)
    end
end

function FD.table.count(t, value)
    local count = 0

    for k, v in pairs(t) do
        if v == value then
            count = count + 1
        end
    end

    return count
end

function FD.table.icount(t, value)
    local count = 0

    for k, v in ipairs(t) do
        if v == value then
            count = count + 1
        end
    end

    return count
end

function FD.table.count_if(t, func)
    local count = 0

    for k, v in pairs(t) do
        if func(v, k) then
            count = count + 1
        end
    end

    return count
end

function FD.table.icount_if(t, func)
    local count = 0

    for k, v in ipairs(t) do
        if func(v, k) then
            count = count + 1
        end
    end

    return count
end

function FD.table.random(t)
    local keys = {}

    for k, _ in pairs(t) do
        table.insert(keys, k)
    end

    local i = keys[math.random(#keys)]
    return t[i], i
end

function FD.table.irandom(t)
    local i = math.random(#t)
    return t[i], i
end

function FD.table.random_n(t, n)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end

    return FD.table.irandom_n(keys, n)
end

function FD.table.irandom_n(t, n)
    local keys = FD.table.irange(#t)

    FD.table.ishuffle(keys)

    local result = {}

    for i = 1, n do
        table.insert(result, t[keys[i]])
    end

    return result
end

function FD.table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k, v
        end
    end

    return nil
end

function FD.table.ifind(t, value)
    for k, v in ipairs(t) do
        if v == value then
            return k, v
        end
    end

    return nil
end

function FD.table.try_remove(t, value)
    local k = FD.table.find(t, value)
    if k then
        FD.table.remove(t, k)
        return true
    end

    return false
end

function FD.table.iremove_if(t, func, removeFunc)
    for i = #t, 1, -1 do
        local v = t[i]
        if func(v, i) then
            if removeFunc then
                removeFunc(v, i)
            end
            FD.table.remove(t, i)
        end
    end
end

function FD.table.find_if(t, func)
    for k, v in pairs(t) do
        if func(v, k) then
            return v, k
        end
    end

    return nil
end

function FD.table.ifind_if(t, func)
    for k, v in ipairs(t) do
        if func(v, k) then
            return v, k
        end
    end

    return nil
end

function FD.table.filter(t, func)
    local result = {}

    for k, v in pairs(t) do
        if func(v, k) then
            result[k] = v
        end
    end

    return result
end

function FD.table.ifilter(t, func)
    local result = {}

    for k, v in ipairs(t) do
        if func(v, k) then
            table.insert(result, v)
        end
    end

    return result
end

function FD.table.map(t, func)
    local result = {}

    for k, v in pairs(t) do
        result[k] = func(v, k)
    end

    return result
end

function FD.table.every(t, func)
    for k, v in pairs(t) do
        if not func(v, k) then
            return false
        end
    end

    return true
end

function FD.table.some(t, func)
    for k, v in pairs(t) do
        if func(v, k) then
            return true
        end
    end

    return false
end

function FD.table.isome(t, func)
    for k, v in ipairs(t) do
        if func(v, k) then
            return true
        end
    end

    return false
end

function FD.table.ireduce(t, func, initialValue)
    local result = initialValue or t[1]
    local index = initialValue and 1 or 2

    for i = index, #t do
        result = result + func(result, t[i], i)
    end

    return result
end

function FD.table.islice(t, i, j)
    local result = {}

    for k = i, j or #t do
        table.insert(result, t[k])
    end

    return result
end

-- function FD.table.sort(tbl)
--     local keys = {}

--     for key, _ in pairs(tbl) do
--         table.table.insert(keys, key)
--     end

--     table.sort(keys, function(keyLhs, keyRhs) return tbl[keyLhs] < tbl[keyRhs] end)

--     local result = {}

--     for k = i, j or #t do
--         table.insert(result, t[k])
--     end

--     return result
-- end
