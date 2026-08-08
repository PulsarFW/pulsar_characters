CreateThread(function()
	while GetIsLoadingScreenActive() do
		Wait(0)
	end
	SendNUIMessage({
		type = "APP_SHOW",
	})
end)

local config = load(LoadResourceFile(GetCurrentResourceName(), "config/shared.lua"))()

local loadTo = 0
function loadModel(model)
	RequestModel(model)
	loadTo = 0
	while not HasModelLoaded(model) and loadTo < 500 do
		loadTo += 1
		Wait(100)
	end
end

local preview = config.Scenes.select.preview
local peds = {}

function getPreviewSlot(k)
	return preview["char" .. k]
end

RegisterNUICallback("GetData", function(data, cb)
	cb("ok")

	while plsr.State.flags.ID == nil do
		Wait(1)
	end

	for k, v in ipairs(peds) do
		DeleteEntity(v)
	end

	plsr.Callbacks:ServerCallback("Characters:GetServerData", {}, function(serverData)
		SendNUIMessage({
			type = "LOADING_SHOW",
			data = { message = "Getting Character Data" },
		})

		FadeOutWithTimeout(500)

		plsr.Callbacks:ServerCallback("Characters:GetCharacters", {}, function(characters, characterLimit)
			local sceneCoords = config.Scenes.select.pedCoords

			local ped = PlayerPedId()
			SetEntityCoords(ped, sceneCoords.x, sceneCoords.y, sceneCoords.z, 0.0, 0.0, 0.0, false)
			FreezeEntityPosition(ped, true)
			SetEntityVisible(ped, false)
			SetPlayerVisibleLocally(ped, false)

			local interior = GetInteriorFromEntity(ped)
			if interior ~= 0 then
				local roomHash = GetRoomKeyFromEntity(ped)
				ForceRoomForEntity(ped, interior, roomHash)
			end

			Wait(250)

			local sceneCam = config.Scenes.select.camera
			local cam2 = CreateCamWithParams(
				"DEFAULT_SCRIPTED_CAMERA",
				sceneCam.coord.x,
				sceneCam.coord.y,
				sceneCam.coord.z,
				sceneCam.pitch,
				sceneCam.roll,
				sceneCam.coord.w,
				sceneCam.fov,
				false,
				0
			)
			SetCamActiveWithInterp(cam2, cam, 1000, true, true)
			RenderScriptCams(true, false, 1, true, true)

			TriggerScreenblurFadeOut(500)
			cam = cam2

			for k, v in ipairs(characters) do
				local slot = getPreviewSlot(k)
				if slot then
					local coord = slot.coord

					if v.Preview then
						loadModel(GetHashKey(v.Preview.model))
						local ped = CreatePed(
							5,
							GetHashKey(v.Preview.model),
							coord[1],
							coord[2],
							coord[3],
							coord[4],
							false,
							true
						)

						local t = 0
						while not DoesEntityExist(ped) and t < 2500 do
							t += 1
							Wait(1)
						end

						if DoesEntityExist(ped) then
							SetEntityCoords(ped, coord[1], coord[2], coord[3], 0.0, 0.0, 0.0, false)
							FreezeEntityPosition(ped, true)
							plsr.Ped:Preview(ped, tonumber(v.Gender), v.Preview, false, v.GangChain)
							plsr.Animations.Ped:PlayEmote(ped, slot.anim, true)

							table.insert(peds, ped)
						end
					else
						loadModel(tonumber(v.Gender) == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`)
						local ped = CreatePed(
							5,
							tonumber(v.Gender) == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`,
							coord[1],
							coord[2],
							coord[3],
							coord[4],
							false,
							true
						)

						local t = 0
						while not DoesEntityExist(ped) and t < 2500 do
							t += 1
							Wait(1)
						end

						if DoesEntityExist(ped) then
							SetEntityCoords(ped, coord[1], coord[2], coord[3], 0.0, 0.0, 0.0, false)
							FreezeEntityPosition(ped, true)
							plsr.Animations.Ped:PlayEmote(ped, slot.anim, true)

							table.insert(peds, ped)
						end
					end
				end
			end

			SendNUIMessage({
				type = "SET_DATA",
				data = {
					changelog = serverData.changelog,
					motd = serverData.motd,
					characters = characters,
					characterLimit = characterLimit,
				},
			})
			SendNUIMessage({ type = "LOADING_HIDE" })
			SendNUIMessage({
				type = "SET_STATE",
				data = { state = "STATE_CHARACTERS" },
			})

			FadeInWithTimeout(500)
		end)
	end)
end)

RegisterNUICallback("CreateCharacter", function(data, cb)
	cb("ok")
	plsr.Callbacks:ServerCallback("Characters:CreateCharacter", data, function(character)
		if character ~= nil then
			SendNUIMessage({
				type = "CREATE_CHARACTER",
				data = { character = character },
			})
		end

		SendNUIMessage({
			type = "SET_STATE",
			data = { state = "STATE_CHARACTERS" },
		})
		SendNUIMessage({ type = "LOADING_HIDE" })
	end)
end)

RegisterNUICallback("DeleteCharacter", function(data, cb)
	cb("ok")
	plsr.Callbacks:ServerCallback("Characters:DeleteCharacter", data.id, function(status)
		if status then
			SendNUIMessage({
				type = "DELETE_CHARACTER",
				data = { id = data.id },
			})
		end
		SendNUIMessage({ type = "LOADING_HIDE" })
	end)
end)

RegisterNUICallback("SelectCharacter", function(data, cb)
	cb("ok")
	plsr.Callbacks:ServerCallback("Characters:GetSpawnPoints", data.id, function(spawns)
		if spawns then
			SendNUIMessage({
				type = "SET_SPAWNS",
				data = { spawns = spawns },
			})
			SendNUIMessage({
				type = "SET_STATE",
				data = { state = "STATE_SPAWN" },
			})
		end

		SendNUIMessage({ type = "LOADING_HIDE" })
	end)
end)

RegisterNUICallback("PlayCharacter", function(data, cb)
	cb("ok")

	FadeOutWithTimeout(500)

	plsr.Callbacks:ServerCallback("Characters:GetCharacterData", data.character.ID, function(cData)
		cData.spawn = data.spawn
		TriggerEvent("Characters:Client:SetData", -1, cData, function()
			plsr.Spawn:SpawnToWorld(cData, function()
				if data.spawn.event ~= nil then
					plsr.Callbacks:ServerCallback(data.spawn.event, data.spawn, function()
						TriggerServerEvent("Characters:Server:Spawning")
						FadeInWithTimeout(500)
					end)
				else
					TriggerServerEvent("Characters:Server:Spawning")

					FadeInWithTimeout(500)
				end
			end)
		end)

		for k, v in ipairs(peds) do
			DeleteEntity(v)
		end
	end)
end)

RegisterNetEvent("Characters:Client:Spawned", function()
	plsr.State.flags.loggedIn = true
	TriggerEvent("Characters:Client:Spawn")
	TriggerServerEvent("Characters:Server:Spawn")
	SetNuiFocus(false)
	SendNUIMessage({ type = "APP_HIDE" })
	SendNUIMessage({ type = "LOADING_HIDE" })
end)
