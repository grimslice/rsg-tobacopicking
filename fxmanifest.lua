fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'

description 'RSG Tobacco Picking'
version '1.0.0'

shared_scripts {
    '@rsg-core/shared/locale.lua',
    'locales/en.lua', -- you can add more languages here
    'config.lua'
}

client_scripts {
    '@rsg-target/client/target.lua',
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependency 'rsg-core'
dependency 'rsg-target'