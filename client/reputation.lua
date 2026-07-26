local _reps = {}
_REP = {
	GetLevel = function(self, id)
		if GlobalState[string.format("Rep:%s", id)] ~= nil then
			local reps = plsr.State.character.Reputations or {}
			if reps[id] ~= nil then
				local level = 0
				if reps[id] ~= nil then
					for k, v in ipairs(GlobalState[string.format("Rep:%s", id)].levels) do
						if v.value <= reps[id] then
							level = k
						end
					end
					return level
				else
					return 0
				end
			else
				return 0
			end
		else
			return 0
		end
	end,
	HasLevel = function(self, id, level)
		if GlobalState[string.format("Rep:%s", id)] ~= nil then
			local reps = plsr.State.character.Reputations or {}
			if reps[id] ~= nil then
				local l = 0
				if reps[id] ~= nil then
					for k, v in ipairs(GlobalState[string.format("Rep:%s", id)].levels) do
						if v.value <= reps[id] then
							l = k
						end
					end
					return l >= level
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	end,
	GetLevelData = function(self, id)
		if GlobalState[string.format("Rep:%s", id)] ~= nil then
			local reps = plsr.State.character.Reputations or {}
			if reps[id] ~= nil then
				local level = 0
				if reps[id] ~= nil then
					for k, v in ipairs(GlobalState[string.format("Rep:%s", id)].levels) do
						if v.value <= reps[id] then
							level = {
								level = k,
								label = v.label,
								value = v.value,
							}
						end
					end
					return level
				else
					return 0
				end
			else
				return 0
			end
		else
			return 0
		end
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Reputation", _REP)
end)
