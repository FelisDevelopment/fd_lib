function FD.ui.indicator(o)
    local self = o or {}

    self.uuid = FD.utils.uuid()
    self.shown = false
    self.lastValues = {}

    SendNUIMessage({
        app = 'indicators',
        show = 'register',
        data = self
    })

    function self.show()
        if not self.shown or (self.notification or self.timer) then
            SendNUIMessage({
                app = 'indicators',
                show = true,
                data = {
                    uuid = self.uuid
                }
            })

            self.shown = true
        end
    end

    function self.update(key, value)
        if self.lastValues[key] ~= value then
            SendNUIMessage({
                app = 'indicators',
                show = 'update',
                data = {
                    uuid = self.uuid,
                    key = key,
                    value = value
                }
            })

            self.lastValues[key] = value
        end
    end

    function self.hide()
        if self.shown then
            SendNUIMessage({
                app = 'indicators',
                show = false,
                data = {
                    uuid = self.uuid
                }
            })
        end

        self.shown = false
    end

    function self.delete()
        SendNUIMessage({
            app = 'indicators',
            show = 'delete',
            data = {
                uuid = self.uuid
            }
        })
    end

    function self.isShown()
        return self.shown
    end

    function self.getLastValue(key)
        return self.lastValues[key]
    end

    return self
end
