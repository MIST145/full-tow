fx_version 'cerulean'
game 'gta5'

author 'TowTruck Developer'
description 'Realistic towing system with ramp and winch control'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/ui.lua',
    'client/winch.lua',
    'client/tow_truck.lua',
    'client/target.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target'
}
