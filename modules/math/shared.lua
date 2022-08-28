FD.math = math

function FD.math.average(t)
    local sum = 0

    for _, v in ipairs(t) do
        sum = sum + v
    end

    return sum / #t
end

function FD.math.is_integer(value)
    return type(value) == 'number' and FD.math.tointeger(value)
end
