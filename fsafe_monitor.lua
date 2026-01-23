local samp = require 'lib.samp.events'
local inicfg = require 'inicfg'

local script_version = 3
local url_version = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg_admins/main/version.txt" 
local url_script = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg_admins/main/fsafe_monitor.lua"

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
        local status = showLogs and "{32CD32}ON" or "{FF4500}OFF"
        sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}Monitor display: " .. status, -1)
    end)
    
    sampRegisterChatCommand("fsafereset", function()
        mainIni.safe.de, mainIni.safe.m4, mainIni.safe.ak, mainIni.safe.ri = 0, 0, 0, 0
        inicfg.save(mainIni, config_path)
        sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}All logs reset.", -1)
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
                sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}Updated: " .. weapon .. " = " .. ammo, -1)
            else
                sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}Error! Types: de, m4, ak, ri", -1)
            end
        else
            sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}Usage: /fsafeset {type} {amount}", -1)
        end
    end)

    sampAddChatMessage("{7B70FA}[blitzkrieg fsafe] {FFFFFF}v" .. script_version .. " loaded. Author: {7B70FA}slave_rodriguez", -1)

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
    local temp_path = os.getenv("TEMP") .. "\\fsafe_ver.txt"
    downloadUrlToFile(url_version, temp_path, function(id, status, p1, p2)
        if status == 6 then
            local f = io.open(temp_path, "r")
            if f then
                local content = f:read("*a")
                f:close()
                os.remove(temp_path)
                local new_version = tonumber(content:match("%d+"))
                if new_version and new_version > script_version then
                    sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}New version v" .. new_version .. " found! Downloading...", -1)
                    
                    local update_tmp = thisScript().path .. ".tmp"
                    downloadUrlToFile(url_script, update_tmp, function(id2, status2, p12, p22)
                        if status2 == 6 then
                            local f_new = io.open(update_tmp, "rb")
                            local new_code = f_new:read("*a")
                            f_new:close()
                            
                            local f_main = io.open(thisScript().path, "wb")
                            f_main:write(new_code)
                            f_main:close()
                            
                            os.remove(update_tmp)
                            sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Update successful! Reloading...", -1)
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
    
    if (low:find("сейф") or low:find("осталось")) and not low:find("объявление") and not low:find("тел:") then
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
end
