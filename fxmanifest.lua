fx_version 'cerulean'
games {'gta5'}

author 'Sonoran Software Systems'
real_name 'Sonoran CMS Permissions'
description 'Sonoran CMS to Ace permissions translation layer'
version '1.0.1'
git_repo 'https://github.com/Sonoran-Software/cms_ace_perms'

lua54 'yes'

server_scripts {'server/server.lua', 'config.lua'}

escrow_ignore {'config.CHANGEME.lua'}

ui_page 'nui/index.html'
