local samp = require 'lib.samp.events'
local encoding = require 'encoding'
local vkeys = require 'vkeys'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local script_version = 5
local script_url = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/blitzkrieg_stream.lua"
local script_path = thisScript().path

local maxLevelLimit = 999
local mainColor = "7B70FA"
local notmainColor = "FFFFFF"
local errorColor = "FF0000"

local showScreenList = false
local screenPos = {x = 500, y = 500}
local isDragging = false
local font = renderCreateFont("Arial", 10, 5)

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    checkUpdate()

    sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Cheaters checker v%d loaded. | commands: /stream, /maxlvl, /sfc, /sstream | author: {7B70FA}slave_rodriguez", mainColor, script_version), -1)

    sampRegisterChatCommand("maxlvl", function(arg)
        if #arg > 0 and tonumber(arg) then
            maxLevelLimit = tonumber(arg)
            sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] Max level: {FFFFFF}%d", mainColor, maxLevelLimit), -1)
        else
            sampAddChatMessage(string.format(u8"{%s}[ERROR] Use: /maxlvl [number]", errorColor), -1)
        end
    end)

    sampRegisterChatCommand("sfc", function()
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myColor = sampGetPlayerColor(myId)
        local ids = {}
        
        for i = 0, 999 do
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and doesCharExist(ped) and i ~= myId then
                local playerColor = sampGetPlayerColor(i)
                local level = sampGetPlayerScore(i)
                if level <= maxLevelLimit and playerColor ~= myColor then 
                    table.insert(ids, tostring(i)) 
                end
            end
        end
        
        if #ids > 0 then
            sampSendChat(string.format(u8"/fc Cheaters: %s", table.concat(ids, " ")))
        else
            sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}No cheaters found.", mainColor), -1)
        end
    end)

    sampRegisterChatCommand("stream", function()
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myColor = sampGetPlayerColor(myId)
        
        sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] List of cheater in stream zone [up to %d lvl]", mainColor, maxLevelLimit), -1)
        local count = 0
        
        for i = 0, 999 do
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and doesCharExist(ped) and i ~= myId then
                local level = sampGetPlayerScore(i)
                local playerColor = sampGetPlayerColor(i)
                
                if level <= maxLevelLimit and playerColor ~= myColor then
                    local hexColor = string.format("%06X", bit.band(playerColor, 0xFFFFFF))
                    sampAddChatMessage(string.format("{%s}%s{%s}[%d] | Level: %d", hexColor, sampGetPlayerNickname(i), notmainColor, i, level), -1)
                    count = count + 1
                end
            end
        end
        
        if count == 0 then 
            sampAddChatMessage(string.format(u8"{%s}No cheaters found.", mainColor), -1) 
        end
    end)

    sampRegisterChatCommand("sstream", function()
        showScreenList = not showScreenList
        local status = showScreenList and "{00FF00}ON" or "{FF0000}OFF"
        sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] Screen list: %s", mainColor, status), -1)
    end)

    while true do
        wait(0)
        if showScreenList then
            drawCheatersList()
            handleDragging()
        end
    end
end

function drawCheatersList()
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local myColor = sampGetPlayerColor(myId)
    local yOffset = 0
    
    renderFontDrawText(font, string.format("Stream List (Max Lvl: %d)", maxLevelLimit), screenPos.x, screenPos.y, 0xFF7B70FA)
    yOffset = yOffset + 15

    local count = 0
    for i = 0, 999 do
        local result, ped = sampGetCharHandleBySampPlayerId(i)
        if result and doesCharExist(ped) and i ~= myId then
            local level = sampGetPlayerScore(i)
            local playerColor = sampGetPlayerColor(i)
            
            if level <= maxLevelLimit and playerColor ~= myColor then
                local nick = sampGetPlayerNickname(i)
                local text = string.format("%s[%d] | Lvl: %d", nick, i, level)
                local renderCol = bit.or(bit.band(playerColor, 0xFFFFFF), 0xFF000000)
                
                renderFontDrawText(font, text, screenPos.x, screenPos.y + yOffset, renderCol)
                yOffset = yOffset + 15
                count = count + 1
            end
        end
    end

    if count == 0 then
        renderFontDrawText(font, "No targets found", screenPos.x, screenPos.y + yOffset, 0xFFFFFFFF)
    end
end

function handleDragging()
    if isCursorActive() then
        local cX, cY = getCursorPos()
        if isKeyDown(vkeys.VK_LBUTTON) then
            -- Если нажали в районе заголовка
            if cX >= screenPos.x and cX <= screenPos.x + 150 and cY >= screenPos.y and cY <= screenPos.y + 20 then
                isDragging = true
            end
            
            if isDragging then
                screenPos.x = cX - 10
                screenPos.y = cY - 5
            end
        else
            isDragging = false
        end
    end
end

function checkUpdate()
    local temp_path = getWorkingDirectory() .. "\\temp_stream.lua"
    downloadUrlToFile(script_url, temp_path, function(id, status, p1, p2)
        if status == 6 then
            local f = io.open(temp_path, "r")
            if f then
                local content = f:read("*a")
                f:close()
                local new_version = content:match("local script_version = (%d+)")
                new_version = tonumber(new_version)
                if new_version and new_version > script_version then
                    sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Update is found v%d! Downloading...", mainColor, new_version), -1)
                    local new_file = io.open(script_path, "w")
                    if new_file then
                        new_file:write(content)
                        new_file:close()
                        sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Updated! Press {7B70FA}Ctrl + R", mainColor), -1)
                    end
                end
                os.remove(temp_path)
            end
        end
    end)
end
