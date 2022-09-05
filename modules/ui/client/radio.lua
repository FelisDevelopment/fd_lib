local function close(data, cb)
    if cb ~= nil then
        cb(1)
    end

    FD.ui.radioToggle(false)
    FD.utils.toggleFocus(false, false, false)
end

function FD.ui.radioToggle(open, keepInput)
    if LocalPlayer.state.isBusy and open then return end

    FD.utils.setState(open)

    SendNUIMessage({
        app = 'radio',
        show = open,
        data = {
            keepInput = keepInput or false
        }
    })

    if keepInput then
        FD.utils.disableControls({
            enableMouse = false,
            enableMovement = true,
            enableCarMovement = true,
            enableCombat = false,
            enablePause = false
        })
    end

    if not open and controlsLoop then
        FD.utils.disableControls(false)
    end

    if not open then
        FD.utils.toggleFocus(false, false, false)
        TriggerEvent('radio:close')
    end
end

function FD.ui.setRadioTheme(theme)
    SendNUIMessage({
        app = 'radio',
        show = 'changeTheme',
        data = {
            theme = theme
        }
    })
end

function FD.ui.setRadioValues(data)
    SendNUIMessage({
        app = 'radio',
        show = 'updateValues',
        data = data
    })
end

RegisterNUICallback('closeRadio', close)
