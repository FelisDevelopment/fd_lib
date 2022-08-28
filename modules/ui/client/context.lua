local current

local function close()
    SendNUIMessage({
        app = 'context',
        show = false
    })
end

function FD.ui.context(data, reopen)
    local open = FD.ui.isUiOpen()

    if open?.isOpen and open?.app == 'context' and not reopen then
        return close()
    end

    current = data

    SendNUIMessage({
        app = 'context',
        show = true,
        data = data
    })
end

-- Various UI Callbacks
RegisterNUICallback('contextButtonTriggered', function(data, cb)
    cb(1)

    local button = current?.buttons?[data.index]

    if button.close then
        close()
    end

    if button.event then TriggerEvent(button.event, FD.utils.unpack(button.args)) end
    if button.serverEvent then TriggerServerEvent(button.serverEvent, FD.utils.unpack(button.args)) end
    if button.qbCommand then TriggerServerEvent('QBCore:CallCommand', button.qbCommand, FD.utils.unpack(button.args)) end
    if button.command then ExecuteCommand(button.command) end
    if button.action then button.action(FD.utils.unpack(button.args)) end
end)

RegisterNUICallback('tabCloseTriggered', function(data, cb)
    cb(1)

    local tab = current?.tabs?[data.index]

    tab = tab?.close or {}

    if tab.close then
        close()
    end

    if tab.event then TriggerEvent(tab.event, FD.utils.unpack(tab.args)) end
    if tab.serverEvent then TriggerServerEvent(tab.serverEvent, FD.utils.unpack(tab.args)) end
    if tab.qbCommand then TriggerServerEvent('QBCore:CallCommand', tab.qbCommand, FD.utils.unpack(tab.args)) end
    if tab.command then ExecuteCommand(tab.command) end
    if tab.action then tab.action(FD.utils.unpack(tab.args)) end
end)

RegisterNUICallback('sectionSubmit', function(data, cb)
    cb(1)

    local tab = nil

    if type(data.tab) == 'string' then
        tab = FD.table.find_if(current.tabs, function(value, index)
            return (value?.id or 'unknown') == data.tab
        end)
    else
        tab = current?.tabs[data.tab]
    end

    if not tab then
        return
    end

    local section = tab.sections[data.section]
    local response = filterResponseTrash(data.data)

    section = section?.submit or {}

    if section.close then
        close()
    end

    if section.event then TriggerEvent(section.event, response, FD.utils.unpack(section.args)) end
    if section.serverEvent then TriggerServerEvent(section.serverEvent, response, FD.utils.unpack(section.args)) end
    if section.qbCommand then TriggerServerEvent('QBCore:CallCommand', section.qbCommand, response, FD.utils.unpack(section.args)) end
    if section.command then ExecuteCommand(section.command) end
    if section.action then section.action(response, FD.utils.unpack(section.args)) end
end)
