fx_version "cerulean"
lua54 "yes"
game "gta5"

author "DevJacob"
description "A realistic towing script for FiveM"
version "1.2.0"

shared_scripts {
    '@ox_lib/init.lua',
    "shared/utils.lua",
    "shared/config.lua",
}

client_scripts {
    "client/utils.lua",
    "client/classes/towTruck.lua",
    "client/classes/scoopBased.lua",
    "client/classes/propBased.lua",
    "client/ropes.lua",
    "client/menu.lua",
    "client/main.lua",
}