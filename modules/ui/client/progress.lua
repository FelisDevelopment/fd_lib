local progress = nil

local function createProp(prop)
	FD.utils.requestModel(prop.model)
	local coords = GetEntityCoords(cache.get('ped'))
	local object = CreateObject(prop.model, coords.x, coords.y, coords.z, true, true, true)
	AttachEntityToEntity(object, cache.get('ped'), GetPedBoneIndex(cache.get('ped'), prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, 0, true)
	return object
end

local function cleanup(data, beforeEnd)
    progress = nil

    FD.utils.disableControls(false)
    FD.utils.setState(false)

    if beforeEnd then
        beforeEnd()
    end

    if data.anim then
		ClearPedTasks(cache.get('ped'))
	end

	if data.prop then
		local n = #data.prop
		for i = 1, n > 0 and n or 1 do
			local prop = data['prop'..i]

			if prop then
				DetachEntity(prop)
				DeleteEntity(prop)
			end
		end
	end
end

local function start(data, beforeStart, beforeEnd)
    if beforeStart then
        beforeStart()
    end

    FD.utils.setState(true)
    progress = data

    local p = promise:new()
    local currentProgress, waitTime = 0, data.duration / 100

    if data.anim then
		if data.anim.dict then
			FD.utils.requestAnimDict(data.anim.dict)

			TaskPlayAnim(cache.get('ped'), data.anim.dict, data.anim.clip, data.anim.blendIn or 3.0, data.anim.blendOut or 1.0, data.anim.duration or -1, data.anim.flag or 49, data.anim.playbackRate or 0, data.anim.lockX, data.anim.lockY, data.anim.lockZ)
			data.anim = true
		elseif data.anim.scenario then
			TaskStartScenarioInPlace(cache.get('ped'), data.anim.scenario, 0, data.anim.playEnter ~= nil and data.anim.playEnter or true)
			data.anim = true
		end
	end

    if data.prop then
		if data.prop.model then
			data.prop1 = createProp(data.prop)
		else
			for i = 1, #data.prop do
				local prop = data.prop[i]

				if prop then
					data['prop'..i] = createProp(prop)
				end
			end
		end
	end

   Citizen.CreateThread(function()
        while progress do
            currentProgress += 1

            if currentProgress >= 100 then
                cleanup(data, beforeEnd)

                p:resolve(currentProgress)
                return
            end

            if data.inBetween then
                data.inBetween(currentProgress)
            end

            if IsPedRagdoll(cache.get('ped')) then
                cleanup(data, beforeEnd)
                p:resolve(p:resolve(currentProgress))
            end

            Wait(waitTime)
        end

        if progress == false then
            p:resolve(currentProgress)

            SendNUIMessage({
                app = data.component == 'circle' and 'progressCircle' or 'progressBar',
                show = 'cancel',
                data = {}
            })

            cleanup(data, beforeEnd)
        end
   end)

   if data.controls then
        FD.utils.disableControls(data.controls)
   end

    return p
end


function FD.ui.progressBar(data, deathCallback, beforeStart, beforeEnd)
    while progress ~= nil do Wait(100) end

    if data?.useWhileDead or not IsEntityDead(PlayerPedId()) or (deathCallback ~= nil and not deathCallback()) then
        SendNUIMessage({
            app = 'progressBar',
            show = true,
            data = data
        })

		return Citizen.Await(start(data, beforeStart, beforeEnd))
	end

    return 0
end

function FD.ui.progressCircle(data, deathCallback, beforeStart, beforeEnd)
    while progress ~= nil do Wait(100) end

    if data?.useWhileDead or not IsEntityDead(PlayerPedId()) or (deathCallback ~= nil and not deathCallback()) then
        data.component = 'circle'

        SendNUIMessage({
            app = 'progressCircle',
            show = true,
            data = data
        })

		return Citizen.Await(start(data, beforeStart, beforeEnd))
	end

    return 0
end

function FD.ui.cancelProgress()
    if not progress then return end

    if not progress?.canCancel then
		print("Progress bar cannot be cancelled")
	end

	if progress?.canCancel then
        progress = false
    end
end

function FD.ui.progressActive()
	return progress and true
end

RegisterCommand('cancelprogress', FD.ui.cancelProgress, false)

RegisterKeyMapping('cancelprogress', locale('cancel_progress'), 'keyboard', 'x')
