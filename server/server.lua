local db = pr_lib.database
local function owner(src)
    return pr_lib.phone and pr_lib.phone.GetActiveOwnerIdentifier
        and pr_lib.phone.GetActiveOwnerIdentifier(src)
        or nil
end
local function mailId(value)
    return type(value) == 'number' and value > 0 and value % 1 == 0 and value or nil
end
local function decodeButton(value)
    if type(value) == 'string' and value ~= '' then
        local ok, decoded = pcall(json.decode, value)
        if ok and type(decoded) == 'table' then return decoded end
    end
end
pr_lib.callback.register('forge-npwd:mail:getMail', function(src)
    local id = owner(src)
    if not id then return {} end
    local rows = db.query('SELECT `citizenid`, `sender`, `subject`, `message`, `read`, `mailid`, `date`, `button` FROM player_mails WHERE citizenid = ? ORDER BY date DESC', { id }) or {}
    for _, row in ipairs(rows) do row.button = decodeButton(row.button) end
    return rows
end)
pr_lib.callback.register('forge-npwd:mail:updateRead', function(src, value)
    local id, key = owner(src), mailId(value)
    if not id or not key then return false end
    return (db.update('UPDATE player_mails SET `read` = 1 WHERE mailid = ? AND citizenid = ?', { key, id }) or 0) > 0
end)
pr_lib.callback.register('forge-npwd:mail:deleteMail', function(src, value)
    local id, key = owner(src), mailId(value)
    if not id or not key then return false end
    return (db.update('DELETE FROM player_mails WHERE mailid = ? AND citizenid = ?', { key, id }) or 0) > 0
end)
pr_lib.callback.register('forge-npwd:mail:updateButton', function(src, value)
    local id, key = owner(src), mailId(value)
    if not id or not key then return nil end
    local row = db.single('SELECT button FROM player_mails WHERE mailid = ? AND citizenid = ?', { key, id })
    local button = row and decodeButton(row.button)
    if not button or type(button.buttonEvent) ~= 'string' then return nil end
    local changed = db.update('UPDATE player_mails SET button = NULL WHERE mailid = ? AND citizenid = ? AND button = ?', { key, id, row.button })
    return changed and changed > 0 and button or nil
end)
local function sendMailToCitizen(citizenid, data)
    if type(citizenid) ~= 'string' or citizenid == '' or type(data) ~= 'table' then return false end
    local sender, subject, message = tostring(data.sender or ''), tostring(data.subject or ''), tostring(data.message or '')
    if #sender > 255 or #subject > 255 or #message > 65535 then return false end
    local key
    for _ = 1, 10 do
        local candidate = math.random(111111, 999999)
        if not db.scalar('SELECT 1 FROM player_mails WHERE mailid = ? LIMIT 1', { candidate }) then key = candidate; break end
    end
    if not key then return false end
    local button = type(data.button) == 'table' and next(data.button) and data.button or nil
    local inserted
    if button then
        inserted = db.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)',
            {citizenid, sender, subject, message, key, 0, json.encode(button)})
    else
        inserted = db.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)',
            {citizenid, sender, subject, message, key, 0})
    end
    if inserted == nil or tonumber(db.scalar('SELECT 1 FROM player_mails WHERE citizenid = ? AND mailid = ? LIMIT 1', {citizenid, key})) ~= 1 then return false end
    -- Database queries may yield: resolve the online recipient only after persistence.
    local player = pr_lib.framework.GetPlayerFromIdentifier(citizenid)
    local info = player and (player.PlayerData or player)
    if info and info.source then
        TriggerClientEvent('forge-npwd:mail:newMail', info.source, {sender=sender,subject=subject,message=message,mailid=key,button=button,read=0,date=os.time()*1000})
    end
    return true
end
exports('SendMailToCitizen', sendMailToCitizen)
-- Compatibility protocols used by existing business scripts, not framework dependencies.
RegisterNetEvent('qb-phone:server:sendNewMail', function(data)
    local id = owner(source)
    if id then sendMailToCitizen(id, data) end
end)
AddEventHandler('qb-phone:server:sendNewMailToOffline', sendMailToCitizen)
pr_lib.addCommand('testemail', {help='Enviar e-mail de teste',restricted='group.admin'}, function(src)
    local id = owner(src)
    if id then sendMailToCitizen(id, {sender='Forge',subject='Teste de e-mail',message='Integração PR Bridge funcionando.'}) end
end)
