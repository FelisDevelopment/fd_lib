local inprogress = nil

local function close()
    inprogress = nil

    FD.utils.setState(false)
    SendNUIMessage({
        app = 'kbdAction',
        show = false,
        data = nil
    })
end

function FD.ui.kbdAction(timeout, label, labelClasses)
    if LocalPlayer.state.isBusy then return end

    while inprogress ~= nil do Wait(100) end

    local p = promise:new()

    inprogress = true
    FD.utils.setState(true)

    SendNUIMessage({
        app = 'kbdAction',
        show = true,
        data = {
            label = label,
            timeout = timeout,
            labelClasses = labelClasses
        }
    })

    Citizen.CreateThread(function()
        local start = GetGameTimer()

        while inprogress do
            if GetGameTimer() - start > timeout then
                close()

                p:resolve(false)
                return
            end

            if IsControlJustReleased(0, 246) then
                close()

                p:resolve(true)
                return
            end

            if IsControlJustReleased(0, 249) then
                close()

                p:resolve(false)
                return
            end

            Wait(0)
        end
    end)

    return Citizen.Await(p)
end
