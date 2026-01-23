local samp = require 'lib.samp.events'
local inicfg = require 'inicfg'

local script_version = 3
local url_version = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/version.txt" 
local url_script = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/fsafe_monitor.lua"

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
        sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Monitor: " .. (showLogs and "ON" or "OFF"), -1)
    end)
    
    sampRegisterChatCommand("fsafereset", function()
        mainIni.safe.de, mainIni.safe.m4, mainIni.safe.ak, mainIni.safe.ri = 0, 0, 0, 0
        inicfg.save(mainIni, config_path)
        sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Reset complete.", -1)
    end)

    sampRegisterChatCommand("fsafeset", function(arg)
        local weapon, ammo = arg:match("^(%w+)%s+(%d+)$")
        if weapon and ammo then
            weapon = weapon:lower()
            if mainIni.safe[weapon] ~= nil or weapon == "ri" or weapon == "ak" then
                mainIni.safe[weapon] = tonumber(ammo)
                inicfg.save(mainIni, config_path)
                sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Updated " .. weapon, -1)
            end
        end
    end)

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
    local version_file = os.getenv("TEMP") .. "\\fsafe_v.txt"
    downloadUrlToFile(url_version, version_file, function(id, status, p1, p2)
        if status == 6 then
            local f = io.open(version_file, "r")
            if f then
                local content = f:read("*a")
                f:close()
                os.remove(version_file)
                local new_version = tonumber(content:match("%d+"))
                if new_version and new_version > script_version then
                    sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}New version v" .. new_version .. " found! Downloading...", -1)
                    
                    local update_temp_file = os.getenv("TEMP") .. "\\fsafe_update.lua"
                    downloadUrlToFile(url_script, update_temp_file, function(id2, status2, p12, p22)
                        if status2 == 6 then
                            local up = io.open(update_temp_file, "rb")
                            if up then
                                local new_code = up:read("*a")
                                up:close()
                                os.remove(update_temp_file)
                                
                                local main_f = io.open(thisScript().path, "wb")
                                if main_f then
                                    main_f:write(new_code)
                                    main_f:close()
                                    sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Update successful! Reloading...", -1)
                                    thisScript():reload()
                                else
                                    sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Error: Cannot write to script file.", -1)
                                end
                            end
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
        if not low:find("объявление") and not low:find("тел:") and not low:find("news") then
            if low:find("deagle") then mainIni.safe.de = val
            elseif low:find("m4") then mainIni.safe.m4 = val
            elseif low:find("ak") then mainIni.safe.ak = val
            elseif low:find("rifle") then mainIni.safe.ri = val
            end
            inicfg.save(mainIni, config_path)
        end
    end
end
