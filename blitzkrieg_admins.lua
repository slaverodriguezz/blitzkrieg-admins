script_name("blitzkrieg admins")
script_author("slave_rodriguez")
script_version("3.1")

require "lib.moonloader"
local sampev = require "lib.samp.events"
local requests = require("requests")

local SCRIPT_VERSION = "3.1" 
local SCRIPT_URL = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/blitzkrieg_admins.lua"
local SCRIPT_PATH = getWorkingDirectory() .. "\\blitzkrieg_admins.lua"
local textColor = "{F5DEB3}"

function checkForUpdates()
    local response = requests.get(SCRIPT_URL)

    if response and response.status_code == 200 then
        local newScript = response.text
        local newVersion = newScript:match('SCRIPT_VERSION%s*=%s*"([%d%.]+)"')

        if newVersion and newVersion ~= SCRIPT_VERSION then
            local f = io.open(SCRIPT_PATH, "w+")
            if f then
                f:write(newScript)
                f:close()
                sampAddChatMessage("{00FF00}[blitzkrieg] Update downloaded! Restart SAMP to apply (new version: " .. newVersion .. ")", -1)
            else
                sampAddChatMessage("{FF0000}[blitzkrieg] Failed to write new script version to disk: " .. SCRIPT_PATH, -1)
            end
        else
            sampAddChatMessage("{3A4FFC}[blitzkrieg] No updates found. You are using the latest version (" .. SCRIPT_VERSION .. ")", -1)
        end
    else
        local code = response and response.status_code or "nil"
        sampAddChatMessage("{FF0000}[blitzkrieg] Update check failed. HTTP code: " .. tostring(code), -1)
    end
end

local admins = {
    ["Jonny_Wilson"] = 10, ["Jeysen_Prado"] = 10, ["Maxim_Kudryavtsev"] = 10, ["Salvatore_Giordano"] = 10,
    ["Diego_Serrano"] = 10, ["Gosha_Fantom"] = 10, ["Tobey_Marshall"] = 10, ["Impressive_Plitts"] = 5,
    ["Quentin_Qween"] = 10, ["Jayson_Frenks"] = 10, ["Danya_Korolyov"] = 10, ["Sergo_Cross"] = 10,
    ["Trojan_Dev"] = 10, ["Kostya_Vlasov"] = 10, ["Game_Birds"] = 10, ["Aleksey_Efimenko"] = 7,
    ["Test_Evlv"] = 8, ["Domenick_Jackson"] = 8, ["Fernando_Bennet"] = 6,
    ["Egor_Ufimtsev"] = 6, ["Daniel_Salaru"] = 6, ["Wilion_Walker"] = 5, ["Rikuto_Yashida"] = 5,
    ["Aleksei_Kuznetcov"] = 5, ["Anthony_Cerezo"] = 5, ["Niko_Filliams"] = 5,
    ["Ramon_Morettie"] = 5, ["Alessandro_Carrasco"] = 5, ["Midzuki_Cerezo"] = 3,
    ["Kwenyt_Joestar"] = 3, ["Absolutely_Sawide"] = 5, ["Oruto_Matsushima"] = 5,
    ["Michael_Rojas"] = 6, ["Marco_Mazzini"] = 5, ["Edward_Thawne"] = 5, ["Mayu_Sakura"] = 5,
    ["Donatello_Ross"] = 5, ["Cody_Flatcher"] = 5, ["Carlo_Barbero"] = 5, ["Ruslan_Satriano"] = 5,
    ["Kennedy_Oldridge"] = 5, ["Andrew_Sheredega"] = 5, ["Jesus_Rubin"] = 3,
    ["Faust_Casso"] = 3, ["Yuliya_Ermak"] = 5, ["Mickey_Marryman"] = 5,
    ["Jayden_Henderson"] = 5, ["Arteezy_Adalwolff"] = 5, ["Mayson_Wilson"] = 5, ["Denis_MacTavish"] = 5,
    ["Laurent_Lemieux"] = 5, ["Simon_Frolov"] = 5, ["Dimentii_Lazarev"] = 5, ["Sandy_Blum"] = 5, 
    ["Yaroslav_Yarkin"] = 5, ["Kira_Yukimura"] = 5, ["Gracie_Ludvig"] = 5, ["Artem_Rosenberg"] = 5, 
    ["Emmett_Hoggarth"] = 5, ["Temik_Attano"] = 1, ["Chapa_Winx"] = 1, ["Calvin_Broadus"] = 1, 
    ["Rabbit_Tomioka"] = 1, ["Shiro_Mercedez"] = 1, ["Christian_Moon"] = 1, ["Aitesu_Matsumoto"] = 1, 
    ["William_Bueno"] = 4, ["Nate_River"] = 4, ["Kasper_Whiter"] = 3
}

function main()
    repeat wait(0) until isSampAvailable()

    sampRegisterChatCommand("badmins", cmd_badmins)
    sampRegisterChatCommand("offadmins", cmd_offadmins)
    sampRegisterChatCommand("fcadmins", cmd_fcadmins)
    sampRegisterChatCommand("update", function()
        sampAddChatMessage("{3A4FFC}[blitzkrieg] Checking for updates...", -1)
        checkForUpdates()
    end)

    sampAddChatMessage("{3A4FFC}[blitzkrieg] {F5DEB3}admins checker loaded | author: {3A4FFC}slave_rodriguez", -1)

    wait(5000)
    checkForUpdates()

    wait(-1)
end

function cmd_badmins()
    local result = {}
    local playerCount = sampGetMaxPlayerId(false)
    for i = 0, playerCount do
        if sampIsPlayerConnected(i) then
            local name = sampGetPlayerNickname(i)
            if admins[name] then
                table.insert(result, {name = name, id = i, level = admins[name]})
            end
        end
    end

    table.sort(result, function(a, b)
        return a.level > b.level
    end)

    if #result > 0 then
        sampAddChatMessage("{FFFF00}Admins online: {FFFFFF}" .. #result, -1)
        for _, admin in ipairs(result) do
            sampAddChatMessage(string.format("%s%s | ID: %d | Level: %d", textColor, admin.name, admin.id, admin.level), -1)
        end
    else
        sampAddChatMessage("{FFFF00}No admins online.", -1)
    end
end

function cmd_offadmins()
    local result = {}
    for name, level in pairs(admins) do
        table.insert(result, {name = name, level = level})
    end
    table.sort(result, function(a, b)
        return a.level > b.level
    end)
    local dialogText = ""
    for _, admin in ipairs(result) do
        dialogText = dialogText .. string.format("%s | Level: %d\n", admin.name, admin.level)
    end
    sampShowDialog(1234, "blitzkrieg | admins list", dialogText, "Close", "", 0)
end

function cmd_fcadmins()
    local adminIds = {}
    local playerCount = sampGetMaxPlayerId(false)
    
    for i = 0, playerCount do
        if sampIsPlayerConnected(i) then
            local name = sampGetPlayerNickname(i)
            if admins[name] then
                table.insert(adminIds, tostring(i))
            end
        end
    end

    if #adminIds == 0 then
        sampAddChatMessage("{FFFF00}[blitzkrieg] No admins online.", -1)
        return
    end

    local allIds = table.concat(adminIds, ", ")
    sampSendChat("/fc Admins online: " .. allIds)
end



