fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'fd_lib'
version      '1.6.0'
license 'LGPL-3.0-or-later'
repository 'https://https://github.com/FelisDevelopment/fd_lib'
description 'A library of shared functions to utilise in other resources.'

dependencies {
    '/server:5104',
    '/onesync',
}

files {
    'imports.lua',
    'web/dist/index.html',
    'web/dist/**/*',
    'locales/*.json',
}

ui_page 'web/dist/index.html'

shared_script {
    'main.lua'
}

shared_scripts {
    'config/*.lua',
    'modules/**/shared.lua',
    'modules/**/shared/*.lua',
}

client_scripts {
    'modules/**/client.lua',
    'modules/**/client/*.lua'
}

server_scripts {
    'modules/**/server.lua',
    'modules/**/server/*.lua'
}
