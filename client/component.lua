RegisterNetEvent("Characters:Client:SetData", function(key, data, cb)
	plsr.State:SetCharacterData(key, data)
	TriggerEvent("Characters:Client:Updated", key)

	if cb then
		cb()
	end
end)

CHARACTERS = {
	Updating = true,
	Logout = function(self)
		DoScreenFadeOut(500)
		while IsScreenFadingOut() do
			Wait(1)
		end
		plsr.Callbacks:ServerCallback("Characters:Logout", {}, function()
			plsr.State.flags.loggedIn = false
			plsr.Action:Hide()
			plsr.Spawn:InitCamera()
			SendNUIMessage({
				type = "APP_RESET",
			})
			Wait(500)
			plsr.Spawn:Init()
		end)
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Characters", CHARACTERS)
end)
