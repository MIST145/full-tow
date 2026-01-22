Config = {}

-- Tow truck models and their type
Config.TowTrucks = {
    -- PROP_BASED: flatbed with separate prop
    ['flatbed'] = {
        type = 'PROP_BASED',
        name = 'Flatbed',
        description = 'Classic flatbed tow truck',
        rampBone = 'hydraulic_01',
        rampDownRotation = -90.0,
        rampUpRotation = 0.0,
        rampHeight = 2.5,
    },
    ['phantom'] = {
        type = 'PROP_BASED',
        name = 'Phantom',
        description = 'Phantom tow truck',
        rampBone = 'hydraulic_01',
        rampDownRotation = -90.0,
        rampUpRotation = 0.0,
        rampHeight = 2.5,
    },
    -- SCOOP_BASED: underlift with bone animation
    ['towtruck'] = {
        type = 'SCOOP_BASED',
        name = 'Towtruck',
        description = 'Underlift tow truck',
        forkBone = 'forks',
        forkDownZ = 0.0,
        forkUpZ = 1.2,
    },
}

-- Default config if truck not defined
Config.DefaultTruck = {
    type = 'SCOOP_BASED',
    name = 'Default Truck',
    forkBone = 'forks',
    forkDownZ = 0.0,
    forkUpZ = 1.2,
}

-- Winch settings
Config.Winch = {
    ropeLength = 50.0,
    ropeFalloff = 10.0,
    pullSpeed = 2.0,
    releaseSpeed = 1.0,
    hookOffset = vector3(0.0, 2.0, 1.5), -- Relative to truck
    maxDistance = 100.0,
    raycastDistance = 50.0,
}

-- Keybinds for controls
Config.Keybinds = {
    rampUp = 'LEFT',      -- Arrow Left
    rampDown = 'RIGHT',   -- Arrow Right
    winchToggleMode = 'N', -- Toggle between rope/attach modes
    winchUp = 'UP',       -- Arrow Up
    winchDown = 'DOWN',   -- Arrow Down
    openMenu = 'F6',      -- Open main menu
    closeUI = 'ESCAPE',   -- Close UI
    backMenu = 'BACK',    -- Back to main menu
}

-- TextUI settings
Config.TextUI = {
    position = 'top-right',
    offset = 0.1,
    duration = 0,
}

-- ox_target offsets per model
Config.TargetOffsets = {
    ['flatbed'] = {
        {
            label = 'Controlar Rampa',
            mode = 'ramp',
            offset = vector3(0.0, -3.0, 0.5),
            size = 0.5,
            distance = 2.0,
        },
        {
            label = 'Controlar Guincho',
            mode = 'winch',
            offset = vector3(0.0, 1.0, 1.0),
            size = 0.5,
            distance = 2.0,
        },
    },
    ['phantom'] = {
        {
            label = 'Controlar Rampa',
            mode = 'ramp',
            offset = vector3(0.0, -3.0, 0.5),
            size = 0.5,
            distance = 2.0,
        },
        {
            label = 'Controlar Guincho',
            mode = 'winch',
            offset = vector3(0.0, 1.0, 1.0),
            size = 0.5,
            distance = 2.0,
        },
    },
    ['towtruck'] = {
        {
            label = 'Controlar Rampa',
            mode = 'ramp',
            offset = vector3(0.0, -2.0, 0.5),
            size = 0.5,
            distance = 2.0,
        },
        {
            label = 'Controlar Guincho',
            mode = 'winch',
            offset = vector3(0.0, 1.0, 1.0),
            size = 0.5,
            distance = 2.0,
        },
    },
}

-- Tow truck spawn location for testing
Config.SpawnLocation = vector3(425.5, -980.5, 29.4)
Config.SpawnHeading = 180.0
