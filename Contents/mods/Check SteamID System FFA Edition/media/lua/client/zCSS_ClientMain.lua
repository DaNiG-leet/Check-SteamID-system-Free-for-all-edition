--==============================================
-- Coded by DaNiG
-- My discord: https://discord.gg/2hg72hsHKv
-- Free for all
--==============================================

if not isClient() then return end

local SETTINGS = require("CSS_Settings")
local ChatSystem = require("CSS_ChatSystem")
local timeToSend

local CSS = {
    ModuleName = SETTINGS.ModuleName,
    Commands = {},
}

CSS.OnTick = function()
    if not timeToSend then
        Events.OnTick.Remove(CSS.OnTick)
    end
    if os.time() < timeToSend then
        return
    end
    sendClientCommand(getPlayer(), CSS.ModuleName, 'CheckSteamID', {getCurrentUserSteamID()})
    Events.OnTick.Remove(CSS.OnTick)
end

CSS.StartTimer = function(delay)
    timeToSend = os.time() + delay -- Crutch. If you send SteamID at once, nothing happens.
    Events.OnTick.Add(CSS.OnTick)
end

CSS.Commands.ReturnSteamID = function()
    CSS.StartTimer(5)
end

CSS.Commands.Alert = function(args)
    ChatSystem.addLineToChat('Alert. ' .. args[1] .. ' steamid in list. Reason: ' .. args[2], 'RED')
end

CSS.onServerCommand = function(module, command, args)
    if module ~= CSS.ModuleName then return end
    if CSS.Commands[command] then
        CSS.Commands[command](args)
    end
end

Events.OnServerCommand.Add(CSS.onServerCommand)