local ChatSystem = {}
ChatSystem.COLORS = require("CSS_Colors")

function ChatSystem.addLineToChat(message, color, chat, alert, soundName, volume)

    if not ISChat.instance then return end
    if not ISChat.instance.chatText then return end

    if not chat then chat = 1 end

    local options = {
        showTime = ISChat.instance.showTimestamp,
        serverAlert = false,
        showAuthor = false
    }

    if type(color) ~= "string" then color = ChatSystem.COLORS.DEF end

    message = '[CSS] ' .. message

    if options.showTime then
        local dateStamp = Calendar.getInstance():getTime()
        local dateFormat = SimpleDateFormat.new("H:mm")
        if dateStamp and dateFormat then message = "<RGB:1,1,1>" .. "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]  " .. ChatSystem.COLORS[color] .. message end
    else
        message = ChatSystem.COLORS[color] .. message
    end

    message = '<SIZE:' .. tostring(ISChat.instance.chatFont) .. '>' .. message

    local msg = {
        getChatID = function(_)
            return false
        end,
        getText = function(_)
            return message
        end,
        getTextWithPrefix = function(_)
            return message
        end,
        isServerAlert = function(_)
            return options.serverAlert
        end,
        isShowAuthor = function(_)
            return options.showAuthor
        end,
        getAuthor = function(_)
            return tostring('Server')
        end,
        setShouldAttractZombies = function(_)
            return false
        end,
        setOverHeadSpeech = function(_)
            return false
        end
    }
    if alert and soundName then
        getSoundManager():PlaySound(soundName, false, 0):setVolume(volume)
    end
    ISChat.addLineInChat(msg, chat)
end

return ChatSystem