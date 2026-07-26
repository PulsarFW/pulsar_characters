local config = load(LoadResourceFile(GetCurrentResourceName(), "config/server.lua"))()

_tempLastLocation = {}
_lastSpawnLocations = {}

_pleaseFuckingWorkSID = {}
_pleaseFuckingWorkID = {}

_fuckingBozos = {}

local _pedsTableReady = false
local function ensurePedsTable(callback)
	if _pedsTableReady then
		if callback then
			callback()
		end
		return
	end
	plsr.Database:Query(
		"CREATE TABLE IF NOT EXISTS `peds` (`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `character_id` BIGINT UNSIGNED NOT NULL, `data` JSON NOT NULL, UNIQUE INDEX `idx_character` (`character_id`))",
		nil,
		function()
			_pedsTableReady = true
			if callback then
				callback()
			end
		end
	)
end

local _changelogsTableReady = false
local function ensureChangelogsTable(callback)
	if _changelogsTableReady then
		if callback then
			callback()
		end
		return
	end
	plsr.Database:Query(
		"CREATE TABLE IF NOT EXISTS `changelogs` (`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `date` BIGINT NOT NULL, `data` JSON NOT NULL, INDEX `idx_date` (`date`))",
		nil,
		function()
			_changelogsTableReady = true
			if callback then
				callback()
			end
		end
	)
end

AddEventHandler("Player:Server:Connected", function(source)
	_fuckingBozos[source] = os.time()
end)

function RegisterCallbacks()
	CreateThread(function()
		while true do
			if not (GlobalState["DisableAFK"] or false) then
				for k, v in pairs(_fuckingBozos) do
					if v < (os.time() - (60 * config.AfkKick.kickMinutes)) then
						if not plsr.State:Player(k).isDev and not plsr.State:Player(k).isAdmin and not plsr.State:Player(k).isStaff then
							plsr.Punishment:Kick(k, "You Were Kicked For Being AFK On Character Select", "Pwnzor", true)
						else
							plsr.Logger:Warn("Characters", "Staff or Admin Was AFK, Removing From Checks")
							_fuckingBozos[k] = nil
						end
					elseif v < (os.time() - (60 * config.AfkKick.warningMinutes)) then
						-- TODO: Implement better alert when at this stage when we have someway to do it
						plsr.Execute:Client(k, "Notification", "Warn", "You Will Be Kicked Soon For Being AFK", config.AfkKick.warningNotifyDurationMs)
					end
				end
			end
			Wait(60000)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:GetServerData", function(source, data, cb)
		while plsr.Fetch:Source(source) == nil do
			Wait(1000)
		end

		local motd = GetConvar("motd", "Welcome to Pulsar Framework")
		ensureChangelogsTable(function()
			plsr.Database:Query("SELECT `date`, `data` FROM `changelogs` ORDER BY `date` DESC LIMIT 1", nil, function(success, results)
				if not success then
					cb({ changelog = nil, motd = "" })
					return
				end

				if results and #results > 0 then
					local ok, changelog = pcall(json.decode, results[1].data)
					if ok and type(changelog) == "table" then
						changelog.date = results[1].date
					else
						changelog = nil
					end
					cb({ changelog = changelog, motd = motd })
				else
					cb({ changelog = nil, motd = motd })
				end
			end)
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:GetCharacters", function(source, data, cb)
		local player = plsr.Fetch:Source(source)
		EnsureCharactersTable(function()
			plsr.Database:Query(
				"SELECT `id`, `data` FROM `characters` WHERE `account` = ? AND `deleted` = 0",
				{ player:GetData("AccountID") },
				function(success, results)
					if not success then
						cb(nil)
						return
					end

					local decodedById = {}
					local charsToFetch = {}
					for k, row in ipairs(results) do
						local ok, decoded = pcall(json.decode, row.data)
						if ok and type(decoded) == "table" then
							decodedById[row.id] = decoded
							table.insert(charsToFetch, row.id)
						end
					end

					local p = promise.new()
					if #charsToFetch == 0 then
						p:resolve({})
					else
						ensurePedsTable(function()
							local placeholders = {}
							for i = 1, #charsToFetch do
								table.insert(placeholders, "?")
							end
							plsr.Database:Query(
								"SELECT `character_id`, `data` FROM `peds` WHERE `character_id` IN (" .. table.concat(placeholders, ", ") .. ")",
								charsToFetch,
								function(s2, pedRows)
									p:resolve((s2 and pedRows) or {})
								end
							)
						end)
					end

					local pedRows = Citizen.Await(p)
					local previews = {}
					for k, row in ipairs(pedRows) do
						local ok, decoded = pcall(json.decode, row.data)
						if ok then
							previews[row.character_id] = decoded
						end
					end

					local cData = {}
					for k, charId in ipairs(charsToFetch) do
						local v = decodedById[charId]
						table.insert(cData, {
							ID = charId,
							First = v.First,
							Last = v.Last,
							Phone = v.Phone,
							DOB = v.DOB,
							Gender = v.Gender,
							LastPlayed = v.LastPlayed,
							Jobs = v.Jobs,
							SID = v.SID,
							GangChain = v.GangChain,
							Preview = previews[charId] or false,
						})
					end

					local charLimit = config.CharacterLimits.default
					if player.Permissions:IsStaff() then
						charLimit = config.CharacterLimits.staff
					end

					cb(cData, charLimit)
				end
			)
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:CreateCharacter", function(source, data, cb)
		local player = plsr.Fetch:Source(source)

		EnsureCharactersTable(function()
			local p = promise.new()
			plsr.Database:Scalar(
				"SELECT COUNT(*) FROM `characters` WHERE `account` = ? AND `deleted` = 0",
				{ player:GetData("AccountID") },
				function(success, count)
					p:resolve((success and count) or config.CharacterLimits.default)
				end
			)

			local charCount = Citizen.Await(p)

			if charCount < config.CharacterLimits.default or player.Permissions:IsStaff() then
				local pNumber = plsr.Phone:GeneratePhoneNumber()

				local doc = {
					User = player:GetData("AccountID"),
					First = data.first,
					Last = data.last,
					Phone = pNumber,
					Gender = tonumber(data.gender),
					Bio = data.bio,
					Origin = data.origin,
					DOB = data.dob,
					LastPlayed = -1,
					Jobs = {},
					SID = plsr.Sequence:Get("Character"),
					Cash = config.NewCharacter.startingCash,
					New = true,
					Licenses = {
						Drivers = {
							Active = config.NewCharacter.startsWithDriversLicense,
							Points = 0,
							Suspended = false,
						},
						Weapons = {
							Active = false,
							Suspended = false,
						},
						Hunting = {
							Active = false,
							Suspended = false,
						},
						Fishing = {
							Active = false,
							Suspended = false,
						},
						Pilot = {
							Active = false,
							Suspended = false,
						},
						Drift = {
							Active = false,
							Suspended = false,
						},
					},
				}

				local extra = plsr.Middleware:TriggerEventWithData("Characters:Creating", source, doc)
				for k, v in ipairs(extra) do
					for k2, v2 in pairs(v) do
						if k2 ~= "ID" then
							doc[k2] = v2
						end
					end
				end

				plsr.Database:Insert(
					"INSERT INTO `characters` (`account`, `sid`, `deleted`, `phone`, `data`) VALUES (?, ?, 0, ?, ?)",
					{ doc.User, doc.SID, doc.Phone, json.encode(doc) },
					function(success, newId)
						if not success then
							cb(nil)
							return
						end
						doc.ID = newId
						TriggerEvent("Characters:Server:CharacterCreated", doc)
						plsr.Middleware:TriggerEvent("Characters:Created", source, doc)
						cb(doc)

						plsr.Logger:Info(
							"Characters",
							string.format(
								"%s [%s] Created a New Character %s %s (%s)",
								player:GetData("Name"),
								player:GetData("AccountID"),
								doc.First,
								doc.Last,
								doc.SID
							),
							{
								console = true,
								file = true,
								database = true,
							}
						)
					end
				)
			else
				cb(nil)
			end
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:DeleteCharacter", function(source, data, cb)
		local player = plsr.Fetch:Source(source)
		EnsureCharactersTable(function()
			plsr.Database:Single(
				"SELECT `id`, `data` FROM `characters` WHERE `account` = ? AND `id` = ?",
				{ player:GetData("AccountID"), data },
				function(success, row)
					if not success or row == nil then
						cb(nil)
						return
					end

					local ok, deletingChar = pcall(json.decode, row.data)
					if not ok then
						cb(nil)
						return
					end

					plsr.Database:Update(
						"UPDATE `characters` SET `deleted` = 1, `data` = JSON_SET(`data`, '$.Deleted', true) WHERE `account` = ? AND `id` = ?",
						{ player:GetData("AccountID"), data },
						function(updateSuccess)
							TriggerEvent("Characters:Server:CharacterDeleted", data, deletingChar.SID)
							cb(updateSuccess)

							if updateSuccess then
								plsr.Logger:Warn(
									"Characters",
									string.format(
										"%s [%s] Deleted Character %s %s (%s)",
										player:GetData("Name"),
										player:GetData("AccountID"),
										deletingChar.First,
										deletingChar.Last,
										deletingChar.SID
									),
									{
										console = true,
										file = true,
										database = true,
										discord = {
											embed = true,
										},
									}
								)
							end
						end
					)
				end
			)
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:GetSpawnPoints", function(source, data, cb)
		local player = plsr.Fetch:Source(source)
		EnsureCharactersTable(function()
			plsr.Database:Single(
				"SELECT `data` FROM `characters` WHERE `account` = ? AND `id` = ? AND `deleted` = 0",
				{ player:GetData("AccountID"), data },
				function(success, row)
					if not success or row == nil then
						cb(nil)
						return
					end

					local ok, char = pcall(json.decode, row.data)
					if not ok or type(char) ~= "table" then
						cb(nil)
						return
					end

					local hasLastLocation = _lastSpawnLocations[char.ID]

					if char.New then
						cb({
							{
								id = 1,
								label = "Character Creation",
								location = plsr.Apartment:GetInteriorLocation(char.Apartment or 1),
							},
						})
					elseif char.Jailed and not char.Jailed.Released ~= nil then
						cb({ config.Spawns.prison })
					elseif char.ICU and not char.ICU.Released then
						cb({ config.Spawns.icu })
					elseif hasLastLocation and plsr.Damage:WasDead(char.SID) then
						cb({
							{
								id = "LastLocation",
								label = "Last Location",
								location = {
									x = hasLastLocation.coords.x,
									y = hasLastLocation.coords.y,
									z = hasLastLocation.coords.z,
									h = 0.0,
								},
								icon = "location-dot",
								event = "Characters:GlobalSpawn",
							},
						})
					else
						local spawns = plsr.Middleware:TriggerEventWithData("Characters:GetSpawnPoints", source, data, char)
						cb(spawns or {})
					end
				end
			)
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:GetCharacterData", function(source, data, cb)
		local player = plsr.Fetch:Source(source)
		EnsureCharactersTable(function()
			plsr.Database:Single(
				"SELECT `id`, `data` FROM `characters` WHERE `account` = ? AND `id` = ?",
				{ player:GetData("AccountID"), data },
				function(success, row)
					if not success or row == nil then
						cb(nil)
						return
					end

					local ok, cData = pcall(json.decode, row.data)
					if not ok or type(cData) ~= "table" then
						cb(nil)
						return
					end

					cData.Source = source
					cData.ID = row.id

					player:SetData("Character", {
						SID = cData.SID,
						First = cData.First,
						Last = cData.Last,
					})

					local store = plsr.DataStore:CreateStore(source, "Character", cData)
					ONLINE_CHARACTERS[source] = store

					_pleaseFuckingWorkSID[cData.SID] = source
					_pleaseFuckingWorkID[cData.ID] = source

					GlobalState[string.format("SID:%s", source)] = cData.SID

					plsr.Middleware:TriggerEvent("Characters:CharacterSelected", source)

					cb(cData)
				end
			)
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:Logout", function(source, data, cb)
		_fuckingBozos[source] = os.time()
		local c = plsr.Fetch:CharacterSource(source)
		if c ~= nil then
			local cData = c:GetData()
			if cData.SID and cData.ID then
				_pleaseFuckingWorkSID[cData.SID] = nil
				_pleaseFuckingWorkID[cData.ID] = nil
			end

			TriggerEvent("Characters:Server:PlayerLoggedOut", source, cData)

			plsr.Middleware:TriggerEvent("Characters:Logout", source)
			ONLINE_CHARACTERS[source] = nil
			GlobalState[string.format("SID:%s", source)] = nil
			TriggerClientEvent("Characters:Client:Logout", source)
			plsr.Routing:RoutePlayerToHiddenRoute(source)
			plsr.DataStore:DeleteStore(source, "Character")
		end
		cb("ok")
	end)

	plsr.Callbacks:RegisterServerCallback("Characters:GlobalSpawn", function(source, data, cb)
		plsr.Routing:RoutePlayerToGlobalRoute(source)
		cb()
	end)
end

AddEventHandler("Characters:Server:DropCleanup", function(source, cData)
	_fuckingBozos[source] = nil
	ONLINE_CHARACTERS[source] = nil

	GlobalState[string.format("SID:%s", source)] = nil

	if cData and cData.SID and cData.ID then
		_pleaseFuckingWorkSID[cData.SID] = nil
		_pleaseFuckingWorkID[cData.ID] = nil
	end
end)

function HandleLastLocation(source)
	local char = plsr.Fetch:CharacterSource(source)

	if char ~= nil then
		local lastLocation = _tempLastLocation[source]
		if lastLocation and type(lastLocation) == "vector3" then
			_lastSpawnLocations[char:GetData("ID")] = {
				coords = lastLocation,
				time = os.time(),
			}
		end
	end

	_tempLastLocation[source] = nil
end

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	local lastLocation = _tempLastLocation[source]
	if lastLocation and type(lastLocation) == "vector3" then
		_lastSpawnLocations[cData.ID] = {
			coords = lastLocation,
			time = os.time(),
		}
	end
end)

function RegisterMiddleware()
	plsr.Middleware:Add("Characters:Spawning", function(source)
		_fuckingBozos[source] = nil
		TriggerClientEvent("Characters:Client:Spawned", source)
	end, 100000)
	plsr.Middleware:Add("Characters:ForceStore", function(source)
		local char = plsr.Fetch:CharacterSource(source)
		if char ~= nil then
			StoreData(source)
		end
	end, 100000)
	plsr.Middleware:Add("Characters:Logout", function(source)
		local char = plsr.Fetch:CharacterSource(source)
		if char ~= nil then
			StoreData(source)
		end
	end, 10000)

	plsr.Middleware:Add("Characters:GetSpawnPoints", function(source, id)
		if id then
			local hasLastLocation = _lastSpawnLocations[id]
			if hasLastLocation and hasLastLocation.time and (os.time() - hasLastLocation.time) <= (60 * config.LastLocationValidityMinutes) then
				return {
					{
						id = "LastLocation",
						label = "Last Location",
						location = {
							x = hasLastLocation.coords.x,
							y = hasLastLocation.coords.y,
							z = hasLastLocation.coords.z,
							h = 0.0,
						},
						icon = "location-dot",
						event = "Characters:GlobalSpawn",
					},
				}
			end
		end
		return {}
	end, 1)

	plsr.Middleware:Add("Characters:GetSpawnPoints", function(source)
		local spawns = {}
		for k, v in ipairs(Spawns) do
			v.event = "Characters:GlobalSpawn"
			table.insert(spawns, v)
		end
		return spawns
	end, 5)

	plsr.Middleware:Add("playerDropped", function(source, message)
		local char = plsr.Fetch:CharacterSource(source)
		if char ~= nil then
			StoreData(source)
		end
	end, 10000)

	plsr.Middleware:Add("Characters:Logout", function(source)
		local tpLocation = plsr.State:Player(source).tpLocation
		if tpLocation then
			_tempLastLocation[source] = tpLocation
		else
			_tempLastLocation[source] = GetEntityCoords(GetPlayerPed(source))
		end
		HandleLastLocation(source)
	end, 1)

	plsr.Middleware:Add("playerDropped", HandleLastLocation, 6)
end

AddEventHandler("playerDropped", function()
	local src = source
	if DoesEntityExist(GetPlayerPed(src)) then
		local tpLocation = plsr.State:Player(src).tpLocation
		if tpLocation then
			_tempLastLocation[src] = tpLocation
		else
			_tempLastLocation[src] = GetEntityCoords(GetPlayerPed(src))
		end
	end
end)

RegisterNetEvent("Characters:Server:LastLocation", function(coords)
	local src = source
	_tempLastLocation[src] = coords
end)
