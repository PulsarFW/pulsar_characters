return {
	Spawns = {
		prison = {
			id = 1,
			icon = "link",
			label = "Bolingbroke Penitentiary",
			location = { x = 1767.49, y = 2501.12, z = 45.72, h = 0.0 },
			event = "Jail:SpawnJailed",
		},
		icu = {
			id = 1,
			icon = "hospital",
			label = "St. Fiacre Intensive Care Unit",
			location = { x = 1153.161, y = -1542.383, z = 39.537, h = 123.576 },
			event = "Hospital:SpawnICU",
		},
		default = {
			{
				id = 1,
				label = "LSIA",
				location = { x = -1044.84, y = -2749.85, z = 21.36, h = 0.0 },
			},
		},
	},

	CharacterLimits = {
		default = 3, -- max characters a normal player may create
		staff = 5, -- max characters a staff member may create
	},

	NewCharacter = {
		startingCash = 1000, -- cash granted on character creation
		startsWithDriversLicense = true, -- whether new characters begin with an active, unsuspended driver's license
	},

	AfkKick = {
		warningMinutes = 5, -- time on character select before the AFK warning fires
		kickMinutes = 10, -- time on character select before being kicked for AFK
		warningNotifyDurationMs = 58000, -- how long the AFK warning toast stays on screen
	},

	LastLocationValidityMinutes = 5, -- how long a "resume where you left off" spawn option stays offered after death/logout
}
