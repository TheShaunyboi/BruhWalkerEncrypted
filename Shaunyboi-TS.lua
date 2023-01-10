local TargetSelector = {}
local collision = _G.Prediction
local forced_target = nil
local targetSelection = nil
local ts_loaded = package.loaded["Shaunyboi-TS"]
local myHero = game.local_player

function TargetSelector:new(spell_data, checkCollision)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.checkCollision = checkCollision
    o.spell_data = spell_data
    o.selectedTarget = nil
    o.collidingTargets = {}
    o.remainingTargets = {}
    return o
end

function TargetSelector:GetEnemyHeroes()
    local _EnemyHeroes = {}
    players = game.players
    for i, unit in ipairs(players) do
        if unit and unit.is_enemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

function TargetSelector:SortByDistanceToMouse(targets)
    table.sort(targets, function(a, b) return GetDistanceToMouse(a) < GetDistanceToMouse(b) end)
    return targets
end
  
function GetDistanceToMouse(unit)
    local mousePos = game.mouse_pos
    if unit and mousePos then
        local dx = unit.origin.x - mousePos.x
        local dz = (unit.origin.z or unit.origin.y) - (mousePos.z or mousePos.y)
        return math.sqrt(dx * dx + dz * dz)
    else
        return math.huge
    end
end

local isMouseButtonDown = false
function on_wnd_proc(msg, wparam)
    if msg == 513 and wparam == 1 then
        isMouseButtonDown = true
    elseif msg == 514 and wparam == 0 then
        isMouseButtonDown = false
    end
end

function isValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

function SelectionMethod()
    if menu:get_value(ts_method_selection) == 0 then
        selection = "TARGET_LOW_HP_PRIORITY"
    elseif menu:get_value(ts_method_selection) == 1 then
        selection = "TARGET_MOST_AP"
    elseif menu:get_value(ts_method_selection) == 2 then
        selection = "TARGET_MOST_AD"
    elseif menu:get_value(ts_method_selection) == 3 then
        selection = "TARGET_NEAR_MOUSE"
    elseif menu:get_value(ts_method_selection) == 4 then
        selection = "TARGET_PRIORITY"
    end
    return selection
end

function TargetSelector:GetPriority(champion)
    -- Returns the priority of the given champion
    local priority = {

    ["Aatrox"] = 3, ["Ahri"] = 4, ["Akali"] = 4, ["Akshan"] = 5, ["Alistar"] = 1,
    ["Amumu"] = 1, ["Anivia"] = 4, ["Annie"] = 4, ["Aphelios"] = 5, ["Ashe"] = 5,
    ["AurelionSol"] = 4, ["Azir"] = 4, ["Bard"] = 3, ["Belveth"] = 3, ["Blitzcrank"] = 1,
    ["Brand"] = 4, ["Braum"] = 1, ["Caitlyn"] = 5, ["Camille"] = 4, ["Cassiopeia"] = 4,
    ["Chogath"] = 1, ["Corki"] = 5, ["Darius"] = 2, ["Diana"] = 4, ["DrMundo"] = 1,
    ["Draven"] = 5, ["Ekko"] = 4, ["Elise"] = 3, ["Evelynn"] = 4, ["Ezreal"] = 5,
    ["FiddleSticks"] = 3, ["Fiora"] = 4, ["Fizz"] = 4, ["Galio"] = 1, ["Gangplank"] = 4,
    ["Garen"] = 1, ["Gnar"] = 1, ["Gragas"] = 2, ["Graves"] = 4, ["Gwen"] = 3,
    ["Hecarim"] = 2, ["Heimerdinger"] = 3, ["Illaoi"] = 3, ["Irelia"] = 3,
    ["Ivern"] = 1, ["Janna"] = 2, ["JarvanIV"] = 3, ["Jax"] = 3, ["Jayce"] = 4,
    ["Jhin"] = 5, ["Jinx"] = 5, ["Kaisa"] = 5, ["Kalista"] = 5, ["Karma"] = 4,
    ["Karthus"] = 4, ["Kassadin"] = 4, ["Katarina"] = 4, ["Kayle"] = 4, ["Kayn"] = 4,
    ["Kennen"] = 4, ["Khazix"] = 4, ["Kindred"] = 4, ["Kled"] = 2, ["KogMaw"] = 5,
    ["Leblanc"] = 4, ["LeeSin"] = 3, ["Leona"] = 1, ["Lillia"] = 4, ["Lissandra"] = 4,
    ["Lucian"] = 5, ["Lulu"] = 3, ["Lux"] = 4, ["Malphite"] = 1, ["Malzahar"] = 3,
    ["Maokai"] = 2, ["MasterYi"] = 5, ["MissFortune"] = 5, ["MonkeyKing"] = 3,
    ["Mordekaiser"] = 4, ["Morgana"] = 3, ["Nami"] = 3, ["Nasus"] = 2, ["Nautilus"] = 1,
    ["Neeko"] = 4, ["Nidalee"] = 4, ["Nilah"] = 5, ["Nocturne"] = 4, ["Nunu"] = 2,
    ["Olaf"] = 2, ["Orianna"] = 4, ["Ornn"] = 2, ["Pantheon"] = 3, ["Poppy"] = 2,
    ["Pyke"] = 4, ["Qiyana"] = 4, ["Quinn"] = 5, ["Rakan"] = 3, ["Rammus"] = 1,
    ["RekSai"] = 2, ["Rell"] = 5, ["Renata"] = 3, ["Renekton"] = 2, ["Rengar"] = 4,
    ["Riven"] = 4, ["Rumble"] = 4, ["Ryze"] = 4, ["Samira"] = 5, ["Sejuani"] = 2,
    ["Senna"] = 5, ["Seraphine"] = 4, ["Sett"] = 2, ["Shaco"] = 4, ["Shen"] = 1,
    ["Shyvana"] = 2, ["Singed"] = 1, ["Sion"] = 1, ["Sivir"] = 5, ["Skarner"] = 2,
    ["Sona"] = 3, ["Soraka"] = 4, ["Swain"] = 3, ["Sylas"] = 4, ["Syndra"] = 4,
    ["TahmKench"] = 1, ["Taliyah"] = 4, ["Talon"] = 4, ["Taric"] = 1, ["Teemo"] = 4,
    ["Thresh"] = 1, ["Tristana"] = 5, ["Trundle"] = 2, ["Tryndamere"] = 4,
    ["TwistedFate"] = 4, ["Twitch"] = 5, ["Udyr"] = 2, ["Urgot"] = 2, ["Varus"] = 5,
    ["Vayne"] = 5, ["Veigar"] = 4, ["Velkoz"] = 4, ["Vex"] = 4, ["Vi"] = 2,
    ["Viego"] = 4, ["Viktor"] = 4, ["Vladimir"] = 3, ["Volibear"] = 2, ["Warwick"] = 2,
    ["Xayah"] = 5, ["Xerath"] = 4, ["Xinzhao"] = 3, ["Yasuo"] = 4, ["Yone"] = 4,
    ["Yorick"] = 2, ["Yuumi"] = 2, ["Zac"] = 1, ["Zed"] = 4, ["Zeri"] = 5,
    ["Ziggs"] = 4, ["Zilean"] = 3, ["Zoe"] = 4, ["Zyra"] = 3

    }
    return priority[champion.champ_name] or math.huge
end

function TargetSelector:SortByPriority(targets)
    -- Sorts the given targets by priority
    table.sort(targets, function(a, b) return self:GetPriority(a) > self:GetPriority(b) end)
    return targets
end
    
function TargetSelector:SelectTarget(spell_data, checkCollision)
    
    -- Return selection method
    targetSelection = SelectionMethod()

    -- If we have no forced targets, run selection method
    if forced_target == nil then
        if targetSelection == "TARGET_LOW_HP_PRIORITY" then
            -- Select target with lowest HP & uses priority
            self.remainingTargets = self:GetEnemyHeroes()
            self.remainingTargets = self:SortByPriority(self.remainingTargets)
            self.validTargets = {}
            for i, target in ipairs(self.remainingTargets) do
                if isValid(target) and myHero:distance_to(target.origin) <= spell_data.range then
                    local c = collision:get_collision(spell_data, vec3.new(target.origin.x, target.origin.y, target.origin.z), target)
                    if (not checkCollision or next(c) == nil) then
                        table.insert(self.validTargets, target)
                    end
                end
            end
            table.sort(self.validTargets, function(a, b) return a.health < b.health end)
            self.selectedTarget = self.validTargets[1]

        elseif targetSelection == "TARGET_MOST_AP" then
            -- Select target with most AP & uses priority
            self.remainingTargets = self:GetEnemyHeroes()
            self.remainingTargets = self:SortByPriority(self.remainingTargets)
            self.validTargets = {}
            for i, target in ipairs(self.remainingTargets) do
                if isValid(target) and myHero:distance_to(target.origin) <= spell_data.range then
                    local c = collision:get_collision(spell_data, vec3.new(target.origin.x, target.origin.y, target.origin.z), target)
                    if (not checkCollision or next(c) == nil) then
                        table.insert(self.validTargets, target)
                    end
                end
            end
            table.sort(self.validTargets, function(a, b) return a.ability_power > b.ability_power end)
            self.selectedTarget = self.validTargets[1]

        elseif targetSelection == "TARGET_MOST_AD" then
            -- Select target with most AD & uses priority
            self.remainingTargets = self:GetEnemyHeroes()
            self.remainingTargets = self:SortByPriority(self.remainingTargets)
            self.validTargets = {}
            for i, target in ipairs(self.remainingTargets) do
                if isValid(target) and myHero:distance_to(target.origin) <= spell_data.range then
                    local c = collision:get_collision(spell_data, vec3.new(target.origin.x, target.origin.y, target.origin.z), target)
                    if (not checkCollision or next(c) == nil) then
                        table.insert(self.validTargets, target)
                    end
                end
            end
            table.sort(self.validTargets, function(a, b) return a.total_attack_damage > b.total_attack_damage end)
            self.selectedTarget = self.validTargets[1]

        elseif targetSelection == "TARGET_NEAR_MOUSE" then
            -- Select target closest to mouse cursor
            self.remainingTargets = self:GetEnemyHeroes()
            self.remainingTargets = self:SortByDistanceToMouse(self.remainingTargets)
            self.validTargets = {}
            for i, target in ipairs(self.remainingTargets) do
                if isValid(target) and myHero:distance_to(target.origin) <= spell_data.range then
                    local c = collision:get_collision(spell_data, vec3.new(target.origin.x, target.origin.y, target.origin.z), target)
                    if (not checkCollision or next(c) == nil) then
                        table.insert(self.validTargets, target)
                    end
                end
            end
            self.selectedTarget = self.validTargets[1]

        elseif targetSelection == "TARGET_PRIORITY" then
            -- Select target with highest priority
            self.remainingTargets = self:GetEnemyHeroes()
            self.remainingTargets = self:SortByPriority(self.remainingTargets)
            self.validTargets = {}
            for i, target in ipairs(self.remainingTargets) do
                if isValid(target) and myHero:distance_to(target.origin) <= spell_data.range then
                    local c = collision:get_collision(spell_data, vec3.new(target.origin.x, target.origin.y, target.origin.z), target)
                    if (not checkCollision or next(c) == nil) then
                        table.insert(self.validTargets, target)
                    end
                end
            end
            self.selectedTarget = self.validTargets[1]
        end
    end

    -- Select target based off left mouse click if menu option is enabled
    if menu:get_value(ts_force) == 1 and isMouseButtonDown then
        self.remainingTargets = self:GetEnemyHeroes()
        self.validTargets = {}
        for i, target in ipairs(self.remainingTargets) do
            if GetDistanceToMouse(target) < 150 then        
                table.insert(self.validTargets, target)
            end
        end
        self.selectedTarget = self.validTargets[1]
        forced_target = self.selectedTarget
    end

    if forced_target ~= nil then
        local disable_range = spell_data.range + 150
        if myHero:distance_to(forced_target.origin) >= disable_range or not isValid(forced_target) then
            forced_target = nil 
        end
    end

    -- Draw target selected if menu option is enabled
    if self.selectedTarget and menu:get_value(ts_draw) == 1 then 
        renderer:draw_circle(self.selectedTarget.origin.x, self.selectedTarget.origin.y, self.selectedTarget.origin.z, 50, 0, 255, 255, 255)
    end

    return self.selectedTarget
end

do
    local function Update()
		local version = 0.1
		local file_name = "Shaunyboi-TS.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shaunyboi-TS.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shaunyboi-TS.lua.version.txt")
		if tonumber(web_version) ~= version then
            console:log("Shaunyboi Target Selector Updated")
            console:log("Please Reload via F5")
        end
    end
    Update()
end

if ts_loaded then
    console:log("[Shaun's Target Selector] Initiated Successfully")

    if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
        ts_category = menu:add_category_sprite("Shaun's Target Selector", "Shaun's Sexy Common//Logo.png")
    else
        http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
        ts_category = menu:add_category("Shaun's Target Selector")
    end

    ts_method = menu:add_subcategory("Target Selection Methods", ts_category)
    m_table = {}
    m_table[1] = "Lowest Health & Prioity Sorting"
    m_table[2] = "Most AP & Champion Prioity Sorting"
    m_table[3] = "Most AD & Champion Prioity Sorting"
    m_table[4] = "Closest To Mouse Position"
    m_table[5] = "Champion Prioity Sorting Only"
    ts_method_selection = menu:add_dropdown("Method Selection", ts_method, m_table, 0)

    ts_force = menu:add_checkbox("Use Left Click Force", ts_category, 1)
    ts_draw = menu:add_checkbox("Draw Selected Target", ts_category, 1)
end

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark Prediction Library Downloaded")
   console:log("Please Reload via F5")
end

client:set_event_callback("on_wnd_proc", on_wnd_proc)
return TargetSelector
 
