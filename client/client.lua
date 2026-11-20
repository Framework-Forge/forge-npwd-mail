local locale = pr_lib.locale()
local mailNotificationSequence = 0
local PHONE_RESOURCE = 'forge-npwd'

local function phoneCall(method, ...)
    if GetResourceState(PHONE_RESOURCE) ~= 'started' then return false end
    return pcall(function(...)
        local phone = exports[PHONE_RESOURCE]
        return phone[method](phone, ...)
    end, ...)
end

RegisterNUICallback('forge-npwd:mail:getMail', function(_, cb)
	local mail = pr_lib.callback.await('forge-npwd:mail:getMail', false)
	cb({ status = 'ok', data = mail })
end)

RegisterNUICallback('forge-npwd:mail:updateRead', function(data, cb)
    local ok = pr_lib.callback.await('forge-npwd:mail:updateRead', false, data)
    cb({ status = ok and 'ok' or 'error' })
end)
RegisterNUICallback('forge-npwd:mail:deleteMail', function(data, cb)
    local ok = pr_lib.callback.await('forge-npwd:mail:deleteMail', false, data)
    cb({ status = ok and 'ok' or 'error' })
end)
RegisterNUICallback('forge-npwd:mail:updateButton', function(data, cb)
    local button = pr_lib.callback.await('forge-npwd:mail:updateButton', false, type(data) == 'table' and data.mailid)
    if type(button) ~= 'table' then cb({status='error'}); return end
    TriggerEvent(button.buttonEvent, button.buttonData)
    cb({status='ok'})
end)

RegisterNetEvent('forge-npwd:mail:newMail', function(data)
	if type(data) ~= 'table' or GetResourceState(PHONE_RESOURCE) ~= 'started' then return end

	phoneCall('sendForgeNPWDMessage', 'forge-npwd-mail', 'newMail', {data})

	local subject = type(data.subject) == 'string' and data.subject:match('%S') and data.subject or locale('newmail')
	local sender = type(data.sender) == 'string' and data.sender:match('%S') and data.sender or nil

	-- This Forge NPWD build only resolves internal apps in createNotification.
	-- System notifications also raise the closed phone, without app lookup or focus.
	mailNotificationSequence = mailNotificationSequence + 1
	phoneCall('createSystemNotification', {
		uniqId = ('forge-npwd-mail:%s:%s'):format(GetGameTimer(), mailNotificationSequence),
		secondaryTitle = sender and ('E-mail: ' .. sender) or 'E-mail',
		content = subject,
		keepOpen = false,
		duration = 5000,
		controls = false,
	})
end)
