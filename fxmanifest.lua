fx_version "cerulean"
game { "gta5" }
description "Simple WIPE script with for fivem"
lua54 'yes'

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}


shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua',
}
