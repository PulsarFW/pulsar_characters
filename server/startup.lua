local config = load(LoadResourceFile(GetCurrentResourceName(), "config/server.lua"))()

Spawns = {}

local _ran = false

function Startup()
	if _ran then
		return
	end
	_ran = true

	-- Goes through pulsar_locations' own component rather than reading its table directly
	plsr.Locations:GetAll("spawn", function(locations)
		Spawns = { table.unpack(config.Spawns.default) }
		local loaded = 0
		for _, location in ipairs(locations or {}) do
			table.insert(Spawns, {
				id = location._id,
				label = location.Name,
				location = { x = location.Coords.x, y = location.Coords.y, z = location.Coords.z, h = location.Coords.w },
			})
			loaded = loaded + 1
		end

		plsr.Logger:Trace("Characters", "Loaded ^2" .. loaded .. "^7 Spawn Locations", { console = true })
	end)
end

AddEventHandler("Locations:Server:Added", function(type, location)
	if type == "spawn" then
		table.insert(Spawns, {
			id = location._id,
			label = location.Name,
			location = { x = location.Coords.x, y = location.Coords.y, z = location.Coords.z, h = location.Coords.h },
		})
		plsr.Logger:Info("Characters", "New Spawn Point Created: ^5" .. location.Name, { console = true })
	end
end)
