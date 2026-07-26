name 'Pulsar Characters'
description 'Character select, creation, and spawn-point selection'
author 'Artmines - maintained for Pulsar Framework'
url 'https://pulsarframe.work'
version 'v1.0.0'

version_check 'yes'
github 'https://github.com/PulsarFW/pulsar_characters'

fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@pulsar_core/components/cl_error.lua")
shared_script("@pulsar_core/core/sh_pulsar.lua")
client_script("@pulsar_pwnzor/client/check.lua")

client_scripts({
	"client/**/*.lua",
})

server_scripts({
	"server/**/*.lua",
})

ui_page("ui/dist/index.html")

files({ "ui/dist/index.html", "ui/dist/assets/*", "config/shared.lua" })
