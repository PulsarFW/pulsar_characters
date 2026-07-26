local config = load(LoadResourceFile(GetCurrentResourceName(), "config/server.lua"))()

Spawns = {}

local _ran = false

function Startup()
	if _ran then
		return
	end
	_ran = true

	-- `seed_locations` is created/populated by pulsar_locations via Default:Add — that resource
	-- starts after this one (resources.cfg load order), so defensively create it here too rather
	-- than assume it already exists by the time this runs.
	plsr.Database:Query(
		"CREATE TABLE IF NOT EXISTS `seed_locations` (`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `data` JSON NOT NULL)",
		nil,
		function()
			plsr.Database:Query("SELECT `id`, `data` FROM `seed_locations`", nil, function(success, results)
				if not success then
					return
				end

				Spawns = { table.unpack(config.Spawns.default) }
				local loaded = 0
				for k, row in ipairs(results) do
					local ok, location = pcall(json.decode, row.data)
					if ok and type(location) == "table" and location.Type == "spawn" then
						table.insert(Spawns, {
							id = row.id,
							label = location.Name,
							location = { x = location.Coords.x, y = location.Coords.y, z = location.Coords.z, h = location.Coords.h },
						})
						loaded = loaded + 1
					end
				end

				plsr.Logger:Trace("Characters", "Loaded ^2" .. loaded .. "^7 Spawn Locations", { console = true })
			end)
		end
	)
end

AddEventHandler("Locations:Server:Added", function(type, location)
	if type == "spawn" then
		table.insert(Spawns, {
			label = location.Name,
			location = { x = location.Coords.x, y = location.Coords.y, z = location.Coords.z, h = location.Coords.h },
		})
		plsr.Logger:Info("Characters", "New Spawn Point Created: ^5" .. location.Name, { console = true })
	end
end)
