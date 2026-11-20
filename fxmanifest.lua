fx_version 'cerulean'
game 'gta5'

name 'forge-npwd-mail'
author 'PierreMoraes'
description 'Forge Mail app for Forge NPWD through PR Bridge'
version '1.0.2'
repository 'https://github.com/Qbox-project/npwd_qbx_mail'

client_script 'client/client.lua'

shared_script '@pr_bridge/init.lua'
shared_script '@forge-npwd/compat/app.lua'

server_script {
    'server/server.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/**/*',
    'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'


dependency 'pr_bridge'
dependency 'forge-npwd'

-- Legacy dependency names; export routing remains inside forge-npwd.
provide 'npwd_forge_mail'
provide 'npwd_qbx_mail'

server_script 'server/version.lua'
