fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'fd_lib'
version      '1.4.1'
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
    '@nb-keyevent/nb-keyevent.lua',
    'modules/**/client.lua',
    'modules/**/client/*.lua'
}

server_scripts {
    'modules/**/server.lua',
    'modules/**/server/*.lua'
}
