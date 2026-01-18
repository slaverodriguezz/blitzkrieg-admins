script_name("blitzkrieg admins")
script_author("slave_rodriguez")
script_version("1.8")

require "lib.moonloader"
local sampev = require "lib.samp.events"
local imgui = require 'imgui'
local requests = require("requests")

local SCRIPT_VERSION = "1.8" 
local SCRIPT_URL = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/blitzkrieg_admins.lua"
local SCRIPT_PATH = getWorkingDirectory() .. "\\blitzkrieg_admins.lua"
local textColor = "{F5DEB3}"
local mainColor = imgui.ImVec4(0.25, 0.22, 0.98, 1.0) -- #3F37FA (в формате RGBA)

-- UI vars
local window = imgui.ImBool(false)
local searchQuery = imgui.ImBuffer(64)

-- Админы
local admins = {
    ["Jonny_Wilson"] = 10, ["Jeysen_Prado"] = 10, ["Maxim_Kudryavtsev"] = 10, ["Salvatore_Giordano"] = 10,
    ["Diego_Serrano"] = 10, ["Gosha_Fantom"] = 10, ["Tobey_Marshall"] = 10, ["Impressive_Plitts"] = 5,
    ["Quentin_Qween"] = 10, ["Jayson_Frenks"] = 10, ["Danya_Korolyov"] = 10, ["Sergo_Cross"] = 10,
    ["Trojan_Dev"] = 10, ["Kostya_Vlasov"] = 10, ["Game_Birds"] = 10, ["Aleksey_Efimenko"] = 5,
    ["Test_Evlv"] = 8, ["Domenick_Jackson"] = 8, ["Homka_Daxwell"] = 5, ["Fernando_Bennet"] = 6,
    ["Egor_Ufimtsev"] = 6, ["Daniel_Salaru"] = 6, ["Wilion_Walker"] = 5, ["Rikuto_Yashida"] = 5,
    ["Aleksei_Kuznetcov"] = 5, ["Anthony_Cerezo"] = 5, ["Pabloz_Hernandezx"] = 5, ["Niko_Filliams"] = 5,
    ["Avgustique_Unhoped"] = 5, ["Ramon_Morettie"] = 5, ["Alessandro_Carrasco"] = 4, ["Midzuki_Cerezo"] = 3,
    ["Kwenyt_Joestar"] = 3, ["Absolutely_Sawide"] = 4, ["Oruto_Matsushima"] = 4, ["Anthony_Morrow"] = 5,
    ["Michael_Rojas"] = 6, ["Marco_Mazzini"] = 5, ["Edward_Thawne"] = 5, ["Mayu_Sakura"] = 5,
    ["Donatello_Ross"] = 5, ["Cody_Flatcher"] = 5, ["Carlo_Barbero"] = 5, ["Ruslan_Satriano"] = 5,
    ["Kennedy_Oldridge"] = 5, ["Andrew_Sheredega"] = 5, ["Jack_Gastro"] = 3, ["Jesus_Rubin"] = 3,
    ["Faust_Casso"] = 3, ["Bobby_Shmurda"] = 3, ["Yuliya_Ermak"] = 4, ["Mickey_Marryman"] = 4,
    ["Jayden_Henderson"] = 5, ["Arteezy_Adalwolff"] = 5, ["Mayson_Wilson"] = 5, ["Denis_MacTavish"] = 5,
    ["Laurent_Lemieux"] = 5, ["Simon_Frolov"] = 5, ["Dimentii_Lazarev"] = 5, ["Jagermeister_Orazov"] = 5,
    ["Sandy_Blum"] = 5, ["Yaroslav_Yarkin"] = 5, ["Kira_Yukimura"] = 5, ["Gracie_Ludvig"] = 5,
    ["Artem_Rosenberg"] = 5, ["Lauren_Vandom"] = 5, ["Emmett_Hoggarth"] = 5, ["Kasper_Whiter"] = 3
}

-- Проверка обновлений
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

-- Основная функция
function main()
    repeat wait(0) until isSampAvailable()

    sampRegisterChatCommand("badmins", cmd_badmins)
    sampRegisterChatCommand("offadmins", function() window.v = not window.v end)
    sampRegisterChatCommand("update", function()
        sampAddChatMessage("{3A4FFC}[blitzkrieg] Checking for updates...", -1)
        checkForUpdates()
    end)

    sampAddChatMessage("{3A4FFC}[blitzkrieg] {F5DEB3}admins checker loaded | author: {3A4FFC}slave_rodriguez", -1)
    wait(3000)
    checkForUpdates()

    while true do
        wait(0)
        imgui.Process = window.v
    end
end

-- Команда /badmins (онлайн-админы)
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

-- Рисуем IMGUI окно
function imgui.OnDrawFrame()
    if not window.v then return end

    imgui.SetNextWindowSize(imgui.ImVec2(520, 500), imgui.Cond.FirstUseEver)
    imgui.Begin("Blitzkrieg Admins", window, imgui.WindowFlags.NoCollapse)

    imgui.TextColored(mainColor, string.format("Blitzkrieg Admins List  v%s", SCRIPT_VERSION))
    imgui.Separator()

    imgui.PushItemWidth(250)
    imgui.InputTextWithHint("##search", "Search admin...", searchQuery, 64)
    imgui.SameLine()
    if imgui.Button("Clear") then searchQuery.v = "" end
    imgui.PopItemWidth()

    imgui.Spacing()
    imgui.Columns(2, nil, true)
    imgui.TextColored(mainColor, "Name")
    imgui.NextColumn()
    imgui.TextColored(mainColor, "Level")
    imgui.NextColumn()
    imgui.Separator()

    -- Список с фильтром
    local adminsList = {}
    for name, level in pairs(admins) do
        if searchQuery.v == "" or name:lower():find(searchQuery.v:lower()) then
            table.insert(adminsList, {name = name, level = level})
        end
    end

    table.sort(adminsList, function(a, b)
        return a.level > b.level
    end)

    for _, a in ipairs(adminsList) do
        imgui.Text(a.name)
        imgui.NextColumn()
        imgui.TextColored(mainColor, tostring(a.level))
        imgui.NextColumn()
    end

    if #adminsList == 0 then
        imgui.TextColored(imgui.ImVec4(1, 0.4, 0.4, 1), "No admins found.")
    end

    imgui.Columns(1)
    imgui.End()
end
