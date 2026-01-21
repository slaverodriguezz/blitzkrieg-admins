local samp = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local script_version = 3
local script_url = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/blitzkrieg_stream.lua"
local script_path = thisScript().path

local maxLevelLimit = 999
local mainColor = "7B70FA"
local notmainColor = "FFFFFF"
local errorColor = "FF0000"

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    checkUpdate()

    sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Чеккер загружен. v%d | Автор: {7B70FA}slave_rodriguez", mainColor, script_version), -1)

    sampRegisterChatCommand("maxlvl", function(arg)
        if #arg > 0 and tonumber(arg) then
            maxLevelLimit = tonumber(arg)
            sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] Максимальный уровень: {FFFFFF}%d", mainColor, maxLevelLimit), -1)
        else
            sampAddChatMessage(string.format(u8"{%s}[Ошибка] Используйте: /maxlvl [число]", errorColor), -1)
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
            sampSendChat(string.format(u8"/fc Читеры: %s", table.concat(ids, " ")))
        else
            sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Читеров нет (или у всех твой клист).", mainColor), -1)
        end
    end)

    sampRegisterChatCommand("stream", function()
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myColor = sampGetPlayerColor(myId)
        
        sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] Список читеров в зоне стрима [до %d уровня]", mainColor, maxLevelLimit), -1)
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
            sampAddChatMessage(string.format(u8"{%s}В зоне стрима нет подходящих игроков (кроме своих).", mainColor), -1) 
        end
    end)

    wait(-1)
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
                    sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Найдено обновление v%d! Устанавливаю...", mainColor, new_version), -1)
                    local new_file = io.open(script_path, "w")
                    if new_file then
                        new_file:write(content)
                        new_file:close()
                        sampAddChatMessage(string.format(u8"{%s}[blitzkrieg] {FFFFFF}Обновлено! Нажми {7B70FA}Ctrl + R", mainColor), -1)
                    end
                end
                os.remove(temp_path)
            end
        end
    end)
end
