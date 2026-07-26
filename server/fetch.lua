FETCH = {
	AllCharacters = function(self)
		return ONLINE_CHARACTERS
	end,
	CharacterSource = function(self, source)
		if source then
			return ONLINE_CHARACTERS[source]
		end
	end,
	CharacterData = function(self, key, value)
		for source, char in pairs(ONLINE_CHARACTERS) do
			if char and char:GetData(key) == value then
				return char
			end
		end
	end,
	ID = function(self, value)
		local source = _pleaseFuckingWorkID[value]
		if source then
			return plsr.Fetch:CharacterSource(tonumber(source))
		end
	end,
	SID = function(self, value)
		local source = _pleaseFuckingWorkSID[value]
		if source then
			return plsr.Fetch:CharacterSource(tonumber(source))
		end
	end,
	CountCharacters = function(self)
		local c = 0
		for k, v in pairs(ONLINE_CHARACTERS) do
			if v ~= nil then
				c = c + 1
			end
		end
		return c
	end,
	GetOfflineData = function(self, stateId, key)
		local p = promise.new()
		EnsureCharactersTable(function()
			plsr.Database:Single(
				"SELECT `data` FROM `characters` WHERE `sid` = ? AND `deleted` = 0 LIMIT 1",
				{ stateId },
				function(success, row)
					if not success or row == nil then
						return p:resolve(nil)
					end
					local ok, decoded = pcall(json.decode, row.data)
					if not ok or type(decoded) ~= "table" then
						return p:resolve(nil)
					end
					return p:resolve(decoded[key])
				end
			)
		end)
		return Citizen.Await(p)
	end,
}

AddEventHandler("Proxy:Shared:ExtendReady", function(component)
	if component == "Fetch" then
		exports["pulsar_core"]:ExtendComponent(component, FETCH)
	end
end)
