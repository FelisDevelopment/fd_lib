Citizen.CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            SendNUIMessage({
                event = "isMinimapShown",
                data = {
                    isShown = IsMinimapRendering()
                }
            })
        end

        Wait(1000)
    end
end)

function FD.ui.notification(data)
    data.position = data.position or Config.defaultNotificationPosition

    SendNUIMessage({
        app = 'notifications',
        show = true,
        data = data
    })
end
