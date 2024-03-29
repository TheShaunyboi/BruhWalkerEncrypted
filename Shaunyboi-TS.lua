local ts_loaded = package.loaded["Shaunyboi-TS"]
if not ts_loaded then return end

local menu_version = 0.7
local ShaunPred = require "ShaunPrediction"
local isMouseButtonDown = false
local forced_target = nil
local clickedForced = nil
local targetSelection = nil
local menu_draw = nil
local myHero = game.local_player

local TargetSelector = {}
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

function TargetSelector:new(spell_data, checkCollision, pred)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.pred = pred or false
    o.checkCollision = checkCollision
    o.spell_data = spell_data
    o.pred_output = nil
    return o
end

function TargetSelector:GetEnemyHeroes()
    local enemyHeroes = {}
    players = game.players
    for i, unit in ipairs(players) do
        if unit and unit.is_enemy then
            table.insert(enemyHeroes, unit)
        end
    end
    return enemyHeroes
end

function TargetSelector:SortByDistanceToMouse(targets)
    table.sort(targets, function(a, b) return self:GetDistanceToMouse(a) < self:GetDistanceToMouse(b) end)
    return targets
end
  
function TargetSelector:GetDistanceToMouse(unit)
    local mousePos = game.mouse_pos
    if unit and mousePos then
        local dx = unit.origin.x - mousePos.x
        local dz = (unit.origin.z or unit.origin.y) - (mousePos.z or mousePos.y)
        return math.sqrt(dx * dx + dz * dz)
    else
        return math.huge
    end
end

function TargetSelector:isValid(unit)
    return unit and unit.is_enemy and unit.is_alive and unit.is_visible
end

function TargetSelector:SelectionMethod()
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

function TargetSelector:GetPriority(target)
    -- Returns the priority of the given champion
    return priority[target.champ_name] or 3
end

function TargetSelector:GetForcedTarget()
    -- Select target based off left mouse click if menu option is enabled
    if menu:get_value(ts_force) == 0 then return nil end

    if isMouseButtonDown and not clickedForced then
        for _, target in ipairs(self:GetEnemyHeroes()) do
            if self:GetDistanceToMouse(target) <= 150 then        
                clickedForced = target
                return target
            end
        end
    end

    if clickedForced then
        if (not myHero.is_alive or not clickedForced.is_visible) then
            clickedForced = nil 
            return nil
        end
        if isMouseButtonDown and self:GetDistanceToMouse(clickedForced) > 150 then
            clickedForced = nil 
            return nil
        end
    end
    
    return clickedForced
end
    
function TargetSelector:SelectTarget(spell_data, checkCollision, pred)
    -- Return selection method
    targetSelection = self:SelectionMethod()
    forced_target = self:GetForcedTarget()

    -- If we have forced targets
    if forced_target and myHero:distance_to(forced_target.origin) <= spell_data.range then
        menu_draw = forced_target
        return forced_target, (pred and ShaunPred:calculatePrediction(forced_target, spell_data, myHero) or nil)
    end

    -- Select target based on target selection method
    local targets = self:GetEnemyHeroes()
    if targetSelection == "TARGET_LOW_HP_PRIORITY" then
        table.sort(targets, function(a, b)
            if a.health ~= b.health then
                return a.health < b.health
            else
                return self:GetPriority(a) > self:GetPriority(b)
            end
        end)
    elseif targetSelection == "TARGET_MOST_AP" then
        table.sort(targets, function(a, b)
            if a.ability_power ~= b.ability_power then
                return a.ability_power > b.ability_power
            else
                return self:GetPriority(a) > self:GetPriority(b)
            end
        end)
    elseif targetSelection == "TARGET_MOST_AD" then
        table.sort(targets, function(a, b)
            if a.total_attack_damage ~= b.total_attack_damage then
                return a.total_attack_damage > b.total_attack_damage
            else
                return self:GetPriority(a) > self:GetPriority(b)
            end
        end)
    elseif targetSelection == "TARGET_NEAR_MOUSE" then
        table.sort(targets, function(a, b)
            if self:GetDistanceToMouse(a) ~= self:GetDistanceToMouse(b) then
                return self:GetDistanceToMouse(a) < self:GetDistanceToMouse(b)
            else
                return self:GetPriority(a) > self:GetPriority(b)
            end
        end)
    elseif targetSelection == "TARGET_PRIORITY" then
        table.sort(targets, function(a, b)
            return self:GetPriority(a) > self:GetPriority(b)
        end)
    end

    -- Select valid targets and return the highest priority valid target
    local validTargets = {}
    for i, target in ipairs(targets) do
        if self:isValid(target) and myHero:distance_to(target.origin) <= spell_data.range then
            if pred then
                local output = ShaunPred:calculatePrediction(target, spell_data, myHero)
                if output and output.castPos then
                    table.insert(validTargets, target)
                    self.pred_output = output
                end
            else
                local c = _G.Prediction:get_collision(spell_data, vec3.new(target.origin.x, target.origin.y, target.origin.z), target)
                if (not checkCollision or next(c) == nil) then
                    table.insert(validTargets, target)
                end
            end
        end
    end
    
    if #validTargets > 0 then
        menu_draw = validTargets[1]
        return validTargets[1], (self.pred_output or nil)
    end

    -- If no valid targets found, return nil
    return nil
end

if not _G.ShaunyTSInitialized then
    do
        local function Update()
            local version = 0.7
            local file_name = "Shaunyboi-TS.lua"
            local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shaunyboi-TS.lua"
            
            http:get_async("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shaunyboi-TS.lua.version.txt", function(success, web_version)
				if tonumber(web_version) == version then
                    console:log("[Shaun's Target Selector] Initiated Successfully")
				else
					http:download_file_async(url, file_name, function(success)
						if success then
                            console:log("Shaun's Target Selector Updated..")
                            console:log("Please reload via F5..")
						end
					end)
				end
			end)
        end
        Update()
    end

	if not file_manager:file_exists("Prediction.lib") then
        local file_name = "Prediction.lib"
        local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
		http:download_file_async(url, file_name,function()
            console:log("Ark Prediction Downloaded")
            console:log("Please Reload via F5")
		end)
	end

	if not file_manager:file_exists("ShaunPrediction.lua") then
        local file_name = "ShaunPrediction.lua"
        local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua"
		http:download_file_async(url, file_name,function()
            console:log("Shaun Prediction Downloaded")
            console:log("Please Reload via F5")
		end)
	end
end

if not _G.ShaunyTSInitialized then
    _G.ShaunyTSInitialized = true

    if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
        ts_category = menu:add_category_sprite("Shaun's Target Selector", "Shaun's Sexy Common//Logo.png")
    else
        http:download_file_async("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png", function()
        end)
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

    pred_menu = menu:add_subcategory("Shaun Prediction Hit Chance Filtering", ts_category)
    pred_filter = menu:add_slider("Minimum Target Selected Hit Chance", pred_menu, 1, 100, 45)

    ts_force = menu:add_checkbox("Use Left Click Force", ts_category, 1)
    ts_draw = menu:add_checkbox("Draw Selected Target", ts_category, 1)
    menu:add_label("Version "..tostring(menu_version), ts_category)
end

function on_draw()
    if menu:get_value(ts_draw) == 1 and menu_draw then 
        renderer:draw_circle(menu_draw.origin.x, menu_draw.origin.y, menu_draw.origin.z, 50, 0, 255, 255, 255)
    end
end

function on_wnd_proc(msg, wparam)
    if msg == 513 and wparam == 1 then
        isMouseButtonDown = true
    elseif msg == 514 and wparam == 0 then
        isMouseButtonDown = false
    end
end

client:set_event_callback("on_wnd_proc", on_wnd_proc)
client:set_event_callback("on_draw", on_draw)
return TargetSelector
 
