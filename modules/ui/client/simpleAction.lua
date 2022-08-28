function FD.ui.simpleAction(button, text, description, settings)
    if LocalPlayer.state.isBusy then return end

    if button and text then
        FD.utils.setState(true)

        return SendNUIMessage({
            app = 'simpleAction',
            show = true,
            data = {
                button = button,
                text = text,
                description = description,
                settings = settings
            }
        })
    end

    FD.utils.setState(false)
    return SendNUIMessage({
        app = 'simpleAction',
        show = false
    })
end

function FD.ui.hideSimpleAction()
    FD.utils.setState(false)

    return SendNUIMessage({
        app = 'simpleAction',
        show = false
    })
end
