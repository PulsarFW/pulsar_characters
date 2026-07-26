return {
	NewCharacterHealth = {
		default = 200, -- HP applied on spawn when no valid saved HP exists
		minValid = 100, -- saved HP values at or below this are ignored in favor of default
	},

	Scenes = {
		splash = {
			pedCoords = { x = -145.403, y = -603.707, z = 167.000 },
			camera = { coord = vector4(-141.606, -601.351, 167.595, 264.761), pitch = -12.335, roll = 0.00, fov = 75.00 },
		},
		select = {
			pedCoords = { x = -145.403, y = -603.707, z = 167.000 },
			camera = { coord = vector4(-141.781, -601.587, 167.746,  264.761), pitch = -12.335, roll = 0.00, fov = 60.00 },
			preview = {
				char1 = { anim = "sitchair3", coord = vector4(-138.754, -600.025, 166.614, 126.432) },
				char2 = { anim = "sitchair4", coord = vector4(-137.928, -601.000, 166.605, 124.834) },
				char3 = { anim = "sitchair2", coord = vector4(-137.615, -601.925, 166.610, 93.474) },
				char4 = { anim = "sitchair5", coord = vector4(-138.007, -602.376, 166.595, 45.607) },
				char5 = { anim = "sitchair",  coord = vector4(-138.411, -603.437, 166.092, 39.504) },
			},
		},
	},
}

