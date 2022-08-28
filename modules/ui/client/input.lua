local dialogs = {
    result = nil,
    registered = {}
}

-- Various UI functions
function FD.ui.registerDialog(id, data)
    if next(dialogs.registered[id]) then
        print(("Dialog with id %s already registered, please use unique name!"):format(id))
        return false
    end

    dialogs.registered[id] = data

    return true
end

function FD.ui.dialog(id, data)
    if LocalPlayer.state.isBusy then return end

    dialogs.result = nil

    if not dialogs.registered[id] and type(id) ~= 'table' then
        return false
    end

    local p = promise:new()
    FD.utils.setState(true)

    SendNUIMessage({
        app = 'input',
        show = true,
        data = dialogs.registered[id] or id
    })

    Citizen.CreateThread(function()
        while dialogs.result == nil do
            Citizen.Wait(100)
        end

        FD.utils.setState(false)
        p:resolve(dialogs.result)

        dialogs.result = nil
    end)

    return Citizen.Await(p)
end

-- Various local functions
function filterResponseTrash(response)
    if response.cancelled then
        return false
    end

    for _, data in pairs(response) do
        if data?.value == nil then
            response[_] = ''
        else
            response[_] = data.value
        end
    end

    return response
end

-- Various UI Callbacks
RegisterNUICallback('dialogResult', function(data, cb)
    dialogs.result = filterResponseTrash(data)

    cb('ok')
end)
