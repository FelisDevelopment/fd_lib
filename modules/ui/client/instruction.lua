function FD.ui.showInstruction(key, label)
    local instruction = {
        key = key,
        label = label
    }
    if type(key) == 'table' then
        instruction = key
    end

    SendNUIMessage({
        app = 'instruction',
        show = true,
        data = instruction
    })
end

function FD.ui.hideInstruction(key, label)
    local instruction = {
        key = key,
        label = label
    }
    if type(key) == 'table' then
        instruction = key
    end

    SendNUIMessage({
        app = 'instruction',
        show = false,
        data = instruction
    })
end
