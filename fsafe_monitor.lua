local samp = require 'lib.samp.events'
local inicfg = require 'inicfg'

local script_version = 1.0 
local url_version = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg_admins/main/version.txt" 
local url_script = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg_admins/main/fsafe_monitor.lua"

local config_path = "moonloader//config//fsafe_stats.ini"
local mainIni = inicfg.load({
    safe = { de = 0, m4 = 0, ak = 0, ri = 0 },
    settings = { posX = 20, posY = 300 }
}, config_path)

local font = renderCreateFont("Arial", 9, 12)
local isDragging = false

local function u8(str)
    return str:gsub('..', function(cc)
        local code = {
            ['\208\144'] = '\192', ['\208\145'] = '\193', ['\208\146'] = '\194', ['\208\147'] = '\195', ['\208\148'] = '\196', ['\208\149'] = '\197', ['\208\150'] = '\198', ['\208\151'] = '\199', ['\208\152'] = '\200', ['\208\153'] = '\201', ['\208\154'] = '\202', ['\208\155'] = '\203', ['\208\156'] = '\204', ['\208\157'] = '\205', ['\208\158'] = '\206', ['\208\159'] = '\207', ['\208\160'] = '\208', ['\208\161'] = '\209', ['\208\162'] = '\210', ['\208\163'] = '\211', ['\208\164'] = '\212', ['\208\165'] = '\213', ['\208\166'] = '\214', ['\208\167'] = '\215', ['\208\168'] = '\216', ['\208\169'] = '\217', ['\208\170'] = '\218', ['\208\171'] = '\219', ['\208\172'] = '\220', ['\208\173'] = '\221', ['\208\174'] = '\222', ['\208\175'] = '\223', ['\208\176'] = '\224', ['\208\177'] = '\225', ['\208\178'] = '\226', ['\208\179'] = '\227', ['\208\180'] = '\228', ['\208\181'] = '\229', ['\208\182'] = '\230', ['\208\183'] = '\231', ['\208\184'] = '\232', ['\208\185'] = '\233', ['\208\186'] = '\234', ['\208\187'] = '\235', ['\208\188'] = '\236', ['\208\189'] = '\237', ['\208\190'] = '\238', ['\208\191'] = '\239', ['\209\128'] = '\240', ['\209\129'] = '\241', ['\209\130'] = '\242', ['\209\131'] = '\243', ['\209\132'] = '\244', ['\209\133'] = '\245', ['\209\134'] = '\246', ['\209\135'] = '\247', ['\209\136'] = '\248', ['\209\137'] = '\249', ['\209\138'] = '\250', ['\209\139'] = '\251', ['\209\140'] = '\252', ['\209\141'] = '\253', ['\209\142'] = '\254', ['\209\143'] = '\255', ['\208\129'] = '\168', ['\209\145'] = '\184'
        }
        return code[cc] or cc
    end)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    checkUpdate()
    
    local showLogs = true

    sampRegisterChatCommand("fsafemon", function()
        showLogs = not showLogs
        local status = showLogs and "{32CD32}" .. u8("ВКЛЮЧЕНО") or "{FF4500}" .. u8("ВЫКЛЮЧЕНО")
        sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}" .. u8("Отображение: ") .. status, -1)
    end)
    
    sampRegisterChatCommand("fsafereset", function()
        mainIni.safe.de, mainIni.safe.m4, mainIni.safe.ak, mainIni.safe.ri = 0, 0, 0, 0
        inicfg.save(mainIni, config_path)
        sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}" .. u8("Все показатели сброшены."), -1)
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
                sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}" .. u8("Обновлено: ") .. weapon .. " = " .. ammo, -1)
            else
                sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}" .. u8("Ошибка! Типы: de, m4, ak, ri"), -1)
            end
        else
            sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}" .. u8("Пример: /fsafeset de 100"), -1)
        end
    end)

    sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}v" .. script_version .. u8(" запущен. Автор: ") .. "{7B70FA}slave_rodriguez", -1)

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
                    if isDragging then isDragging = false inicfg.save(mainIni, config_path) end
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
                    sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}" .. u8("Найдено обновление v") .. new_version .. u8(". Загрузка..."), -1)
                    downloadUrlToFile(url_script, thisScript().path, function(id, status, p1, p2)
                        if status == 6 then
                            sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}" .. u8("Обновлено! Перезагрузка..."), -1)
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
