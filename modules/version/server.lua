-- yoink, thanks to https://github.com/overextended/ox_lib/blob/master/resource/version/server.lua

function FD.version.check(self, repository, isKeyMaster)
    local resource = GetInvokingResource() or GetCurrentResourceName()
    local version = GetResourceMetadata(resource, 'version', 0)

    if version then
        version = version:match("%d%.%d+%.%d+")
    end

    if not version then
        return print(("^1This resource doesn't have version provided in '%s' resources manifest.^0"):format(resource))
    end

    PerformHttpRequest(("https://api.github.com/repos/%s/releases/latest"):format(repository),
        function(code, response)
            if code ~= 200 then
                return print(("^1%s repository is not available. Is it private? Or no releases yet?^0"):format(repository))
            end

            response = json.decode(response)

            local remoteVersion = response.tag_name:match("%d%.%d+%.%d+")
            if not remoteVersion then
                return print(("^1%s doesn't have any releases."):format(repository))
            end

            if remoteVersion == version then return end

            local vMajor, vMinor = string.strsplit('.', version, 2)
            local rMajor, rMinor = string.strsplit('.', remoteVersion, 2)

            if tonumber(vMajor) < tonumber(rMajor) or tonumber(vMinor) < tonumber(rMinor) then
                if isKeyMaster then
                    return print((
                        "^3An update is available for %s (version: %s, new version:%s)\r\nPlease download update from keymaster.^0"
                        ):
                        format(resource, version, remoteVersion))
                end

                return print(("^3An update is available for %s (version: %s, new version:%s)\r\nDownload from: %s^0"):
                    format(resource,
                        version,
                        remoteVersion,
                        response.html_url))
            end
        end, "GET")
end

FD.version:check('FelisDevelopment/fd_lib', true)
