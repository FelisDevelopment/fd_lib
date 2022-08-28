RegisterNUICallback('getSafezoneSize', function(_, cb)
    local safezoneSize = GetSafeZoneSize()
    local resX, resY = GetActiveScreenResolution()
    local aspect = GetAspectRatio(false)
    local scaleX = 1.0 / resX
    local scaleY = 1.0 / resY

    local posX = -0.0045
    local posY = 0.002

    local hud = nil

    if GetResourceState('fd_hud'):find('started') then
        hud = exports.fd_hud:getMinimapOffsets()

        if hud then
            posX = hud.posX
            posY = hud.posY
        end
    end

    if tonumber(string.format("%.2f", aspect)) >= 2.3 then
        posX = hud?.wide?.posX ~= nil and hud?.wide?.posX or -0.0045
        posY = hud?.wide?.posY ~= nil and hud?.wide?.posY or 0.002
    end

    local height = hud?.height and (hud?.height * -1) or -0.18888

    local minimap = {}

    SetScriptGfxAlign(string.byte(hud?.circle and "I" or "L"), string.byte(hud?.circle and "I" or "B"))
    local minimapLeftX, minimapTopY = GetScriptGfxPosition(posX, posY + (height))
    ResetScriptGfxAlign()

    local widthFactor = 4
    local heightFactor = 5.674

    if hud?.circle then
        widthFactor = 4.2
        heightFactor = 4.974
    end

    minimap.top = resY * (minimapTopY)
    minimap.left = resX * (minimapLeftX)
    minimap.rawWidth = scaleX * (resX / (widthFactor * aspect))
    minimap.width = resX * (minimap.rawWidth)
    minimap.rawHeight = scaleY * (resY / (heightFactor))
    minimap.height = resY * (minimap.rawHeight)
    minimap.right = resX * (minimapLeftX + minimap.rawWidth)
    minimap.bottom = resY * (minimapTopY + minimap.rawHeight)

    if minimap.left < 0 then
        minimap.left = 0
    end

    cb({
        x = ((resX / 100) * (((1.0 - safezoneSize) * 0.5) * 100.0)),
        y = ((resY / 100) * (((1.0 - safezoneSize) * 0.5) * 100.0)),
        minimap = minimap
    })
end)
