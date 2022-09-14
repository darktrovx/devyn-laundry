fx_version 'cerulean'
game 'gta5'

author 'Devyn'
description 'Money Laundry'

shared_scripts { 
	'config.lua'
}

server_scripts { 
    "server.lua",
    '@oxmysql/lib/MySQL.lua',
}

client_scripts { 
    "client.lua",
}