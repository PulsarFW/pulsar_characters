ONLINE_CHARACTERS = {}

CreateThread(function()
	RegisterCommands()
	_spawnFuncs = {}
	RegisterCallbacks()
	RegisterMiddleware()
	Startup()
end)

CHARACTERS = {
	GetLastLocation = function(self, source)
		return _tempLastLocation[source] or false
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Characters", CHARACTERS)
end)