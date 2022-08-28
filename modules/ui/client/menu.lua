local menus = {
    registered = {},
    temp = {}
}
local currentMenu = nil

function FD.ui.registerMenu(menu, temp)
    temp = temp and 'temp' or 'registered'

    for k, v in pairs(menu) do
        if type(k) == 'number' then
            menus[temp][v.id] = v
        else
            menus[temp][menu.id] = menu

            break
        end
    end
end

function FD.ui.showMenu(id)
    if type(id) == 'table' then
        FD.ui.registerMenu(id, true)

        local firstId = nil

        for k, v in pairs(id) do
            if type(k) == 'number' then
                firstId = v.id
            else
                firstId = id.id

                break
            end
        end

        return FD.ui.showMenu(firstId)
    end

    if not menus.registered[id] and not menus.temp[id] then return print(('No menu with this id(%s) found.'):format(id)) end

    local data = menus.registered[id] or menus.temp[id]

    currentMenu = id

    local mouseEnabled = data.controls?.nuiMouseEnabled ~= nil and data.controls.nuiMouseEnabled or true

    SetNuiFocus(true, mouseEnabled)
    SetNuiFocusKeepInput(false)

    FD.utils.disableControls(data.controls)

    FD.utils.setState(true)

    SendNUIMessage({
        app = 'menu',
        show = true,
        data = table.clone(data)
    })

    if type(data.controls) == 'table' then
        SetNuiFocusKeepInput(true)
    end
end

local function closeMenu(_, cb, onExit)
    FD.utils.setState(false)

    if cb then cb(1) end

    local menu = menus.registered[currentMenu] or menus.temp[currentMenu]

    if (cb or onExit) and menu.onExit then menu.onExit() end

    SetNuiFocus(false, false);

    SetNuiFocusKeepInput(false)
    currentMenu = nil

    FD.utils.disableControls(false)

    menus.temp = {}

    SendNUIMessage({
        app = 'menu',
        show = false,
        data = false
    })
end

-- NUI Callbacks
RegisterNUICallback('processClick', function(data, cb)
    cb(1)
    local menu = menus.registered[currentMenu] or menus.temp[currentMenu]
    local item = menu.items[data.index]


    if item.event then TriggerEvent(item.event, FD.utils.unpack(item.args)) end
    if item.serverEvent then TriggerServerEvent(item.serverEvent, FD.utils.unpack(item.args)) end
    if item.qbCommand then TriggerServerEvent('QBCore:CallCommand', item.qbCommand, FD.utils.unpack(item.args)) end
    if item.command then ExecuteCommand(item.command) end
    if item.action then item.action(FD.utils.unpack(item.args)) end

    if type(item.close) == "boolean" and not item.close then return end

    closeMenu(nil, cb, menu.onExit)
end)

RegisterNUICallback('closeMenu', closeMenu)

RegisterNUICallback('openSubMenu', function(data, cb)
    cb(1)

    FD.ui.showMenu(data.id)
end)

RegisterNUICallback('processListItemChange', function(data, cb)
    cb(1)

    local menu = menus.registered[currentMenu] or menus.temp[currentMenu]
    local item = menu.items[data.index]

    if item.onChange?.event then TriggerEvent(item.onChange?.event, item.values[data.current], item.values[data.old], data.index, data) end
    if item.onChange?.serverEvent then TriggerServerEvent(item.onChange?.serverEvent, item.values[data.current], item.values[data.old], data.index, data) end
    if item.onChange?.qbCommand then TriggerServerEvent('QBCore:CallCommand', item.onChange?.qbCommand, item.values[data.current], item.values[data.old], data.index, data) end
    if item.onChange?.command then ExecuteCommand(item.onChange?.command) end
    if item.onChange?.action then item.onChange?.action(item.values[data.current], item.values[data.old], data.index, data) end
end)

RegisterNUICallback('processActiveItemChange', function(data, cb)
    cb(1)

    local menu = menus.registered[currentMenu] or menus.temp[currentMenu]

    if menu.onItemChange?.event then TriggerEvent(menu.onItemChange?.event, data.current, data.old) end
    if menu.onItemChange?.serverEvent then TriggerServerEvent(menu.onItemChange?.serverEvent, data.current, data.old) end
    if menu.onItemChange?.qbCommand then TriggerServerEvent('QBCore:CallCommand', menu.onItemChange?.qbCommand, data.current, data.old) end
    if menu.onItemChange?.command then ExecuteCommand(menu.onItemChange?.command) end
    if menu.onItemChange?.action then menu.onItemChange?.action(data.current, data.old) end

end)
