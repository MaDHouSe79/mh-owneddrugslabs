fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe'
description 'MH Owned Drugs Labs - for QB-Core RP servers.'
version '1.0.0'
lua54 'yes'
repository 'https://github.com/MaDHouSe79/mh-owneddrugslabs'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/vehicles.lua',
    'shared/functions.lua',
    'shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/config/sv_config.lua',
    'server/config/labs.lua',
    'server/config/storeage.lua',
    'server/config/fields.lua',
    'server/config/zones.lua',
    'server/config/dealers.lua',
    'server/main.lua',
    'server/update.lua',
}

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/modules/menus.lua',
    'client/modules/zones.lua',
    'client/modules/shops.lua',
    'client/modules/dealers.lua',
    'client/modules/fields.lua',
    'client/modules/npcthiefs.lua',
    'client/main.lua',
}

dependencies {
    'oxmysql',
    'PolyZone',
    'ox_lib',
    'qb-core',
    'qb-inventory',
}

data_file 'DLC_ITYP_REQUEST' 'stream/prop_methbarrel.ytyp'