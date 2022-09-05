local openResult, forceHide, partialHide = nil, false, false
local theme = GetResourceKvpString('fd_theme') or GetConvar("fd:theme", Config.defaultTheme)

function FD.ui.isUiOpen()
    openResult = nil

    local p = promise:new()

    SendNUIMessage({
        isOpen = true
    })

    Citizen.CreateThread(function()
        while openResult == nil do
            Citizen.Wait(100)
        end

        p:resolve(openResult)

        openResult = nil
    end)

    return Citizen.Await(p)
end

function FD.ui.getTheme()
    return theme
end

function FD.ui.setTheme(newTheme)
    theme = newTheme

    SendNUIMessage({
        event = "updateTheme",
        data = {
            theme = theme
        }
    })
end

function FD.ui.getAvailableThemes()
    return Config.availableThemes
end

function FD.ui.hideIndicators(bool)
    SendNUIMessage({
        event = "toggleIndicators",
        data = {
            hide = bool
        }
    })
end

function FD.ui.overrideLocaleKeys(data)
    SendNUIMessage({
        event = "overrideLocaleKeys",
        data = {
            locale = data
        }
    })

    for key, value in pairs(data) do
        setLocaleKey(key, value)
    end
end

function FD.ui.forceHide(bool)
    forceHide = bool
end

function FD.ui.isForceHidden()
    return forceHide
end

RegisterNUICallback('openCheckCallback', function(data, cb)
    cb(1)

    openResult = data
end)

RegisterNUICallback('initializeTheme', function(data, cb)
    cb(theme)
end)

Citizen.CreateThread(function()
    while true do
        if IsPauseMenuActive() or forceHide then
            SendNUIMessage({
                event = "uiShown",
                data = {
                    shown = false
                }
            })
        else
            SendNUIMessage({
                event = "uiShown",
                data = {
                    shown = true
                }
            })
        end

        Wait(1000)
    end
end)

if Config.allowThemeChange == "true" then
    RegisterCommand('fd_theme', function()
        local selections = {}

        for _, item in pairs(FD.ui.getAvailableThemes()) do
            table.insert(selections, {
                label = item,
                value = item
            })
        end

        local result = FD.ui.dialog({
            header = locale("settings"),
            inputs = {
                {
                    type = 'select',
                    value = FD.ui.getTheme(),
                    options = {
                        name = 'theme',
                        label = locale("choose_theme"),
                        selection = selections,
                    },
                }
            }
        })

        if result[1]?.value then
            FD.ui.setTheme(result[1].value)

            SetResourceKvp('fd_theme', result[1].value)
        end
    end, false)
end
