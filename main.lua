FD = {}
Config = {}

function getModule(module)
    if not FD[module] then
        return print(("^1Error: %s module doesn't exist."):format(module))
    end
    return FD[module]
end

exports('getModule', getModule)
