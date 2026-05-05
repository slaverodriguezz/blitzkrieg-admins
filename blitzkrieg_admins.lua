script_name("blitzkrieg admins")
script_author("slave_rodriguez")
script_version("3.6")

require "lib.moonloader"
local sampev = require "lib.samp.events"
local requests = require("requests")

local SCRIPT_VERSION = "3.6" 
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
    ["Egor_Ufimtsev"] = 6, ["Wilion_Walker"] = 5, ["Cody_Fletcher"] = 5, 
    ["Aleksei_Kuznetcov"] = 5, ["Carlo_Barbero"] = 5, ["Emmett_Hoggarth"] = 5, ["Impressive_Plitts"] = 5, 
    ["Gracie_Ludvig"] = 5, ["Kira_Yukimura"] = 5, ["Rikuto_Yashida"] = 5, ["Ramon_Morettie"] = 5, 
    ["Sandy_Blum"] = 5, ["Edward_Thawne"] = 5, ["Mayu_Sakura"] = 5, ["Jayden_Henderson"] = 5, 
    ["Marco_Mazzini"] = 5, ["Yuliya_Ermak"] = 5, ["Faust_Casso"] = 5, ["Christian_Moon"] = 5, 
    ["Aitesu_Matsumoto"] = 5, ["Willka_Plitts"] = 5, ["Nate_River"] = 5, ["Sara_Chelsey"] = 5, 
    ["Fudo_Hasegawa"] = 5, ["Thomas_Basters"] = 4, ["Vadim_Kudo"] = 4, ["Sashenka_Yakovlev"] = 4, 
    ["Danya_Karpin"] = 5, ["Scandal_Benedict"] = 4, ["Hideo_Kadzima"] = 4, ["Marius_Kronberger"] = 4, 
    ["Dmitriy_Renaisssance"] = 4, ["Nicolas_Himbers"] = 4, ["Christopher_Juarez"] = 3, ["Nikitos_Suvorov"] = 2, 
    ["Camel_Plitts"] = 2, ["Bartolo_Correnti"] = 2, ["Franco_Furry"] = 2, ["Screamo_Meow"] = 2, 
    ["Ruslan_Shagenov"] = 2, ["Brady_Tracey"] = 2, ["Kery_Gagarin"] = 2, ["Inti_Kion"] = 2,
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







