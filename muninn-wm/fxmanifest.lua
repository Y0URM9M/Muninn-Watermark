----------------------------------------------------------------
                   --  muninn_watermark--
----------------------------------------------------------------

game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

-- Define the resource metadata
name "muninn_watermark"
description "Watermark Script for your server"
author "Muninn"
version "v1.0.0"

client_scripts {
	'config.lua',
	'client.lua'
}

ui_page 'html/ui.html'
files {
	'html/*',
	'img/logo.png'
}
