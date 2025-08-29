fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'SNX_weaponrepairv2'
author 'SNX DEV'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/cl_weapons.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- jika tak guna, boleh buang
    'server/sv_weapons.lua',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    -- 'ox_target', -- optional, hanya jika mahu target
    -- 'qbx_core' atau 'qb-core' (salah satu wajib running di server)
}