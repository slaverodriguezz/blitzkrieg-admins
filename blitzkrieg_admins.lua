script_name("blitzkrieg admins")
script_author("slave_rodriguez")
script_version("2.3")

require "lib.moonloader"
local imgui = require 'mimgui'
local ffi = require 'ffi'
local encoding = require 'encoding'
local requests = require("requests")

encoding.default = 'CP1251'
local u8 = encoding.UTF8
й
local SCRIPT_VERSION = "2.3" 
local SCRIPT_URL = "https://raw.githubusercontent.com/slaverodriguezz/blitzkrieg-admins/main/blitzkrieg_admins.lua"
local SCRIPT_PATH = getWorkingDirectory() .. "\\blitzkrieg_admins.lua"
local textColor = "{F5DEB3}"

local renderWindow = imgui.new.bool(false)
local searchBuffer = imgui.new.char[256]('')

local admins = {
    ["Jonny_Wilson"] = 10, ["Jeysen_Prado"] = 10, ["Maxim_Kudryavtsev"] = 10, ["Salvatore_Giordano"] = 10,
    ["Diego_Serrano"] = 10, ["Gosha_Fantom"] = 10, ["Tobey_Marshall"] = 10, ["Impressive_Plitts"] = 5,
    ["Quentin_Qween"] = 10, ["Jayson_Frenks"] = 10, ["Danya_Korolyov"] = 10, ["Sergo_Cross"] = 10,
    ["Trojan_Dev"] = 10, ["Kostya_Vlasov"] = 10, ["Game_Birds"] = 10, ["Aleksey_Efimenko"] = 7,
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
    ["Laurent_Lemieux"] = 5, ["Simon_Frolov"] = 5, ["Dimentii_Lazarev"] = 5, ["Sandy_Blum"] = 5, 
    ["Yaroslav_Yarkin"] = 5, ["Kira_Yukimura"] = 5, ["Gracie_Ludvig"] = 5, ["Artem_Rosenberg"] = 5, 
    ["Lauren_Vandom"] = 5, ["Emmett_Hoggarth"] = 5, ["Kasper_Whiter"] = 3
}


local sortedAdmins = {}
for name, level in pairs(admins) do
    table.insert(sortedAdmins, {name = name, level = level})
end
table.sort(sortedAdmins, function(a, b)
    if a.level ~= b.level then return a.level > b.level end
    return a.name < b.name
end)


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
                sampAddChatMessage(u8:decode("{00FF00}[blitzkrieg] Обновление скачано! Перезапустите игру (новая версия: " .. newVersion .. ")"), -1)
            end
        end
    end
end


function getPlayerIdByName(targetName)
    for i = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(i) then
            if sampGetPlayerNickname(i) == targetName then return i end
        end
    end
    return nil
end

function main()
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("badmins", cmd_badmins)
    sampRegisterChatCommand("adminsoff", function() renderWindow[0] = not renderWindow[0] end)
    sampRegisterChatCommand("update", function()
        sampAddChatMessage(u8:decode("{3A4FFC}[blitzkrieg] Проверка обновлений..."), -1)
        checkForUpdates()
    end)

    sampAddChatMessage(u8:decode("{3A4FFC}[blitzkrieg] {F5DEB3}admins checker загружен. Команды: /badmins и /adminsoff | author: {3A4FFC}slave_rodriguez"), -1)

    lua_thread.create(function()
        wait(5000)
        checkForUpdates()
    end)

    wait(-1)
end

function cmd_badmins()
    local result = {}
    for i = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(i) then
            local name = sampGetPlayerNickname(i)
            if admins[name] then
                table.insert(result, {name = name, id = i, level = admins[name]})
            end
        end
    end
    table.sort(result, function(a, b) return a.level > b.level end)
    if #result > 0 then
        sampAddChatMessage(u8:decode("{F5DEB3}Админы онлайн: {FFFFFF}") .. #result, -1)
        for _, admin in ipairs(result) do
            sampAddChatMessage(string.format("%s%s | ID: %d | Level: %d", textColor, admin.name, admin.id, admin.level), -1)
        end
    else
        sampAddChatMessage(u8:decode("{F5DEB3}Сейчас нет админов онлайн."), -1)
    end
end

function drawSection(label, min, max, filter)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.8, 0.2, 1.0))
    imgui.Text(label)
    imgui.PopStyleColor()
    imgui.Separator()
    local count = 0
    for _, admin in ipairs(sortedAdmins) do
        if admin.level >= min and admin.level <= max then
            if filter == "" or admin.name:lower():find(filter:lower(), 1, true) then
                local color = imgui.ImVec4(1, 1, 1, 1)
                if admin.level >= 8 then color = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)
                elseif admin.level >= 6 then color = imgui.ImVec4(0.0, 0.5, 0.0, 1.0)
                elseif admin.level >= 3 then color = imgui.ImVec4(0.0, 1.0, 0.0, 1.0)
                elseif admin.level >= 1 then color = imgui.ImVec4(1.0, 0.6, 0.0, 1.0) end
                imgui.TextColored(color, string.format("[%d]", admin.level))
                imgui.SameLine()
                if imgui.Selectable(admin.name .. "##" .. admin.level, false, 0, imgui.ImVec2(150, 0)) then
                    setClipboardText(admin.name)
                    sampAddChatMessage(u8:decode("{FFFF00}[AdminList] {FFFFFF}Ник {33AA33}" .. admin.name .. " {FFFFFF}скопирован."), -1)
                end
                imgui.SameLine(220)
                local id = getPlayerIdByName(admin.name)
                if id then imgui.TextColored(imgui.ImVec4(0.0, 1.0, 0.0, 1.0), "Online ["..id.."]")
                else imgui.TextDisabled("Offline") end
                count = count + 1
            end
        end
    end
    imgui.Spacing()
end

imgui.OnFrame(function() return renderWindow[0] end,
function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(450, 500), imgui.Cond.FirstUseEver)
    if imgui.Begin(u8"Список администрации Evolve RP", renderWindow) then
        imgui.Text(u8"Поиск:")
        imgui.SameLine()
        imgui.PushItemWidth(-1)
        imgui.InputText("##search", searchBuffer, 256)
        imgui.PopItemWidth()
        imgui.Separator()
        imgui.BeginChild("scroll_area")
        local filter = ffi.string(searchBuffer)
        drawSection(u8"Специальная администрация / разработчики (8-10 lvl)", 8, 10, filter)
        drawSection(u8"Старшая администрация (6-7 lvl)", 6, 7, filter)
        drawSection(u8"Администрация сервера (1-5 lvl)", 1, 5, filter)
        imgui.EndChild()
        imgui.End()
    end
end)

local lastState = false
lua_thread.create(function()
    while true do
        wait(0)
        if renderWindow[0] ~= lastState then
            showCursor(renderWindow[0], renderWindow[0])
            lastState = renderWindow[0]
        end
    end
end)
