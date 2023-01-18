if game.local_player.champ_name ~= "Kaisa" then
	return
end

UpdateDraw = false
local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark Prediction Library Downloaded")
   console:log("Please Reload with F5")
   UpdateDraw = true
end

local file_name = "DreamPred.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://cdn.discordapp.com/attachments/805432133795053598/1063809376588144660/DreamPred.lib"
   http:download_file(url, file_name)
   console:log("Dream Prediction Library Downloaded")
   console:log("Please Reload with F5")
   UpdateDraw = true
end

local file_name = "DreamTS.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://cdn.discordapp.com/attachments/1062849023729471488/1062849023863685150/DreamTS.lib"
   http:download_file(url, file_name)
   console:log("Dream TS Library Downloaded")
   console:log("Please Reload with F5")
   UpdateDraw = true
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
	UpdateDraw = true
end

-- Custom auth lib - currently disabled
--[[local file_name = "md5.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua"
   http:download_file(url, file_name)
   console:log("Auth Lib Downloaded")
   console:log("Please Reload with F5")
   UpdateDraw = true
end]]
   
--[[local md5 = require 'md5'
function checkAuth(scriptId, scriptHash)
    local msg = "[LUA AUTH MANAGER] "
    local m = md5.new()
    m:update(client.id)
    m:update(scriptHash)
    local hash = md5.tohex(m:finish())
    local query = "/v1/api/authenticate?user_id=" .. client.id .. "&script_id=" .. scriptId
    response = http:get_ip("5.161.139.48", 3000, query)
    local tokens = Split(response, " ")
    if #tokens ~= 2 then 
        console:log(msg.."Auth Failed To Shaunyboi Scripts")
        return tostring("false"), 0
    elseif tokens[1] == hash then 
        console:log(msg.."Auth Success To Shaunyboi Scripts")
        return tostring("true"), tokens[2]   
    else 
        console:log(msg.."Auth Mismatch To Shaunyboi Scripts")
        return tostring("false"), 0 
    end     
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

authed, days = checkAuth("shaunyboiscripts", "e40402d3b5807213a14a1ee2ae3d22bc")
if authed == "true" and days == "lifetime" then
    console:log("You have a lifetime subscription")
elseif authed == "true" and tonumber(days) >= 500 then 
    console:log("You have 500+ days")
elseif authed == "true" then 
    console:log("You have "..days.." days remaining")
else
    console:log("You have 0 days remaining")
	return    
end]]

do
    local function Update()
		local version = 4.3
		local file_name = "OhAyKaisa.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/OhAyKaisa.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/OhAyKaisa.lua.version.txt")
        console:log("OhAyKaisa.lua Vers: "..version)
		console:log("OhAyKaisa.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == version then
            console:log("Shaun's Sexy Kaisa Successfully Loaded...")
    	else
			http:download_file(url, file_name)
			console:log("Sexy Kaisa Update available..")
			console:log("Please Reload via F5!..")
            UpdateDraw = true
        end
    end
    Update()
end

pred:use_prediction()
require "DreamPred"
require "PKDamageLib"
local DreamTS = require("DreamTS")
local ml = require "VectorMath"
local arkpred = _G.Prediction
local myHero = game.local_player

-- Ranges

local AA = { range = myHero.attack_range + myHero.bounding_radius }
local Q = { range = 600, delay = 0.1, width = 0, speed = 0 }
local W = { range = 3000, delay = 0.4, width = 200, speed = 1750 }
local E = { range = 0, delay = 0.1, width = 0, speed = 0 }
local R = { delay = 0.1, width = 0, speed = 0 }
local rRange = { 1500, 2250, 3000 }

-- Functions 

local function Ready(spell)
    return spellbook:can_cast(spell)
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	players = game.players
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

function IsValid(object, distance)
    return object and object.is_valid and object.is_enemy and
    not object:has_buff("SionPassiveZombie") and
    not object:has_buff("FioraW") and
    not object:has_buff("sivire") and
    not object:has_buff("nocturneshroudofdarkness") and
    object.is_alive and not object:has_buff_type(18) and
    not object:has_buff_type(16) and
    (not distance or object:distance_to(myHero.origin) <= distance)
end

local function GetDistanceSqr(unit, p2)
    p2 = p2.origin or myHero.origin
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1 = unit.origin
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

local function GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

local function GetEnemyCountCicular(range, p1)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(p1, unit.origin) < Range and
        IsValid(unit, Range) then
        count = count + 1
        end
    end
    return count
end

local function GetMinionCount(range, unit)
	count = 0
	minions = game.minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_enemy and IsValid(minion, Range) and 
            unit.object_id ~= minion.object_id and 
            GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

local function HasPassiveCount(unit)
    if unit:has_buff("kaisapassivemarker") then
        buff = unit:get_buff("kaisapassivemarker")
        if buff.count > 0 then
            return buff.count
        end
    end
    return 0
end

local function HasQBuff(unit)
	if unit:has_buff("KaisaQEvolved") then
		return true
	end
	return false
end

local function CheckQ()
	if HasQBuff(myHero) then
		return 9
	else
		return 5
	end
end

local function HasEBuff(unit)
	if unit:has_buff("KaisaE") then
		return true
	end
	return false
end

local function TargetIsIsolated(range, unit)
	count = 0
	minions = game.minions
	for i, minion in ipairs(minions) do
	    Range = range * range
		if minion.is_enemy and IsValid(minion, Range) and 
            unit.object_id ~= minion.object_id and 
            GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

local function IsImmobileTarget(unit)
    if unit:has_buff_type(5) or 
        unit:has_buff_type(8) or 
        unit:has_buff_type(10) or 
        unit:has_buff_type(11) or 
        unit:has_buff_type(21) or 
        unit:has_buff_type(22) or 
        unit:has_buff_type(24) or 
        unit:has_buff_type(29) then
        return true
    end
    return false
end

local function IsUnderTurret(unit)
    turrets = game.turrets
    for _, v in ipairs(turrets) do
        if v and v.is_enemy then
            local range = (v.bounding_radius / 2 + 775 + unit.bounding_radius / 2)
            if v.is_alive then
                if v:distance_to(unit.origin) < range then
                    return true
                end
            end
        end
    end
    return false
end

local function GetWDmg(unit)
	local Wdmg = getdmg("W", unit, myHero, 1)
	local W2dmg = getdmg("W", unit, myHero, 2)
	local buff = HasPassiveCount(unit)
	if buff and buff == 4 then
		return (Wdmg+W2dmg)
	else
		return Wdmg
	end
end

local function GetQDmg(unit)
	local count = GetEnemyCountCicular(600, unit.origin)
	local QDmg = getdmg("Q", unit, myHero)
	local QDmg2 = (CheckQ() * (getdmg("Q", unit, myHero)/100*25))
	if count >= 2 then
		return QDmg+(QDmg2/count)
	else
		return QDmg+QDmg2
	end
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	Kai_category = menu:add_category_sprite("Shaun's Sexy Kaisa", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	Kai_category = menu:add_category("Shaun's Sexy Kaisa")
end

Kai_enabled = menu:add_checkbox("Enabled", Kai_category, 1)
Kai_combokey = menu:add_keybinder("Combo Mode Key", Kai_category, 32)
menu:add_label("Shaun's Sexy Kaisa", Kai_category)
menu:add_label("#TheVoidMakesMeTingle", Kai_category)

TS =
   DreamTS(
	Kai_category,
   {
        Damage = DreamTS.Damages.AD
   }
)

Kai_pred = menu:add_subcategory("[Prediction Settings]", Kai_category)
p_table = {}
p_table[1] = "Dream"
p_table[2] = "Ark Pred"
Kai_pred_selection = menu:add_combobox("[Select Pred Options]", Kai_pred, p_table, 0)

c_table = {}
c_table[1] = "Very Slow"
c_table[2] = "Slow"
c_table[3] = "Fast"
Kai_pred_castrate = menu:add_combobox("[Dream Cast Rate]", Kai_pred, c_table, 1)

Kai_w_hitchance = menu:add_slider("[W] Ark Pred Hit Chance [%]", Kai_pred, 1, 99, 50)
Kai_w_width = menu:add_slider("[W] Spell Width [Default 170]", Kai_pred, 1, 200, 170)

Kai_ks_function = menu:add_subcategory("[Kill Steal]", Kai_category)
Kai_ks_q = menu:add_subcategory("[Q] Settings", Kai_ks_function, 1)
Kai_ks_use_q = menu:add_checkbox("Use [Q]", Kai_ks_q, 1)
Kai_ks_w = menu:add_subcategory("[W] Settings", Kai_ks_function, 1)
Kai_ks_use_w = menu:add_checkbox("Use [W]", Kai_ks_w, 1)
Kai_ks_w_range = menu:add_slider("Max Range [W]", Kai_ks_w, 1, 3000, 2000)

Kai_combo = menu:add_subcategory("[Combo]", Kai_category)
Kai_combo_q = menu:add_subcategory("[Q] Settings", Kai_combo)
Kai_combo_use_q = menu:add_checkbox("Use [Q]", Kai_combo_q, 1)
Kai_combo_q_iso = menu:add_checkbox("[Q] Isolated Target Only", Kai_combo_q, 0)
Kai_combo_w = menu:add_subcategory("[W] Settings", Kai_combo)
Kai_combo_use_w = menu:add_checkbox("Use [W]", Kai_combo_w, 1)
Kai_combo_use_w_aa = menu:add_checkbox("Only Use [W] Outside AA Range", Kai_combo_w, 1)
Kai_combo_use_w_range = menu:add_slider("Max Range [W]", Kai_combo_w, 1, 3000, 2000)
Kai_combo_use_w_stack = menu:add_slider("Minimum Passive Stacks To Use [W]", Kai_combo_w, 0, 4, 2)
Kai_combo_e = menu:add_subcategory("[E] Settings", Kai_combo)
Kai_combo_use_e = menu:add_checkbox("Use [E]", Kai_combo_e, 1)
Kai_combo_e_aa = menu:add_checkbox("Only Use [E] Outside AA Range", Kai_combo_e, 1)

Kai_harass = menu:add_subcategory("[Harass]", Kai_category)
Kai_harass_q = menu:add_subcategory("[Q] Settings", Kai_harass)
Kai_harass_use_q = menu:add_checkbox("Use [Q]", Kai_harass_q, 1)
Kai_harass_q_iso = menu:add_checkbox("[Q] Isolated Target Only", Kai_harass_q, 1)
Kai_harass_use_auto_q = menu:add_toggle("Toggle Auto Isolated [Q] Harass", 1, Kai_harass_q, 90, true)
Kai_harass_w = menu:add_subcategory("[W] Settings", Kai_harass)
Kai_harass_use_w = menu:add_checkbox("Use [W]", Kai_harass_w, 1)
Kai_harass_use_w_aa = menu:add_checkbox("Only Use [W] Outside AA Range", Kai_harass_w, 1)
Kai_harass_use_w_range = menu:add_slider("Max Range [W]", Kai_harass_w, 1, 3000, 2000)
Kai_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", Kai_harass, 1, 100, 20)

Kai_extra = menu:add_subcategory("[Automated] Features", Kai_category)
Kai_auto_e_gap = menu:add_checkbox("Auto [E] Gap Close", Kai_extra, 1)
Kai_auto_e_gap_whitelist = menu:add_subcategory("[E] Anti Gap Whitelist", Kai_extra)
for _, t in pairs(game.players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [E] Anti Gap On: "..tostring(t.champ_name), Kai_auto_e_gap_whitelist, 1)
    end
end
Kai_auto_e_toclose = menu:add_checkbox("Auto [E] Escape Short Ranged Targets", Kai_extra, 1)
Kai_auto_w = menu:add_checkbox("Auto [W] Immobilised Target", Kai_extra, 1)
evo_cancel = menu:add_checkbox("Animation Evolve Cancelling", Kai_extra, 1)
Kai_e_targetted = menu:add_checkbox("Use Upgraded [E] On Incoming Targetted Spells", Kai_extra, 1)
Kai_e_targetted_whitelist = menu:add_subcategory("Targetted Spell Player Whitelist", Kai_extra)
for _, y in pairs(game.players) do
    if y and y.is_enemy then
        menu:add_checkbox("Use On: "..tostring(y.champ_name), Kai_e_targetted_whitelist, 1)
    end
end

Kai_laneclear = menu:add_subcategory("[Lane Clear]", Kai_category)
Kai_laneclear_use_q = menu:add_checkbox("Use [Q]", Kai_laneclear, 1)
Kai_laneclear_use_e = menu:add_checkbox("Use [E]", Kai_laneclear, 1)
Kai_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", Kai_laneclear, 1, 100, 20)
Kai_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", Kai_laneclear, 1, 10, 3)
Kai_laneclear_e_min = menu:add_slider("Number Of Minions To Use [E]", Kai_laneclear, 1, 10, 3)

Kai_jungleclear = menu:add_subcategory("[Jungle Clear]", Kai_category)
Kai_jungleclear_use_q = menu:add_checkbox("Use [Q]", Kai_jungleclear, 1)
Kai_jungleclear_use_e = menu:add_checkbox("Use [E]", Kai_jungleclear, 1)
Kai_jungleclear_use_w = menu:add_checkbox("Use [W]", Kai_jungleclear, 1)
Kai_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", Kai_jungleclear, 1, 100, 20)

Kai_draw = menu:add_subcategory("[Drawing] Features", Kai_category)
Kai_draw_q = menu:add_checkbox("Draw [Q] Range", Kai_draw, 1)
Kai_draw_w = menu:add_checkbox("Draw [W] Range", Kai_draw, 1)
Kai_draw_r = menu:add_checkbox("Draw [R] Range", Kai_draw, 1)
Kai_auto_q_draw = menu:add_checkbox("Draw Toggle Auto [Q] Harass", Kai_draw, 1)
Kai_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", Kai_draw, 1)
Kai_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", Kai_draw, 1, "Health Bar Damage Is Computed From Q > W")

-- Spell Data

local wpred_width = menu:get_value(Kai_w_width)
local wpred_radius = menu:get_value(Kai_w_width) / 2
local W_input = {
	source = myHero,
	speed = 1750, range = 3000,
	delay = 0.45, radius = wpred_radius,
	collision = {"minion", "wind_wall"},
	type = "linear", hitbox = true
}

local WDream = {
	type = "linear",
	delay = 0.45,
	speed = 1750,
	range = 3000,
	width = wpred_width,
	collision = {
		["Wall"] = true,
		["Hero"] = true,
		["Minion"] = true
	},
}


local function CheckPredCastRate(pred)
	if pred then
		if menu:get_value(Kai_pred_castrate) == 0 and pred.rates["very slow"] then
			return true
		elseif menu:get_value(Kai_pred_castrate) == 1 and pred.rates["slow"] then
			return true
		elseif menu:get_value(Kai_pred_castrate) == 2 and pred.rates["instant"] then
			return true
		end
	end
	return false
end

-- Casting

local function CastQ()
	spellbook:cast_spell(SLOT_Q, Q.delay)
end

local function CastW(unit)
	if unit then
		if menu:get_value(Kai_pred_selection) == 0 then
			local pred = _G.DreamPred.GetPrediction(unit, WDream, myHero)
			if pred and CheckPredCastRate(pred) then
				local p = pred.castPosition
				spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
			end
		else
			local output = arkpred:get_prediction(W_input, unit)
			local inv = arkpred:get_invisible_duration(unit)
			if output.hit_chance >= menu:get_value(Kai_w_hitchance) / 100 and inv < (W_input.delay / 2) then
				local p = output.cast_pos
				spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
			end
		end
	end
end

local function CastE()
	spellbook:cast_spell(SLOT_E, E.delay)
end

local function CastR(unit)
	spellbook:cast_spell(SLOT_R, R.delay, unit.origin.x, unit.origin.y, unit.origin.z)
end

-- Check for AA done & incoming targeted spells

local function CheckTarget(unit)
	if unit.is_hero and unit.is_enemy and unit.is_alive then
		if menu:get_value_string("Use On: "..tostring(unit.champ_name)) == 1 then
			return true
		end	
	end
	return false
end

aa_complete = false
local function weaving()
	aa_complete = true
end

local function on_process_spell(obj, args)
	if obj == myHero and args.is_autoattack then
		aa_complete = false
		delay = 0.20 + (game.ping / 10000)
		client:delay_action(weaving, delay)
	end

    local e_ready = Ready(SLOT_E) and menu:get_value(Kai_e_targetted) == 1 and myHero:has_buff("KaisaEEvolved")
	if e_ready and myHero.is_alive and CheckTarget(obj) then
		if not args.is_autoattack and args.target == myHero then
			spellbook:cast_spell(SLOT_E, 0.25)
		end
	end
end


-- Combo

local function Combo()
    local target = selector:find_target(Q.range, mode_health)
    local w_targets, pred_results = TS:GetTargets(WDream, myHero)
    local wtarget = w_targets[1]
    local etarget = selector:find_target(1500, mode_health)
    local q_range = Q.range
    local w_range = menu:get_value(Kai_combo_use_w_range)
    local use_w = menu:get_value(Kai_combo_use_w) == 1
    local use_w_aa = menu:get_value(Kai_combo_use_w_aa) == 1
    local use_q = menu:get_value(Kai_combo_use_q) == 1
    local use_q_iso = menu:get_value(Kai_combo_q_iso) == 1
    local use_e = menu:get_value(Kai_combo_use_e) == 1
    local use_e_aa = menu:get_value(Kai_combo_e_aa) == 1
    local w_stack = menu:get_value(Kai_combo_use_w_stack)

    if Ready(SLOT_W) and IsValid(wtarget, w_range) then
        if use_w and (use_w_aa and myHero:distance_to(wtarget.origin) >= myHero.attack_range) or not use_w_aa then
            if HasPassiveCount(wtarget) >= w_stack then
                CastW(wtarget)
            end
        end
    end

    if Ready(SLOT_Q) and IsValid(target, Q.range) then
        if use_q then
            if (not use_q_iso or TargetIsIsolated(q_range, myHero) == 0) and (aa_complete or myHero:distance_to(target.origin) > myHero.attack_range) then
                CastQ()
            end
        end
    end

    if Ready(SLOT_E) and IsValid(etarget, 1500) then
        if use_e then
            if (not use_e_aa or myHero:distance_to(etarget.origin) > q_range) and myHero:distance_to(etarget.origin) < 1500 then
                CastE()
            end
        end
    end
end


--Harass

local function Harass()
    local target = selector:find_target(W.range, mode_health)
    local grabHarassMana = myHero.mana / myHero.max_mana >= menu:get_value(Kai_harass_min_mana) / 100
    local w_range = menu:get_value(Kai_harass_use_w_range)
    local use_w = menu:get_value(Kai_harass_use_w) == 1
    local use_w_aa = menu:get_value(Kai_harass_use_w_aa) == 1
    local use_q = menu:get_value(Kai_harass_use_q) == 1
    local use_q_iso = menu:get_value(Kai_harass_q_iso) == 1
    local use_auto_q = menu:get_toggle_state(Kai_harass_use_auto_q)

    if IsValid(target, w_range) and grabHarassMana then
        if use_w and Ready(SLOT_W) then
            if (not use_w_aa or myHero:distance_to(target.origin) >= myHero.attack_range) then
                CastW(target)
            end
        end

        if use_q and not use_auto_q and Ready(SLOT_Q) then
            if (not use_q_iso or TargetIsIsolated(q_range, myHero) == 0) and aa_complete then
                CastQ()
            end
        end
    end
end


-- Auto isolated Q harass

local function AutoQHarass()
    local target = selector:find_target(Q.range, mode_health)
    local use_q = menu:get_value(Kai_harass_use_q) == 1
    local use_auto_q = menu:get_toggle_state(Kai_harass_use_auto_q)
    local combo_pressed = game:is_key_down(menu:get_value(Kai_combokey))
    local grabHarassMana = myHero.mana / myHero.max_mana >= menu:get_value(Kai_harass_min_mana) / 100

    if grabHarassMana and Ready(SLOT_Q) and IsValid(target, Q.range) and use_auto_q and use_q and not combo_pressed then
        if not myHero.is_recalling and not IsUnderTurret(myHero) and TargetIsIsolated(Q.range, myHero) == 0 then
            CastQ()
        end
    end
end


-- Kill steal

local function AutoKill()
    local use_w = menu:get_value(Kai_ks_use_w) == 1
    local use_q = menu:get_value(Kai_ks_use_q) == 1
    local w_range = menu:get_value(Kai_ks_w_range)

    for _, target in ipairs(GetEnemyHeroes()) do
        if IsValid(target, w_range) then
            if Ready(SLOT_W) and use_w and GetWDmg(target) > target.health then
                CastW(target)
            end

            if Ready(SLOT_Q) and use_q and myHero:distance_to(target.origin) <= Q.range and GetQDmg(target) > target.health then
                CastQ()
            end
        end
    end
end


-- Lane clear

local function Clear()
    local grab_mana = myHero.mana/myHero.max_mana >= menu:get_value(Kai_laneclear_min_mana) / 100
    local use_q = menu:get_value(Kai_laneclear_use_q) == 1
    local use_e = menu:get_value(Kai_laneclear_use_e) == 1
    local q_min = menu:get_value(Kai_laneclear_q_min)
    local e_min = menu:get_value(Kai_laneclear_e_min)

    for _, target in ipairs(game.minions) do
        if IsValid(target, Q.range) and target.is_enemy and grab_mana and aa_complete then
            if Ready(SLOT_Q) and use_q and myHero:distance_to(target.origin) < Q.range and GetMinionCount(Q.range, myHero) >= q_min then
                CastQ()
            end

            if Ready(SLOT_E) and use_e and myHero:distance_to(target.origin) < AA.range and GetMinionCount(AA.range, myHero) >= e_min then
                CastE()
            end
        end
    end
end


-- Jungle Clear

local function JungleClear()
	local grab_mana = myHero.mana/myHero.max_mana >= menu:get_value(Kai_jungleclear_min_mana) / 100
    local use_q = menu:get_value(Kai_jungleclear_use_q) == 1
    local use_e = menu:get_value(Kai_jungleclear_use_e) == 1
    local use_w = menu:get_value(Kai_jungleclear_use_w) == 1

    for _, target in ipairs(game.jungle_minions) do
        if IsValid(target, Q.range) and grab_mana and aa_complete then
            if Ready(SLOT_Q) and use_q then
                CastQ()
            end

            if Ready(SLOT_E) and use_e and myHero:distance_to(target.origin) < AA.range then
                CastE()
            end

            if Ready(SLOT_W) and use_w and myHero:distance_to(target.origin) < W.range then
                pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)
                if pred_output.can_cast then
                    local p = pred_output.cast_pos
                    spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
                end
            end
        end
    end
end

-- Auto W

local function AutoW()
    local use_w = menu:get_value(Kai_auto_w) == 1

    for _, target in ipairs(GetEnemyHeroes()) do
        if Ready(SLOT_W) and use_w and IsValid(target, W.range) and not myHero.is_recalling and not IsUnderTurret(myHero) then
            if IsImmobileTarget(target) then
                CastW(target)
            end
        end
    end    
end

-- Auto E

local function AutoE()
    local use_auto_e = menu:get_value(Kai_auto_e_toclose) == 1
    local melee_range = 400

	for _, target in ipairs(GetEnemyHeroes()) do
        if IsValid(target, melee_range) and Ready(SLOT_E) and use_auto_e and not myHero.is_recalling then
            if target.is_melee and aa_complete then
                CastE()
            end
        end
    end
end
    

-- Gap Close

local function on_dash(obj, dash_info)
    local use_e_gap = menu:get_value(Kai_auto_e_gap) == 1

	if use_e_gap and Ready(SLOT_E) and menu:get_value_string("Use [E] Anti Gap On: "..tostring(obj.champ_name)) == 1 then
		if myHero:distance_to(dash_info.end_pos) < myHero.attack_range then
			CastE()
		end
	end
end

-- Cancel evo animation

local function EvoCancel()
    local evolved = myHero.evolve_points

	if menu:get_value(evo_cancel) == 1 and evolved ~= 0 then
	  spellbook:cast_spell(13)
	  client:delay_action(function ()
		spellbook:level_spell_slot(0)
		spellbook:level_spell_slot(1)
		spellbook:level_spell_slot(2)
	  end, 0.01)
	  client:delay_action(function ()
		issueorder:move_fast(myHero.origin)
	  end, 0.6)
	end
end

-- Draw and omtick 

local screen_size = game.screen_size
local function on_draw()

	if menu:get_value(Kai_enabled) == 0 then return end

	if UpdateDraw then
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2, "Shaun's Kaisa Update Available... Press F5")
	end

    local toggle_auto_q_enabled = menu:get_value(Kai_auto_q_draw) == 1 and menu:get_value(Kai_harass_use_q) == 1 and menu:get_toggle_state(Kai_harass_use_auto_q)
    local draw_q_enabled = menu:get_value(Kai_draw_q) == 1 and Ready(SLOT_Q)
    local draw_w_enabled = menu:get_value(Kai_draw_w) == 1 and Ready(SLOT_W)
    local draw_r_enabled = menu:get_value(Kai_draw_r) == 1 and Ready(SLOT_R)
    local draw_kill_enabled = menu:get_value(Kai_draw_kill) == 1
    local draw_kill_healthbar_enabled = draw_kill_enabled and menu:get_value(Kai_draw_kill_healthbar) == 1
    
    if toggle_auto_q_enabled then
        renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto Isolated [Q] Harass Enabled")
    end

    if myHero.is_alive then
        if draw_q_enabled then
            renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, Q.range, 255, 255, 255, 255)
        end

        if draw_w_enabled then
            renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, 1000, 255, 0, 255, 255)
        end

        if draw_r_enabled then
            renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, rRange[spellbook:get_spell_slot(SLOT_R).level], 255, 0, 0, 255)
            minimap:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, rRange[spellbook:get_spell_slot(SLOT_R).level], 255, 0, 0, 255)
        end

        if draw_kill_enabled then
            for _, target in ipairs(GetEnemyHeroes()) do
                if Ready(SLOT_Q) and IsValid(target, 1000) then
                    local fulldmg = GetQDmg(target) + GetWDmg(target) + (myHero.total_attack_damage * 3)
                    if fulldmg > target.health then
                        local pos = game:world_to_screen(target.origin.x, target.origin.y, target.origin.z)
                        renderer:draw_text_big_centered(pos.x, pos.y, "Can Kill Target")
                    end

                    if fulldmg and draw_kill_healthbar_enabled then
                        target:draw_damage_health_bar(fulldmg)
                    end
                end
            end
        end
    end
end

local function on_tick_always()

	if menu:get_value(Kai_enabled) == 0 then return end

    if myHero.is_alive then

        if game:is_key_down(menu:get_value(Kai_combokey)) then
            Combo()
        elseif combo:get_mode() == MODE_HARASS then
            Harass()
        elseif combo:get_mode() == MODE_LANECLEAR then
            Clear()
            JungleClear()
        end

        AutoQHarass()
        AutoW()
        AutoE()
        AutoKill()
        EvoCancel()
    end

    -- Table updating via ontick()
    wpred_width = menu:get_value(Kai_w_width)
    wpred_radius = menu:get_value(Kai_w_width) / 2
    W_input = {
        source = myHero,
        speed = 1750, range = 3000,
        delay = 0.45, radius = wpred_radius,
        collision = {"minion", "wind_wall"},
        type = "linear", hitbox = true
    }
    
    WDream = {
        type = "linear",
        delay = 0.45,
        speed = 1750,
        range = 3000,
        width = wpred_width,
        collision = {
            ["Wall"] = true,
            ["Hero"] = true,
            ["Minion"] = true
        },
    }
end

client:set_event_callback("on_tick_always", on_tick_always)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_process_spell", on_process_spell)
