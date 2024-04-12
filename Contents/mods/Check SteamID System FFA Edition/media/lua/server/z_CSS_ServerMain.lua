--==============================================
-- Coded by DaNiG
-- My discord: https://discord.gg/2hg72hsHKv
-- Free for all
--==============================================

if not isServer() then return end

local SETTINGS = require("CSS_Settings")
local ACCESS_LEVEL = require("CSS_AccessLevelsEnum")
local CSS_DEBUG = false
local oldOnlinePlayers = ArrayList.new()
local ticks = 0

local CSS = {
    DataBase = {},
    DBFilePath = '', -- Path to the file with the steamid list. If an empty string is specified, the file will be taken from Zomboid/lua. 
    DBFileName = 'bannedSteamIDs.ini', -- The name of the file with the list of steamid.
    LogFileName = 'CheckSteamIDSystem',
    Version = '1.0 FFA',
    ModuleName = SETTINGS.ModuleName,
    MinAccessLevel = 'Moderator', -- Minimum accesslevel to receive an alert.
    Commands = {}
}

CSS.print = function(a)
    if not CSS_DEBUG then return end
    print('[CSS] ' .. a)
end

CSS.writeLog = function(a)
    writeLog(CSS.LogFileName, a)
end

CSS.splitString = function(sentence)
    local first_space_index = string.find(sentence, " ")
    local first_word, rest_of_sentence

    if first_space_index then
        first_word = string.sub(sentence, 1, first_space_index - 1)
        rest_of_sentence = string.sub(sentence, first_space_index + 1)
    else
        first_word = sentence
        rest_of_sentence = ""
    end

    return first_word, rest_of_sentence
end

---Database Initialization
CSS.updateDataBase = function()
    local reader = getFileReader(CSS.DBFilePath .. CSS.DBFileName, false)
    if not reader then
        return 1 -- File doesnt exist
    end
    local linesCount = 0
	local line = reader:readLine()
	while line ~= nil do
        linesCount = linesCount + 1
        local steamID, reason = CSS.splitString(line)
        CSS.DataBase[steamID] = reason
		line = reader:readLine()
	end
	reader:close()
    if linesCount == 0 then
        return 2 -- File empty
    end
    return 0, linesCount -- All good
end

---Notifies the administration in chat.
---@param username string "Username of the player to whom the system responded."
---@param reason string "Sentence from the steamid list file."
CSS.AdminAlert = function(username, reason)
    local players = getOnlinePlayers()
    local array_size = players:size()
    for i = 0, array_size - 1, 1 do
        local playerObj = players:get(i)
        if ACCESS_LEVEL[playerObj:getAccessLevel()] >= ACCESS_LEVEL[CSS.MinAccessLevel] then
            sendServerCommand(playerObj, CSS.ModuleName, 'Alert', {username, reason})
        end
    end
end

CSS.SendCommandToCheck = function(player)
    CSS.print('Send command CheckIDConnectedPlayer to ' .. player:getUsername())
    sendServerCommand(player, CSS.ModuleName, "ReturnSteamID", {})
end

CSS.CheckSteamID = function(playerObj, SteamID)
    if CSS.DataBase[SteamID] then
        CSS.writeLog('Found a match. ' .. playerObj:getUsername() .. ' ' .. SteamID .. ' Reason: ' .. CSS.DataBase[SteamID])
        CSS.AdminAlert(playerObj:getUsername(), CSS.DataBase[SteamID])
    end
end

CSS.Commands.CheckSteamID = function(playerObj, args)
    CSS.CheckSteamID(playerObj, args[1])
end

CSS.OnClientCommand = function(module, command, playerObj, args)
    if module ~= CSS.ModuleName then return end
    if CSS.Commands[command] then
        CSS.Commands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(CSS.OnClientCommand)

CSS.OnInitGlobalModData = function()
    print('------------------------------------')
    print('Check SteamID System. Version: ' .. CSS.Version)
    local code, count = CSS.updateDataBase()
    if code == 0 then
        CSS.writeLog('Database inited. No. of entries: ' .. count)
        print('Database inited. No. of entries: ' .. count)
    elseif code == 1 then
        CSS.writeLog('Database has not been initialized. Cause: database file was not found. Make sure that the file named ' .. CSS.DBFileName .. ' is in the path Zomboid/Lua/' .. CSS.DBFilePath)
        print('Database has not been initialized. Check the logs for details.')
    elseif code == 2 then
        CSS.writeLog('Database has not been initialized. Cause: file is empty.')
        print('Database has not been initialized. Check the logs for details.')
    end
    print('------------------------------------')
end

Events.OnInitGlobalModData.Add(CSS.OnInitGlobalModData)

---The main function of determining player connectivity.
---@param tick integer
CSS.OnTick = function(tick)
    local players = getOnlinePlayers() or ArrayList.new()
    if ticks <= players:size() then -- Small optimization
        ticks = ticks + tick
        return
    end
    ticks = 0
    for i = 0, players:size() - 1 do
        local player = players:get(i)
        if player and not oldOnlinePlayers:contains(player) then
            CSS.print(player:getUsername() .. ' connected.')
            CSS.SendCommandToCheck(player)
        end
    end
    oldOnlinePlayers = players
end

Events.OnTick.Add(CSS.OnTick)