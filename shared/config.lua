Config = {}

Config["DebugMode"] = true

Config["MaxHookReach"] = 10.0

Config["HookModel"] = `prop_v_hook_s`

Config["TowTrucks"] = {
	[`flatbed3`] = {
		truckType = "prop",
		truckModel = `flatbed3`,
		bedModel = `flatbed3_base`,
		bedExtraIndex = 1,
		lerpMult = 4.0,
		controlBoxOffset = vector3(-1.05, -1.0, 0.0),
		hookRootOffset = vector3(0.025, 4.5, 0.1),
		bedAttachOffset = vector3(0.0, 1.5, 0.3),
		bedOffsets = {
			raised = {
				pos = vector3(0.0, -3.8, 0.45),
				rot = vector3(0.0, 0.0, 0.0),
			},
			back = {
				pos = vector3(0.0, -4.0, 0.0),
				rot = vector3(0.0, 0.0, 0.0),
			},
			lowered = {
				pos = vector3(0.0, -0.4, -1.0),
				rot = vector3(12.0, 0.0, 0.0),
			},
		},
	},

	[`550towmfd2`] = {
		truckType = "scoop",
		truckModel = `550towmfd2`,
		controlBoxOffset = vector3(-1.1, -1.95, 0.1),
		hookRoot = {
			boneName = "attach_male",
			offset = vector3(0.0, 0.0, 0.0),
		},
		bedAttach = {
			boneName = "misc_z",
			offset = vector3(0.0, 0.0, 0.50),
		},
		bedPositions = {
			raised = 0.0,
			lowered = 0.25,
		},
	},

	[`112towmfd3`] = {
		truckType = "scoop",
		truckModel = `112towmfd3`,
		controlBoxOffset = vector3(-1.1, -1.95, 0.1),
		hookRoot = {
			boneName = "attach_male",
			offset = vector3(0.0, 0.0, 0.0),
		},
		bedAttach = {
			boneName = "misc_z",
			offset = vector3(0.0, 0.0, 0.50),
		},
		bedPositions = {
			raised = 0.0,
			lowered = 0.28,
		},
	},

	[`scaniatow`] = {
		truckType = "scoop",
		truckModel = `scaniatow`,
		controlBoxOffset = vector3(-1.37, -4.18, 0.1),
		hookRoot = {
			boneName = "misc_b",
			offset = vector3(0.0, 0.0, 0.0),
		},
		bedAttach = {
			boneName = "misc_a",
			offset = vector3(0.0, 1.0, 0.28),
		},
		bedPositions = {
			raised = 0.03,
			lowered = 0.27,
		},
	},

	[`337flatbed`] = {
		truckType = "scoop",
		truckModel = `337flatbed`,
		controlBoxOffset = vector3(-1.16, -3.72, 0.1),
		hookRoot = {
			boneName = "misc_b",
			offset = vector3(0.0, 0.0, 0.3),
		},
		bedAttach = {
			boneName = "misc_a",
			offset = vector3(0.0, 0.5, 0.85),
		},
		bedPositions = {
			raised = 0.03,
			lowered = 0.27,
		},
	},

	[`ct660tow`] = {
		truckType = "scoop",
		truckModel = `ct660tow`,
		controlBoxOffset = vector3(-1.23, -3.81, -0.43),
		hookRoot = {
			boneName = "misc_b",
			offset = vector3(-0.0, 0.11, 0.03),
		},
		bedAttach = {
			boneName = "misc_a",
			offset = vector3(0.0000, 0.76, 0.30),
		},
		bedPositions = {
			raised = 0.03,
			lowered = 0.27,
		},
	},

	[`16ramrb`] = {
		truckType = "scoop",
		truckModel = `16ramrb`,
		controlBoxOffset = vector3(-1.17, -4.44, -0.02),
		hookRoot = {
			boneName = "attach_male",
			offset = vector3(-0.0, -0.04, 0.03),
		},
		bedAttach = {
			boneName = "misc_z",
			offset = vector3(0.00, 0.48, 0.17),
		},
		bedPositions = {
			raised = 0.005,
			lowered = 0.36,
		},
	},

	[`flatbedm2`] = {
		truckType = "scoop",
		truckModel = `flatbedm2`,
		controlBoxOffset = vector3(-1.36, -3.47, 0.40),
		hookRoot = {
			boneName = "misc_b",
			offset = vector3(-0.0, -0.00, 0.02),
		},
		bedAttach = {
			boneName = "misc_a",
			offset = vector3(0.00, 0.85, 0.17),
		},
		bedPositions = {
			raised = 0.0,
			lowered = 0.36,
		},
	},
}

Config["MenuKeybinds"] = {
    OpenMenu = 244, -- M
    ToggleMode = 249, -- N
    ArrowUp = 172,
    ArrowDown = 173,
    ArrowLeft = 174,
    ArrowRight = 175,
    Escape = 322
}