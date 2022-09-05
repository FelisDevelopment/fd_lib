local checks = {}
local listening = false

if GetResourceState('nb-keyevent'):find('start') then
    load(LoadResourceFile('nb-keyevent', 'nb-keyevent.lua'))()
end

local function getRandomKey(tbl)
    local keys = {}

    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end

    return keys[math.random(#keys)]
end

local function loadTextures()
    RequestStreamedTextureDict('fd_textures', true)
    local timeout = GetGameTimer() + 10000

    while not HasStreamedTextureDictLoaded('fd_textures') do
        if GetGameTimer() > timeout then
            return false
        end

        Wait(0)
    end

    return true
end

local function cleaup(instant)
    for _, data in pairs(Config.skillcheck.keys) do
        if data.handle and data.handle.commandhandle == nil then
            for _, handle in pairs(data.handle) do
                RemoveKeyEvent(handle)
                data.handle[_] = nil
            end
        end

        if data.handle and data.handle.commandhandle ~= nil then
            RemoveKeyEvent(data.handle)
            data.handle = nil
        end
    end

    SetTimeout(instant and 0 or 250, function()
        listening = false
    end)

    SetTimeout(300, function()
        if not listening then
            SetStreamedTextureDictAsNoLongerNeeded('fd_textures')
        end
    end)
end

function checks.square(duration, difficulty, minPosition, flipped, reverse)
    local p = promise:new()

    local colors = json.decode(json.encode(Config.skillcheck.colors))

    local sizes = {}
    sizes.width, sizes.height = FD.utils.convertToPixel(128, 128)
    sizes.x, sizes.y = 0.5, 0.585 + (sizes.height / 3)

    local skill = {}
    _, skill.height = FD.utils.convertToPixel(0, difficulty)
    local minPosition, maxPosition = minPosition or math.random(10, 20),
        math.floor((sizes.width - skill.height) * 1000.0)

    if flipped then
        local maxPosition = math.floor(maxPosition)

        if minPosition > maxPosition then
            minPosition = math.floor(minPosition - (math.floor(maxPosition) / 2))
        end

        if minPosition <= 0 then
            minPosition = 10
        end
    end

    skill.position = flipped and
        (math.random(minPosition, math.floor(maxPosition)) / 1000.0) -
        (sizes.width / 2) or (math.random(minPosition, math.floor((sizes.height - skill.height) * 1000.0)) / 1000.0) -
        (sizes.height / 2)

    local cursor = {
        position = flipped and 0.0 + (sizes.x) - (sizes.width / 2) or 0.0 + (sizes.y) - (sizes.height / 2),
        movement = 0.0,
        size = flipped and 1.0 / 1080.0 or 3.0 / 1920.0
    }

    if reverse then
        cursor.position = flipped and 0.0 + (sizes.x) + (sizes.width / 2) or 0.0 + (sizes.y) + (sizes.height / 2)
        skill.position = skill.position * -1
    end

    local gap = {
        start = (sizes.y + skill.position) - (skill.height / 2.0),
        finish = (sizes.y + skill.position + skill.height) - (skill.height / 2.0)
    }

    -- Recalculate gap if shit is drunk sleeping on the side
    if flipped then
        gap = {
            start = (sizes.x + skill.position) - (skill.height / 2.0),
            finish = (sizes.x + skill.position + skill.height) - (skill.height / 2.0)
        }
    end


    local key = tostring(getRandomKey(Config.skillcheck.keys))
    local textures = loadTextures()

    if not textures then
        p:resolve(false)
        return false
    end

    if listening then
        p:resolve(false)
        return false
    end

    local timer = GetGameTimer()
    listening = true

    local tick = 0

    local speed = (100.0 / duration)
    local moveCursor = true

    local function handlePress(pressed)
        local currentPosition = cursor.position + cursor.movement - (cursor.size / 2)
        if moveCursor and listening then
            if currentPosition >= gap.start and
                currentPosition <= gap.finish and pressed == key then
                colors.skill.base = colors.skill.success
                moveCursor = false

                cleaup()
                p:resolve(true)

                return
            end

            colors.skill.base = colors.skill.failed
            moveCursor = false

            cleaup()
            p:resolve(false)

            return
        end
    end

    Citizen.CreateThread(function()
        for num, data in pairs(Config.skillcheck.keys) do
            if data.keys and type(data.keys) == 'table' then
                data.handle = {}
                for _, key in ipairs(data.keys) do
                    data.handle['key_' .. key] = KeyEvent('keyboard', key, function(on)
                        on('justpressed', function()
                            handlePress(num)
                        end)
                    end)
                end
            end

            if data.keys and type(data.keys) == 'string' then
                data.handle = KeyEvent('keyboard', data.keys, function(on)
                    on('justpressed', function()
                        handlePress(num)
                    end)
                end)
            end

            Wait(10)
        end
    end)

    Citizen.CreateThread(function()
        while listening do
            local delta = GetGameTimer() - timer
            timer = GetGameTimer()

            for i = 8, 32 do
                DisableControlAction(0, i, true)
            end
            for i = 140, 143 do
                DisableControlAction(0, i, true)
            end

            DisableControlAction(0, 200, true)

            SetScriptGfxDrawOrder(7)

            -- Draw key to press
            SetTextColour(table.unpack(colors.text))
            SetTextScale(0.0, 1.25)
            SetTextDropshadow(10, 0, 0, 0, 255)
            SetTextOutline()
            SetTextFont(4)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentSubstringPlayerName(key)
            EndTextCommandDisplayText(sizes.x, sizes.y - (sizes.height / 3))

            -- Draw skill background
            DrawSprite("fd_textures", "square_128", sizes.x, sizes.y, sizes.width, sizes.height, 0
                , table.unpack(colors.bg))
            SetScriptGfxDrawOrder(9)
            -- Draw skill indicator
            DrawRect(flipped and sizes.x + skill.position or sizes.x, flipped and sizes.y or sizes.y + skill.position,
                flipped and skill.height or sizes.width,
                flipped and sizes.height or skill.height, table.unpack(colors.skill.base))

            SetScriptGfxDrawOrder(8)
            -- Cursor
            DrawRect(flipped and cursor.position + cursor.movement - (cursor.size / 2) or sizes.x,
                flipped and sizes.y or cursor.position + cursor.movement - (cursor.size / 2),
                flipped and cursor.size or sizes.width,
                flipped and sizes.height or cursor.size,
                table.unpack(colors.cursor))

            SetScriptGfxDrawOrder(1)

            tick = moveCursor and tick + (delta * speed * (reverse and -1 or 1)) or tick
            cursor.movement = tick / 1000.0

            if (cursor.movement >= sizes.height and not flipped) or (cursor.movement >= sizes.width and flipped) or
                (cursor.movement * -1 >= sizes.height and reverse) or
                (cursor.movement * -1 >= sizes.width and reverse and flipped) then
                listening = false
                moveCursor = false
                colors.skill.base = colors.skill.failed

                p:resolve(false)
                cleaup()
            end

            if moveCursor and IsDisabledControlJustReleased(0, 200) then
                cleaup(true)
                p:resolve(false)
            end

            if IsPedRagdoll(cache.get('ped')) then
                cleaup(true)
                p:resolve(false)
            end

            Wait(0)
        end
    end)

    return Citizen.Await(p)
end

function checks.circle(duration, difficulty, minPosition, flipped, reverse)
    local p = promise:new()

    if listening then
        p:resolve(false)

        return
    end


    local function getSkillInfo(skill)
        if skill <= 5 then
            return "circle_skill_1", 7
        end
        if skill <= 7 then
            return "circle_skill_2", 10
        end
        if skill <= 10 then
            return "circle_skill_3", 13
        end
        if skill <= 12 then
            return "circle_skill_4", 15
        end
        if skill <= 15 then
            return "circle_skill_5", 18
        end
        if skill <= 17 then
            return "circle_skill_6", 20
        end
        if skill <= 20 then
            return "circle_skill_7", 25
        end
        if skill > 20 then
            return "circle_skill_8", 30
        end
        if skill >= 30 then
            return "circle_skill_9", 40
        end
    end

    local colors = json.decode(json.encode(Config.skillcheck.colors))

    local sizes = {}
    sizes.width, sizes.height = FD.utils.convertToPixel(128.0, 128.0)
    sizes.x, sizes.y = 0.5, 0.585 + (sizes.height / 3)

    local skill = {}
    skill.rotation = math.random(120, 240) + 0.0
    _, skill.tgap = getSkillInfo(difficulty)
    skill.buffer = 6.0
    skill.gap = ((360 / 128) * math.floor((skill.tgap / 128) * 100)) + skill.rotation + skill.buffer

    local cursor = {}
    rotation = 0.0

    local key = tostring(getRandomKey(Config.skillcheck.keys))
    local speed = (100.0 / duration)
    local tick = 0

    local moveCursor = true
    local isCorrect = skill.rotation + skill.buffer <= (tick < 0 and 360 - tick or tick)

    local textures = loadTextures()

    if not textures then
        return false
    end

    if listening then
        return false
    end

    local timer = GetGameTimer()
    listening = true

    local function handlePress(pressed)
        if moveCursor then
            local currentPosition = (cursor.rotation < 0 and 360 + cursor.rotation or cursor.rotation)
            if pressed == key and currentPosition >= (skill.rotation + skill.buffer) and
                currentPosition <= skill.gap then

                colors.skill.base = colors.skill.success
                moveCursor = false

                cleaup()
                p:resolve(true)

                return
            end

            colors.skill.base = colors.skill.failed
            moveCursor = false

            cleaup()
            p:resolve(false)
            return
        end
    end

    Citizen.CreateThread(function()
        for num, data in pairs(Config.skillcheck.keys) do
            if data.keys and type(data.keys) == 'table' then
                data.handle = {}
                for _, key in ipairs(data.keys) do
                    data.handle['key_' .. key] = KeyEvent('keyboard', key, function(on)
                        on('justpressed', function()
                            handlePress(num)
                        end)
                    end)
                end
            end

            if data.keys and type(data.keys) == 'string' then
                data.handle = KeyEvent('keyboard', data.keys, function(on)
                    on('justpressed', function()
                        handlePress(num)
                    end)
                end)
            end

            Wait(10)
        end
    end)

    Citizen.CreateThread(function()
        while listening do
            local delta = GetGameTimer() - timer
            timer = GetGameTimer()

            for i = 8, 32 do
                DisableControlAction(0, i, true)
            end
            for i = 140, 143 do
                DisableControlAction(0, i, true)
            end

            DisableControlAction(0, 200, true)

            tick = moveCursor and tick + (delta * speed * (reverse and -1 or 1)) or tick
            cursor.rotation = tick / 100 * 360

            SetScriptGfxDrawOrder(7)

            -- Draw key to press
            SetTextColour(255, 255, 255, 255)
            SetTextScale(0.0, 1.25)
            SetTextDropshadow(10, 0, 0, 0, 255)
            SetTextOutline()
            SetTextFont(4)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentSubstringPlayerName(key)
            EndTextCommandDisplayText(sizes.x, sizes.y - (sizes.height / 3))

            -- Draw skill background
            DrawSprite("fd_textures", "circle_128", sizes.x, sizes.y, sizes.width, sizes.height, 0, table.unpack(colors.bg))

            SetScriptGfxDrawOrder(9)
            -- Draw skill indicator
            DrawSprite("fd_textures", getSkillInfo(difficulty), sizes.x, sizes.y, sizes.width, sizes.height,
                skill.rotation, table.unpack(colors.skill.base))

            SetScriptGfxDrawOrder(8)
            -- cursor
            DrawSprite("fd_textures", "circle_cursor", sizes.x, sizes.y, sizes.width, sizes.height, cursor.rotation,
                table.unpack(colors.cursor))

            SetScriptGfxDrawOrder(1)

            if moveCursor and IsDisabledControlJustReleased(0, 200) then
                cleaup(true)
                p:resolve(false)
            end

            if (not reverse and tick >= 100 and not isCorrect) or (reverse and tick <= -100 and not isCorrect) then
                cleaup(true)
                p:resolve(false)
            end

            if tick > 100 or tick < -100 then
                cleaup(true)
                p:resolve(false)
            end

            if IsPedRagdoll(cache.get('ped')) then
                cleaup(true)
                p:resolve(false)
            end

            Wait(0)
        end
    end)

    return Citizen.Await(p)
end

function FD.ui.sc(cycles, settings)
    if not GetResourceState('nb-keyevent'):find('started') then
        return FD.logger.err('nb-keyvent is not started, you cannot use skillcheck.')
    end

    if LocalPlayer.state.isBusy then return end

    if listening then
        return
    end

    local p = promise:new()

    FD.utils.setState(true)

    cycles = cycles or 1

    for i = 1, cycles do
        local temp = settings

        if settings and type(settings[i]) == 'table' then
            temp = settings[i]
        end

        local minigame = temp?.minigame and (temp?.minigame == 'randomise' and (math.random(0, 1) == 1 and 'square' or 'circle') or temp?.minigame) or Config.skillcheck?.settings.minigame

        local duration = type(temp?.duration) == 'table' and math.random(table.unpack(temp?.duration)) or (type(temp?.duration) == 'number' and temp.duration or math.random(table.unpack(Config.skillcheck?.settings.duration)))
        local difficulty = type(temp?.difficulty) == 'table' and math.random(table.unpack(temp?.difficulty)) or (type(temp?.difficulty) == 'number' and temp.difficulty or math.random(table.unpack(Config.skillcheck?.settings.difficulty)))
        local minPosition = type(temp?.minPosition) == 'table' and math.random(table.unpack(temp?.minPosition)) or (type(temp?.minPosition) == 'number' and temp.minPosition or math.random(table.unpack(Config.skillcheck?.settings.minPosition)))
        local flipped = (temp?.flipped ~= nil and type(temp?.flipped) == 'boolean') and temp?.flipped or (temp?.flipped == 'randomise' and (math.random(0, 1) == 1 and true or false) or (Config.skillcheck?.settings.flipped == 'randomise' and (math.random(0, 1) == 1 and true or false) or Config.skillcheck?.settings.flipped))
        local reverse = (temp?.reverse ~= nil and type(temp?.reverse) == 'boolean') and temp?.reverse or (temp?.reverse == 'randomise' and (math.random(0, 1) == 1 and true or false) or (Config.skillcheck?.settings.reverse == 'randomise' and (math.random(0, 1) == 1 and true or false) or Config.skillcheck?.settings.reverse))

        result = checks[minigame](duration, difficulty, minPosition, flipped, reverse)

        if not result then
            FD.utils.setState(false)
            p:resolve(false)
            return
        end

        Wait(500)
    end

    FD.utils.setState(false)
    p:resolve(result)

    return Citizen.Await(p)
end
