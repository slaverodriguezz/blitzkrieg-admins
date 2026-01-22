local samp = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local script_version = 7
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

    sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Cheaters checker v%d loaded. | /stream, /sfc, /sstream", mainColor, script_version), -1)

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
                if sampGetPlayerScore(i) <= maxLevelLimit and sampGetPlayerColor(i) ~= myColor then 
                    table.insert(ids, tostring(i)) 
                end
            end
        end
        if #ids > 0 then sampSendChat(string.format("/fc Cheaters: %s", table.concat(ids, " ")))
        else sampAddChatMessage(u8"{7B70FA}[blitzkrieg] {FFFFFF}Никого не найдено", -1) end
    end)

    sampRegisterChatCommand("stream", function()
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myColor = sampGetPlayerColor(myId)
        sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] Stream zone [up to %d lvl]", mainColor, maxLevelLimit), -1)
        for i = 0, 999 do
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and doesCharExist(ped) and i ~= myId then
                local level = sampGetPlayerScore(i)
                local playerColor = sampGetPlayerColor(i)
                if level <= maxLevelLimit and playerColor ~= myColor then
                    local hexColor = string.format("%06X", bit.band(playerColor, 0xFFFFFF))
                    sampAddChatMessage(string.format("{%s}%s{%s}[%d] | Level: %d", hexColor, sampGetPlayerNickname(i), notmainColor, i, level), -1)
                end
            end
        end
    end)

    sampRegisterChatCommand("sstream", function()
        showScreenList = not showScreenList
        sampAddChatMessage(u8"{7B70FA}[blitzkrieg] {FFFFFF}Экранный список: " .. (showScreenList and "{00FF00}ВКЛ" or "{FF0000}ВЫКЛ"), -1)
    end)

    while true do
        wait(0)
        if showScreenList then
            drawList()
            handleDragging()
        end
    end
end

function drawList()
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local myColor = sampGetPlayerColor(myId)
    local y = screenPos.y
    
    renderFontDrawText(font, "Stream List (Drag me)", screenPos.x, y, 0xFF7B70FA)
    y = y + 15

    for i = 0, 999 do
        local result, ped = sampGetCharHandleBySampPlayerId(i)
        if result and doesCharExist(ped) and i ~= myId then
            local level = sampGetPlayerScore(i)
            local pCol = sampGetPlayerColor(i)
            if level <= maxLevelLimit and pCol ~= myColor then
                local nick = sampGetPlayerNickname(i)
                local renderColor = bit.or(bit.band(pCol, 0xFFFFFF), 0xFF000000) 
                renderFontDrawText(font, string.format("%s[%d] | Lvl: %d", nick, i, level), screenPos.x, y, renderColor)
                y = y + 15
            end
        end
    end
end

function handleDragging()
    if isSampAvailable() and sampIsCursorActive() then
        local cX, cY = getCursorPos()
        if isKeyDown(0x01) then 
            if not isDragging and cX >= screenPos.x and cX <= screenPos.x + 150 and cY >= screenPos.y and cY <= screenPos.y + 20 then
                isDragging = true
            end
            if isDragging then
                screenPos.x = cX - 75
                screenPos.y = cY - 10
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
                if new_version and tonumber(new_version) > script_version then
                    local new_file = io.open(script_path, "w")
                    if new_file then
                        new_file:write(content)
                        new_file:close()
                        sampAddChatMessage(u8"{7B70FA}[blitzkrieg] {FFFFFF}Обновлено! Перезагрузите скрипты (Ctrl+R)", -1)
                    end
                end
                os.remove(temp_path)
            end
        end
    end)
end
