function FD.ui.setClipboard(text)
    SendNUIMessage({
        app = 'clipboard',
        show = true,
        data = json.encode(text)
    })
end

-- NUI Callback
RegisterNUICallback('copied', function(data, cb)
    cb('ok')

    if data.copied then
        return
    end

    return
end)
