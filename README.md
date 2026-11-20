# Forge NPWD Forge Mail

Aplicativo de email Forge NPWD com callbacks, locale, comando administrativo e banco pelo PR Bridge. Manifesto depende somente de `pr_bridge`; o serviço Forge NPWD é necessário para exibir o aplicativo e suas notificações.

Inicie `forge-npwd-mail` antes de `forge-npwd` e use `"forge-npwd-mail"` na lista `apps` do Forge NPWD. Export de servidor: `SendMailToCitizen(citizenid, mailData)`, retorna booleano. O protocolo `qb-phone:server:sendNewMail` continua para mensagens ao próprio jogador; `qb-phone:server:sendNewMailToOffline` é um evento local de servidor, destinado a integrações confiáveis. Esses nomes legados não exigem QB Phone ou QBX neste recurso.

As tabelas e emails existentes foram preservados. O frontend entregue contém apenas `web/dist`, sem fonte de build; URLs NUI, identificadores do app e callbacks do bundle distribuído foram atualizados para os novos nomes. Não houve rebuild de uma fonte ausente.

Origem Qbox mantida como atribuição no manifesto.
