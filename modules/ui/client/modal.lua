local modal = {
    result = nil
}

function FD.ui.modal(header, content, settings)
    if LocalPlayer.state.isBusy then return end

    local p = promise:new()

    FD.utils.setState(true)
    SendNUIMessage({
        app = 'modal',
        show = true,
        data = {
            header = header,
            content = content,
            submit = settings?.submit or true,
            cancel = settings?.cancel or true,
            settings = settings
        }
    })

    Citizen.CreateThread(function()
        while modal.result == nil do
            Citizen.Wait(100)
        end

        FD.utils.setState(false)
        p:resolve(modal.result)

        modal.result = nil
    end)

    return Citizen.Await(p)
end

-- NUI Callbacks
RegisterNUICallback('modalResult', function(data, cb)
    modal.result = data or false

    cb('ok')
end)
