local samp = require 'lib.samp.events'
local inicfg = require 'inicfg'

local script_version = 8
local url_script = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/fsafe_monitor.lua"
local script_path = thisScript().path

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
    sampAddChatMessage("{7B70FA}[blitzkrieg safe] {FFFFFF}loaded. | Commands: /fsafeset, /fsafereset, /fsafemon | author: {7B70FA}slave_rodriguez", -1)
    
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
            if mainIni.safe[weapon] ~= nil then
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
    local download_url = url_script .. "?v=" .. os.time()
    local temp_path = os.getenv("TEMP") .. "\\temp_fsafe_upd.lua"
    
    downloadUrlToFile(download_url, temp_path, function(id, status, p1, p2)
        if status == 6 then
            local f = io.open(temp_path, "rb")
            if f then
                local content = f:read("*a")
                f:close()
                os.remove(temp_path)
                
                local new_version = content:match("local script_version = (%d+)")
                if new_version then
                    new_version = tonumber(new_version)
                    if new_version > script_version then
                        sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}New version v" .. new_version .. " found! Updating...", -1)
                        
                        local script_file = io.open(script_path, "wb")
                        if script_file then
                            script_file:write(content)
                            script_file:close()
                            
                            sampAddChatMessage("{7B70FA}[fsafe] {FFFFFF}Updated! Reloading script...", -1)
                            lua_thread.create(function()
                                wait(500)
                                thisScript():reload()
                            end)
                        else
                            sampAddChatMessage("{7B70FA}[fsafe] {FF0000}Update error: {FFFFFF}File is busy or protected.", -1)
                        end
                    end
                end
            end
        end
    end)
end

function samp.onServerMessage(color, text)
    local clean = text:gsub("{%x%x%x%x%x%x}", ""):gsub("%%", "%%%%") 
    local low = clean:lower()
    
    if low:find("объявление") or low:find("тел:") or low:find("news") then return end

    local ammoTotal = clean:match(":%s+(%d+)")
    if ammoTotal then
        local val = tonumber(ammoTotal)
        if low:find("deagle") then mainIni.safe.de = val
        elseif low:find("m4") then mainIni.safe.m4 = val
        elseif low:find("ak") then mainIni.safe.ak = val
        elseif low:find("rifle") then mainIni.safe.ri = val
        end
        inicfg.save(mainIni, config_path)
        return 
    end

    if low:find("\235\238\230\232\235") then 
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myName = sampGetPlayerNickname(myId)
        
        if not clean:find(myName) then
            local putAmmo = clean:match("(%d+)")
            if putAmmo then
                local val = tonumber(putAmmo)
                if low:find("deagle") then mainIni.safe.de = mainIni.safe.de + val
                elseif low:find("m4") then mainIni.safe.m4 = mainIni.safe.m4 + val
                elseif low:find("ak") then mainIni.safe.ak = mainIni.safe.ak + val
                elseif low:find("rifle") then mainIni.safe.ri = mainIni.safe.ri + val
                end
                inicfg.save(mainIni, config_path)
            end
        end
    end
end
