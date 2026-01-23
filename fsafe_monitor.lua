local samp = require 'lib.samp.events'
local inicfg = require 'inicfg'

local script_version = 1.0
local url_version = "ССЫЛКА_НА_RAW_VERSION.TXT"
local url_script = "ССЫЛКА_НА_RAW_FSAFE.LUA"

local config_path = "moonloader//config//fsafe_stats.ini"
local mainIni = inicfg.load({
    safe = { de = 0, m4 = 0, ak = 0, ri = 0 },
    settings = { posX = 20, posY = 300 }
}, config_path)

local font = renderCreateFont("Arial", 9, 12)
local isDragging = false

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    checkUpdate()
    
    local showLogs = true

    sampRegisterChatCommand("fsafemon", function()
        showLogs = not showLogs
        local status = showLogs and "{32CD32}ВКЛЮЧЕНО" or "{FF4500}ВЫКЛЮЧЕНО"
        sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Отображение логов: " .. status, -1)
    end)
    
    sampRegisterChatCommand("fsafereset", function()
        mainIni.safe.de, mainIni.safe.m4, mainIni.safe.ak, mainIni.safe.ri = 0, 0, 0, 0
        inicfg.save(mainIni, config_path)
        sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Все показатели сброшены.", -1)
    end)

    sampRegisterChatCommand("fsafeset", function(arg)
        local weapon, ammo = arg:match("^(%w+)%s+(%d+)$")
        if weapon and ammo then
            weapon = weapon:lower()
            ammo = tonumber(ammo)
            local found = false
            if weapon == "de" then mainIni.safe.de = ammo found = true
            elseif weapon == "m4" then mainIni.safe.m4 = ammo found = true
            elseif weapon == "ak" then mainIni.safe.ak = ammo found = true
            elseif weapon == "ri" then mainIni.safe.ri = ammo found = true
            end
            if found then
                inicfg.save(mainIni, config_path)
                sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Обновлено: " .. weapon .. " = " .. ammo, -1)
            else
                sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Ошибка! Используйте: de, m4, ak, ri", -1)
            end
        else
            sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Пример: /fsafeset {de, m4, ak, ri} {кол-во патронов}", -1)
        end
    end)

    sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Скрипт v" .. script_version .. " запущен. Автор: {7B70FA}slave_rodriguez", -1)

    while true do
        wait(0)
        if showLogs then
            local x, y = mainIni.settings.posX, mainIni.settings.posY
            renderFontDrawText(font, "{8378FA}Deagle {FFFFFF}- " .. mainIni.safe.de, x, y, 0xFFFFFFFF)
            renderFontDrawText(font, "{8378FA}M4 {FFFFFF}- " .. mainIni.safe.m4, x, y + 15, 0xFFFFFFFF)
            renderFontDrawText(font, "{8378FA}AK47 {FFFFFF}- " .. mainIni.safe.ak, x, y + 30, 0xFFFFFFFF)
            renderFontDrawText(font, "{8378FA}Rifle {FFFFFF}- " .. mainIni.safe.ri, x, y + 45, 0xFFFFFFFF)

            if sampIsCursorActive() then
                local mx, my = getCursorPos()
                if isKeyDown(0x01) then 
                    if not isDragging then
                        if mx >= x and mx <= x + 100 and my >= y and my <= y + 60 then isDragging = true end
                    else
                        mainIni.settings.posX, mainIni.settings.posY = mx - 50, my - 30
                    end
                else
                    if isDragging then
                        isDragging = false
                        inicfg.save(mainIni, config_path)
                    end
                end
            end
        end
    end
end

function checkUpdate()
    local temp_path = getWorkingDirectory() .. "\\fsafe_version.txt"
    downloadUrlToFile(url_version, temp_path, function(id, status, p1, p2)
        if status == 6 then
            local f = io.open(temp_path, "r")
            if f then
                local content = f:read("*a")
                f:close()
                os.remove(temp_path)
                local new_version = tonumber(content)
                if new_version and new_version > script_version then
                    sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Найдено обновление до v" .. new_version .. ". Загрузка...", -1)
                    downloadUrlToFile(url_script, thisScript().path, function(id, status, p1, p2)
                        if status == 6 then
                            sampAddChatMessage("{7B70FA}[blitzkrieg fsafe monitoring] {FFFFFF}Обновление завершено! Перезагрузка...", -1)
                            thisScript():reload()
                        end
                    end)
                end
            end
        end
    end)
end

function samp.onServerMessage(color, text)
    local clean = text:gsub("{%x%x%x%x%x%x}", ""):gsub("%%", "%%%%") 
    local low = clean:lower()
    local ammo = clean:match(":%s+(%d+)")
    if ammo then
        local val = tonumber(ammo)
        if low:find("deagle") then mainIni.safe.de = val
        elseif low:find("m4") then mainIni.safe.m4 = val
        elseif low:find("ak") then mainIni.safe.ak = val
        elseif low:find("rifle") then mainIni.safe.ri = val
        end
        inicfg.save(mainIni, config_path)
    end
end
