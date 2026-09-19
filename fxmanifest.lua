fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'CB Studios'
description 'Local survival radio network with physical antennas, maintenance, linking and PMA-Voice integration'
version '1.0.0'
license 'MIT'

dependencies {
    'hate-bridge',
    'oxmysql',
    'pma-voice'
}

shared_scripts {
    'config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/bridge.lua',
    'client/main.lua',
    'client/antennas.lua',
    'client/radio.lua',
    'client/placement.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'server/main.lua',
    'server/antennas.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
