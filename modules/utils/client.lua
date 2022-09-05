controlsLoop = nil

function FD.utils.disableControls(controls)
    if not controls then
        controlsLoop = false
        return
    end

    if type(controls) == 'table' then
        Citizen.CreateThread(function()
            controlsLoop = true

            while controlsLoop do
                Citizen.Wait(0)
                if not controls.enablePause then
                    DisableControlAction(0, 199, true)
                    DisableControlAction(0, 200, true)
                    DisableControlAction(0, 322, true)
                end

                if not controls.enableMouse then
                    DisableControlAction(0, 1, true);
                    DisableControlAction(0, 2, true);
                    DisableControlAction(0, 106, true);
                end

                if not controls.enableMovement then
                    DisableControlAction(0, 30, true)
                    DisableControlAction(0, 31, true)
                    DisableControlAction(0, 36, true)
                    DisableControlAction(0, 21, true)
                end

                if not controls.enableCarMovement then
                    DisableControlAction(0, 63, true)
                    DisableControlAction(0, 64, true)
                    DisableControlAction(0, 71, true)
                    DisableControlAction(0, 72, true)
                    DisableControlAction(0, 75, true)
                end

                if not controls.enableCombat then
                    DisablePlayerFiring(PlayerId(), true)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 25, true)
                    DisableControlAction(1, 37, true)
                    DisableControlAction(0, 47, true)
                    DisableControlAction(0, 58, true)
                    DisableControlAction(0, 140, true)
                    DisableControlAction(0, 141, true)
                    DisableControlAction(0, 142, true)
                    DisableControlAction(0, 143, true)
                    DisableControlAction(0, 263, true)
                    DisableControlAction(0, 264, true)
                    DisableControlAction(0, 257, true)
                end
            end
        end)
    end
end

function FD.utils.setState(bool)
    LocalPlayer.state:set("inv_busy", bool, true)
    LocalPlayer.state:set("isBusy", bool, true)
end

function FD.utils.toggleFocus(isFocused, cursorToggle, keepInput)
    SetNuiFocus(isFocused, cursorToggle)

    if cursorToggle then
        SetCursorLocation(0.5, 0.5)
    end

    SetNuiFocusKeepInput(keepInput)
end

RegisterNUICallback('enableFocus', function(data, cb)
    FD.utils.toggleFocus(data.isFocused or false, data.cursorToggle or false, data.keepInput or false)

    cb('ok')
end)
