local config = load(LoadResourceFile(GetCurrentResourceName(), "config/shared.lua"))()

local cam = nil

local foTo = 0
function FadeOutWithTimeout(time, timeOut)
	DoScreenFadeOut(time or 500)
	foTo = 0
	while IsScreenFadingOut() and foTo < (timeOut or 3000) do
		foTo += 1
		Wait(1)
	end
end

local fiTo = 0
function FadeInWithTimeout(time, timeOut)
	DoScreenFadeIn(time or 500)
	fiTo = 0
	while IsScreenFadingIn() and fiTo < (timeOut or 3000) do
		fiTo += 1
		Wait(1)
	end
end

Spawn = {
	Choosing = true,
	InitCamera = function(self)
		
		if not IsScreenFadedOut() then
			FadeOutWithTimeout(500)
		end

		local sceneCoords = config.Scenes.splash.pedCoords
		local sceneCam = config.Scenes.splash.camera

		local ped = PlayerPedId()
		SetEntityCoords(ped, sceneCoords.x, sceneCoords.y, sceneCoords.z)
		FreezeEntityPosition(ped, true)
		SetEntityVisible(ped, false)
		SetPlayerVisibleLocally(ped, false)

		TransitionToBlurred(500)
		cam = CreateCamWithParams(
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
		SetCamActiveWithInterp(cam, true, 900, true, true)
		RenderScriptCams(true, false, 1, true, true)
		DisplayRadar(false)
	end,
	Init = function(self)
		FadeInWithTimeout(500)
		Wait(500) -- Why the fuck does NUI just not do this without a wait here???
		SetNuiFocus(true, true)
		SendNUIMessage({ type = "APP_SHOW" })
	end,
	SpawnToWorld = function(self, data, cb)
		FadeOutWithTimeout(500)

		local player = PlayerPedId()
		SetTimecycleModifier("default")

		local model = `mp_f_freemode_01`
		if tonumber(data.Gender) == 0 then
			model = `mp_m_freemode_01`
		end

		RequestModel(model)

		while not HasModelLoaded(model) do
			Wait(500)
		end
		SetPlayerModel(PlayerId(), model)
		player = PlayerPedId()
		SetPedDefaultComponentVariation(player)
		SetEntityAsMissionEntity(player, true, true)
		SetModelAsNoLongerNeeded(model)

		-- Safety check I guess
		while not IsEntityFocus(player) do
			ClearFocus()
			Wait(1)
		end

		Wait(300)

		DestroyAllCams(true)
		RenderScriptCams(false, true, 1, true, true)
		FreezeEntityPosition(player, false)

		NetworkSetEntityInvisibleToNetwork(player, false)
		SetEntityVisible(player, true)
		FreezeEntityPosition(player, false)

		cam = nil

		SetPlayerInvincible(PlayerId(), false)
		SetCanAttackFriendly(player, true, true)
		NetworkSetFriendlyFireOption(true)

		SetEntityMaxHealth(player, config.NewCharacterHealth.default)
		SetEntityHealth(player, data.HP > config.NewCharacterHealth.minValid and data.HP or config.NewCharacterHealth.default)
		DisplayHud(true)

		if data.action ~= nil then
			TriggerEvent(data.action, data.data)
		else
			SetEntityCoords(player, data.spawn.location.x, data.spawn.location.y, data.spawn.location.z)
			FadeInWithTimeout(500)
		end

		plsr.State.flags.ped = player

		SetNuiFocus(false)

		TriggerScreenblurFadeOut(500)
		cb()
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Spawn", Spawn)
end)
