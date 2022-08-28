FD.logger = {}

local logColors = {
    ['Info'] = '7',
    ['Error'] = '1',
    ['Warning'] = '3',
}

local log = nil
if IsDuplicityVersion() then
    log = function(level, name, message)
        Citizen.Trace('^4[' ..
            os.date('%c') .. '] ^2[' .. name .. '] ^' .. logColors[level] .. '[' .. level ..
            '] ' .. tostring(message) .. '\n')
    end
else
    log = function(level, name, message)
        Citizen.Trace('[' .. name .. '] [' .. level .. '] ' .. tostring(message) .. '\n')
    end
end

function FD.logger.info(message)
    log('Info', GetInvokingResource() or GetCurrentResourceName(), message)
end

function FD.logger.err(message)
    log('Error', GetInvokingResource() or GetCurrentResourceName(), message)
end

function FD.logger.warn(message)
    log('Warning', GetInvokingResource() or GetCurrentResourceName(), message)
end
