local result = nil

-- showType
-- 0 - Normal
-- 1 - Normal + Mirrored
-- 2 - Mirrored

-- ['numeric', 'alphabet', 'alphanumeric', 'greek', 'braille', 'runes'],
function FD.ui.combination(duration, difficulty, type, hideChars)
    if LocalPlayer.state.isBusy then return end

    difficulty = difficulty == nil and 'random' or difficulty
    type = type == nil and 0 or type
    hideChars = hideChars == nil and false or hideChars

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, false)
    SendNUIMessage({
        app = "combinationMinigame",
        show = true,
        data = {
            sets = difficulty,
            showType = type,
            duration = duration,
            hideChars = hideChars
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

-- mode: 5,
-- duration: 5000,
-- tolerance: 10,
-- positionsNeeded: 5,
function FD.ui.memory(duration, mode, positionsNeeded, tolerance)
    if LocalPlayer.state.isBusy then return end

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        app = "memoryMinigame",
        show = true,
        data = {
            duration = duration,
            mode = mode,
            positionsNeeded = positionsNeeded,
            tolerance = tolerance
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

-- {
-- 	length: 5,
-- 	duration: 5000,
-- }
function FD.ui.password(duration, length)
    if LocalPlayer.state.isBusy then return end

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, false)
    SendNUIMessage({
        app = "passwordMinigame",
        show = true,
        data = {
            duration = duration,
            length = length
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

-- squares: 5,
-- duration: 10000,
-- inverted: false,
-- hideQuestion: false,
-- debug: true,
function FD.ui.squares(duration, squares, inverted, invertTyping, hideQuestion, debug)
    if LocalPlayer.state.isBusy then return end

    squares = squares <= 2 and 3 or (squares > 7 and 7 or squares)

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, false)
    SendNUIMessage({
        app = "squareMinigame",
        show = true,
        data = {
            duration = duration,
            squares = squares,
            inverted = inverted,
            invertTyping = invertTyping,
            hideQuestion = hideQuestion,
            debug = debug
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

function FD.ui.keys(difficulty, total, tolerance)
    if LocalPlayer.state.isBusy then return end

    difficulty = type(difficulty) ~= 'string' and 'easy' or difficulty
    total = total == nil and 10 or total
    tolerance = tolerance == nil and 5 or tolerance

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, false)
    SendNUIMessage({
        app = "keysMinigame",
        show = true,
        data = {
            difficulty = difficulty,
            total = total,
            tolerance = tolerance,
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

-- numbers: 2,
-- preparationTime: 5000,
-- timeout: 10000,
function FD.ui.var(numbers, preparationTime, timeout)
    if LocalPlayer.state.isBusy then return end

    numbers = numbers < 2 and 2 or numbers
    preparationTime = preparationTime == nil and 5000 or preparationTime
    timeout = timeout == nil and 10000 or timeout

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        app = "var",
        show = true,
        data = {
            numbers = numbers,
            preparationTime = preparationTime,
            timeout = timeout,
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

function FD.ui.path(duration, hideAfter, tolerance, pieces)
    if LocalPlayer.state.isBusy then return end

    duration = duration == nil and 5000 or duration
    hideAfter = hideAfter
    tolerance = tolerance

    local p = promise:new()

    FD.utils.setState(true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        app = "pathMinigame",
        show = true,
        data = {
            duration = duration,
            hideAfter = hideAfter,
            tolerance = tolerance,
            pieces = pieces
        }
    })

    Citizen.CreateThread(function()
        result = nil
        while result == nil do
            Wait(0)
        end

        p:resolve(result)
        FD.utils.setState(false)
        result = nil
    end)

    return Citizen.Await(p)
end

function FD.ui.chessPath()

end

-- NUI Callback
RegisterNUICallback('minigameResult', function(data, cb)
    cb(1)

    SetNuiFocus(false, false)
    result = data.passed
end)
