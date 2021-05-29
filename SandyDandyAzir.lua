if game.local_player.champ_name ~= "Azir" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.0
		local file_name = "SandyDanyAzir.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SandyDanyAzir.lua"
    local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SandyDanyAzir.lua.version.txt")
    console:log("SandyDanyAzir..lua Vers: "..Version)
		console:log("SandyDanyAzir..Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log(".................Shaun's Sexy Azir Successfully Loaded........................")
    else
						http:download_file(url, file_name)
			      console:log("Sexy Azir Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end

    end

    AutoUpdate()
end

--Ensuring that the librarys are downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
end

local VIP = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/VIP_USER_LIST.lua.txt")
VIP = VIP .. ','
local LIST = {}
for user in VIP:gmatch("(.-),") do
	table.insert(LIST, user)
end
local USER = client.username
local function VIP_USER_LIST()
	for _, value in pairs(LIST) do
		if string.find(tostring(value), client.username) then
			return true
		end
	end
return false
end

if not VIP_USER_LIST() then
  console:log("You Are Not VIP! To Become a Supportor Please Contact Shaunyboi")
  return
end

if VIP_USER_LIST() then
  console:log("..................You Are VIP! Thanks For Supporting <3 #Family........................")
end

--Initialization lines:
local ml = require "VectorMath"
pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player
local InsecReady = false
local KS_InsecReady = false
local FleeReady = false
local Qfire = false
local Rfire = false
local Efire = false
local flee_Efire = false
local flee_Qfire = false
local KS_Qfire = false
local KS_Rfire = false
local KS_Efire = false

-- Ranges
local Q = { range = 1000, delay = .25, width = 140, speed = 1600 }
local W = { range = 650, delay = .5, width = 315, speed = math.huge }
local E = { range = 1100, delay = .25, speed = math.huge }
local R = { range = 1500, delay = .5, width = 500, speed = 1000 }
local Tether = { range = 660 }

local function IsFlashSlotF()
flash = spellbook:get_spell_slot(SLOT_F)
FData = flash.spell_data
FName = FData.spell_name
if FName == "SummonerFlash" then
    return true
end
return false
end

-- No lib Functions Start

function IsKillable(unit)
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
end

local function IsUnderTurret(unit)
  turrets = game.turrets
  for i, v in ipairs(turrets) do
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

local function AzirE(unit)
	if unit:has_buff("azireshield") then
		return true
	end
	return false
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

local function GetMinionCount(range, unit)
	count = 0
	minions = game.minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_enemy and ml.IsValid(minion) and unit.object_id ~= minion.object_id and GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

function MinionsAround(pos, range)
    local Count = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

function GetBestCircularFarmPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = MinionsAround(m.origin, radius)
            if Count > MostHit then
                MostHit = Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

function JungleMonstersAround(pos, range)
    local Count = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

function GetBestCircularJungPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = JungleMonstersAround(m.origin, radius)
            if Count > MostHit then
                MostHit = Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

-- No lib Functions End

local function SupressedSpellReady(spell)
  return spellbook:can_cast_ignore_supressed(spell)
end

local soldiers = {}
local function on_object_created(object, obj_name)
  if object and obj_name == "AzirSoldier" then
    if object.is_alive then
      table.insert(soldiers, object)
    end
  end
end

function CountSoldiers()
    local count = 0
    for _ in pairs(soldiers) do
        count = count + 1
    end
    return count
end

function SoldiersInQRange()
	target = selector:find_target(2000, mode_cursor)
  for _, soldier in pairs(soldiers) do
    if soldier:distance_to(target.origin) <= Q.range then
			return true
		end
  end
	return false
end

function SoldiersWReady()
  return spellbook:get_spell_slot(SLOT_W).count
end

function FullComboManReady()
	local spell_slot_q = spellbook:get_spell_slot(SLOT_Q)
	local spell_slot_w = spellbook:get_spell_slot(SLOT_W)
	local spell_slot_e = spellbook:get_spell_slot(SLOT_E)
	local spell_slot_r = spellbook:get_spell_slot(SLOT_R)
	local total_spell_cost = spell_slot_q.spell_data.mana_cost + spell_slot_w.spell_data.mana_cost + spell_slot_e.spell_data.mana_cost + spell_slot_r.spell_data.mana_cost
	if myHero.mana > total_spell_cost then
		return true
	end
	return false
end

function AzirInsecReady()
	if FullComboManReady() and spellbook:get_spell_slot(SLOT_R).can_cast and spellbook:get_spell_slot(SLOT_Q).can_cast and spellbook:get_spell_slot(SLOT_E).can_cast and SoldiersWReady() > 0 then
		return true
	end
	return false
end

local function SoldierDmg(unit)
	local level = myHero.level

	if level < 8 then
		AADmg = unit:calculate_phys_damage(58 + (2 * level) + 0.6 * myHero.ability_power)
	elseif level < 12 then
		AADmg = unit:calculate_phys_damage(35 + (5 * level) + 0.6 * myHero.ability_power)
	elseif level > 12 then
		AADmg = unit:calculate_phys_damage(10 * (level - 20) + 0.6 * myHero.ability_power)
	end
	return AADmg
end

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetEDmg(unit)
	local EDmg = getdmg("E", unit, myHero, 1)
	return EDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	azir_category = menu:add_category_sprite("Shaun's Sexy Azir", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	azir_category = menu:add_category("Shaun's Sexy Azir")
end

azir_enabled = menu:add_checkbox("Enabled", azir_category, 1)
azir_combokey = menu:add_keybinder("Combo Mode Key", azir_category, 32)
azir_extra_flee_key = menu:add_keybinder("[W] [Q] [E] Manual Key - Mouse Position", azir_category, 90)
menu:add_label("Welcome To Shaun's Sexy Azir", azir_category)
menu:add_label("#SandInMyBallsHurts", azir_category)

azir_ks_function = menu:add_subcategory("Kill Steal", azir_category)
azir_ks_q = menu:add_subcategory("[Q] Settings", azir_ks_function, 1)
azir_ks_use_q = menu:add_checkbox("Use [Q]", azir_ks_q, 1)
azir_ks_use_qw = menu:add_checkbox("Use [W] Target >= [Q] Range", azir_ks_q, 1)
azir_ks_e = menu:add_subcategory("[E] Settings", azir_ks_function, 1)
azir_ks_use_e = menu:add_checkbox("[E]", azir_ks_e, 1)
azir_ks_use_e_count = menu:add_slider("<= Enemy Count Around To [E]", azir_ks_e, 1, 5, 2)
azir_ks_r = menu:add_subcategory("[R] Settings", azir_ks_function, 1)
azir_ks_use_r = menu:add_checkbox("Use [R]", azir_ks_r, 1)
azir_ks_insec = menu:add_subcategory("[INSEC] Settings", azir_ks_function, 1)
azir_ks_insec_use = menu:add_checkbox("Use [INSEC]", azir_ks_insec, 1)
azir_ks_use_insec_count = menu:add_slider("<= Enemy Count Around To [INSEC]", azir_ks_insec, 1, 5, 2)
azir_ks_blacklist = menu:add_subcategory("Kill Steal Champ Whitelist", azir_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Kill Steal Whitelist: "..tostring(t.champ_name), azir_ks_blacklist, 1)
    end
end

azir_combo = menu:add_subcategory("Combo", azir_category)
azir_combo_q = menu:add_subcategory("[Q] Settings", azir_combo)
azir_combo_use_q = menu:add_checkbox("Use [Q]", azir_combo_q, 1)
azir_combo_use_qw = menu:add_checkbox("Use [W] IF Target >= [Q] Range", azir_combo_q, 1)
azir_combo_w = menu:add_subcategory("[W] Settings", azir_combo)
azir_combo_use_w = menu:add_checkbox("Use [W]", azir_combo_w, 1)
azir_combo_e = menu:add_subcategory("[E] Settings", azir_combo)
azir_combo_use_e = menu:add_checkbox("Use [E]", azir_combo_e, 1)
azir_combo_use_e_hp = menu:add_slider("[E] IF Target HP <= than [%]", azir_combo_e, 1, 100, 30)
azir_combo_use_e_count = menu:add_slider("<= Enemy Count To [E]", azir_combo_e, 1, 5, 2)

azir_harass = menu:add_subcategory("Harass", azir_category)
azir_harass_q = menu:add_subcategory("[Q] Settings", azir_harass)
azir_harass_use_q = menu:add_checkbox("Use [Q]", azir_harass_q, 1)
azir_harass_use_qw = menu:add_checkbox("Use [W] IF Target >= [Q] Range", azir_harass_q, 1)
azir_harass_w = menu:add_subcategory("[W] Settings", azir_harass)
azir_harass_use_w = menu:add_checkbox("Use [W]", azir_harass_w, 1)
azir_combo_w_savecount = menu:add_slider("Save [W] Soldier Count", azir_harass_w, 1, 3 , 1)

azir_laneclear = menu:add_subcategory("Lane Clear", azir_category)
azir_laneclear_use_q = menu:add_checkbox("Use [Q]", azir_laneclear, 1)
azir_laneclear_use_w = menu:add_checkbox("Use [W]", azir_laneclear, 1)
azir_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", azir_laneclear, 1, 100, 20)
azir_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", azir_laneclear, 1, 10, 3)
azir_laneclear_w_min = menu:add_slider("Number Of Minions To Use [W]", azir_laneclear, 1, 10, 2)

azir_lasthit = menu:add_subcategory("Last Hit", azir_category)
azir_lasthit_use_q = menu:add_checkbox("Use [Q] Outside AA Range", azir_lasthit, 1)

azir_jungleclear = menu:add_subcategory("Jungle Clear", azir_category)
azir_jungleclear_use_q = menu:add_checkbox("Use [Q]", azir_jungleclear, 1)
azir_jungleclear_use_w = menu:add_checkbox("Use [W]", azir_jungleclear, 1)
azir_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", azir_jungleclear, 1, 100, 20)

azir_extra_insec = menu:add_subcategory("[INSEC] Settings", azir_category)
azir_insec_key = menu:add_keybinder("[INSEC] Hold Key - Target Nearest To Cursor", azir_extra_insec, 88)
e_table = {}
e_table[1] = "To Allys"
e_table[2] = "To Ally Tower"
e_table[3] = "Mouse Position"
azir_insec_direction = menu:add_combobox("[R] INSEC Direction Preference", azir_extra_insec, e_table, 2)

azir_extra = menu:add_subcategory("[R] Extra Features", azir_category)
azir_extra_semi_r_key = menu:add_keybinder("[R] Semi Manual Key - Target Closest To Mouse Position", azir_extra, 65)
azir_extra_save = menu:add_subcategory("Smart [R] Save Me! Settings", azir_extra)
azir_extra_saveme = menu:add_checkbox("Use Smart [R] Save Me! Usage", azir_extra_save, 1)
azir_extra_saveme_myhp = menu:add_slider("[R] Save Me! When My HP < [%]", azir_extra_save, 1, 100, 25)
azir_extra_saveme_target = menu:add_slider("[R] Save Me! When Target > [%]", azir_extra_save, 1, 100, 45)

azir_extra_gap = menu:add_subcategory("[R] Anti Gap Closer Settings", azir_extra)
azir_extra_gapclose = menu:add_toggle("[R] Toggle Anti Gap Closer key", 1, azir_extra_gap, 84, true)
azir_extra_gapclose_blacklist = menu:add_subcategory("[R] Anti Gap Closer Champ Whitelist", azir_extra_gap)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(t.champ_name), azir_extra_gapclose_blacklist, 1)
    end
end

azir_extra_int = menu:add_subcategory("[R] Interrupt Major Channel Spells Settings", azir_extra, 1)
azir_extra_interrupt = menu:add_checkbox("Use [R] Interrupt Major Channel Spells", azir_extra_int, 1)
azir_extra_interrupt_blacklist = menu:add_subcategory("[R] Interrupt Champ Whitelist", azir_extra_int)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(t.champ_name), azir_extra_interrupt_blacklist, 1)
    end
end

azir_draw = menu:add_subcategory("The Drawing Features", azir_category)
azir_draw_q = menu:add_checkbox("Draw [Q] Range", azir_draw, 1)
azir_draw_w = menu:add_checkbox("Draw [W] Range", azir_draw, 1)
azir_draw_e = menu:add_checkbox("Draw [E] Range", azir_draw, 1)
azir_draw_insec_ready = menu:add_checkbox("Draw [INSEC] Ready Text", azir_draw, 1)
azir_draw_gapclose = menu:add_checkbox("Draw [R] Anti Gap Closer Toggle Text", azir_draw, 1)
azir_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", azir_draw, 1)
azir_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo Colours On Target Health Bar", azir_draw, 1)

-- Casting

local function CastQ(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastE(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
end

local function CastR(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
end

-- Combo

local function Combo()

	target = selector:find_target(1500, mode_health)
	local TargetHP = target.health/target.max_health <= menu:get_value(azir_combo_use_e_hp) / 100

	for _, soldier in pairs(soldiers) do
		if menu:get_value(azir_combo_use_q) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if CountSoldiers() > 0 then
					if myHero:distance_to(target.origin) <= Q.range then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end
	end

	if menu:get_value(azir_combo_use_qw) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) > W.range then
					if SoldiersWReady() > 0 and ml.Ready(SLOT_W) and ml.Ready(SLOT_Q) then
						CastW(target)
					end
				end
			end
		end
	end

	if menu:get_value(azir_combo_use_w) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) <= W.range then
					if SoldiersWReady() > 0 and ml.Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end
	end

	for _, soldier in pairs(soldiers) do
		if menu:get_value(azir_combo_use_e) == 1 then
			if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
				local _, count = ml.GetEnemyCount(target.origin, 1500)
				if TargetHP and count <= menu:get_value(azir_combo_use_e_count) then
					if soldier:distance_to(target.origin) <= 500 then
						if ml.Ready(SLOT_E) and not IsUnderTurret(target) then
							CastE(target)
						end
					end
				end
			end
		end
	end
end

-- Harass

local function Harass()

	target = selector:find_target(1500, mode_health)

	for _, soldier in pairs(soldiers) do
		if menu:get_value(azir_harass_use_q) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if CountSoldiers() > 0 then
					if myHero:distance_to(target.origin) <= Q.range then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end
	end

	if menu:get_value(azir_harass_use_qw) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) > W.range then
					if CountSoldiers() <  menu:get_value(azir_combo_w_savecount) then
						if SoldiersWReady() > 0 and ml.Ready(SLOT_W) and ml.Ready(SLOT_Q) then
							CastW(target)
						end
					end
				end
			end
		end
	end

	if menu:get_value(azir_harass_use_w) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) <= W.range then
					if CountSoldiers() <  menu:get_value(azir_combo_w_savecount) then
						if SoldiersWReady() > 0 and ml.Ready(SLOT_W) then
							CastW(target)
						end
					end
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		for _, soldier in pairs(soldiers) do
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 300 and ml.IsValid(target) and IsKillable(target) then
				if menu:get_value(azir_ks_use_r) == 1 then
					if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
						if GetRDmg(target) > target.health and ml.Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
		end
		for _, soldier in pairs(soldiers) do
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
				if menu:get_value(azir_ks_use_q) == 1 then
					if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
						if GetQDmg(target) > target.health then
							if myHero:distance_to(soldier.origin) <= Q.range and ml.Ready(SLOT_Q) then
								CastQ(target)
							end
						end
					end
				end
			end
		end

		if menu:get_value(azir_ks_use_qw) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= Q.range then
					if myHero:distance_to(target.origin) > W.range then
						if SoldiersWReady() > 0 and ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
							if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
								if GetQDmg(target) > target.health then
									CastW(target)
								end
							end
						end
					end
				end
			end
		end

		if menu:get_value(azir_ks_use_qw) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= Q.range then
					if myHero:distance_to(target.origin) <= W.range then
						if SoldiersWReady() > 0 and ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
							if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
								if GetQDmg(target) > target.health then
									CastW(target)
								end
							end
						end
					end
				end
			end

			local QWEComboDMG = GetQDmg(target) + GetWDmg(target) + GetEDmg(target)
			for _, soldier in pairs(soldiers) do
				if menu:get_value(azir_ks_use_e) == 1 then
					if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
						local _, count = ml.GetEnemyCount(target.origin, 1500)
						if count <= menu:get_value(azir_ks_use_e_count) then
							if soldier:distance_to(target.origin) <= Q.range then
								if ml.Ready(SLOT_E) and not IsUnderTurret(target) then
									if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
										if QWEComboDMG > target.health then
											CastE(target)
										end
									end
								end
							end
						end
					end
				end
			end

			local FulComboDMG = GetQDmg(target) + GetWDmg(target) + GetEDmg(target) + GetRDmg(target)
			local _, count = ml.GetEnemyCount(target.origin, 1500)
			if menu:get_value(azir_ks_insec_use) == 1 then
				if FulComboDMG > target.health and count <= menu:get_value(azir_ks_use_insec_count) then
					if ml.IsValid(target) and IsKillable(target) and menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
						if AzirInsecReady() then
							KS_InsecReady = true
						end

						if InsecReady and not KS_Efire and not SoldiersInQRange() and myHero:distance_to(target.origin) < Q.range then
							CastW(target)
							KS_Efire = true
						end

						for _, soldier in pairs(soldiers) do
							if KS_InsecReady and ml.Ready(SLOT_W) and spellbook:get_spell_slot(SLOT_E).can_cast then
								if myHero:distance_to(soldier.origin) <= E.range and myHero:distance_to(soldier.origin) > 600 and target:distance_to(soldier.origin) <= Q.range then
									CastE(soldier)
									KS_Qfire = true
								end
							end

							if KS_Qfire and not KS_Rfire and myHero:distance_to(soldier.origin) <= 200 then
								CastQ(target)
								if not spellbook:get_spell_slot(SLOT_Q).can_cast then
									KS_Rfire = true
								end
							end

							if KS_InsecReady and KS_Rfire and myHero:distance_to(target.origin) <= 300 and ml.Ready(SLOT_R) then
								local mouse = game.mouse_pos
								spellbook:cast_spell(SLOT_R, R.delay, mouse.x, mouse.y, mouse.z)
							end
						end
					end
				end
			end
			if FulComboDMG < target.health then
				KS_InsecReady = false
				KS_Qfire = false
				KS_Rfire = false
				KS_Efire = false
			end
		end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(azir_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(azir_laneclear_use_q) == 1 and ml.Ready(SLOT_Q) then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 600 then
				if SoldiersWReady() > 0 and GetMinionCount(500, myHero) >= menu:get_value(azir_laneclear_q_min) then
					if GrabLaneClearMana then
						CastQ(target)
					end
				end
			end
		end

		if menu:get_value(azir_laneclear_use_w) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= Q.range then
					if myHero:distance_to(target.origin) <= W.range then
						local BestPos, MostHit = GetBestCircularFarmPos(myHero, W.range, W.width)
						if GrabLaneClearMana and BestPos and SoldiersWReady() > 0 and MostHit >= menu:get_value(azir_laneclear_w_min) then
							if spellbook:get_spell_slot(SLOT_W).can_cast then
								x, y, z = BestPos.x, BestPos.y, BestPos.z
								spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
							end
						end
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(azir_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if menu:get_value(azir_jungleclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 600 then
				if GrabJungleClearMana and ml.Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(azir_jungleclear_use_w) == 1 then
			if  ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy then
				if myHero:distance_to(target.origin) <= W.range then
					local BestPos, MostHit = GetBestCircularJungPos(myHero, W.range, W.width)
					if GrabJungleClearMana and BestPos and SoldiersWReady() > 0 and spellbook:get_spell_slot(SLOT_W).can_cast then
						x, y, z = BestPos.x, BestPos.y, BestPos.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end
				end
			end
		end
	end
end

-- Q Last Hit

local function Qlasthit()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(azir_laneclear_min_mana) / 100
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(azir_lasthit_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetQDmg(target) > target.health and myHero:distance_to(target.origin) > TrueAARange then
					if GrabLaneClearMana and ml.Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end
	end
end

-- Manual R

local function ManualR()

  target = selector:find_target(1500, mode_cursor)

  if game:is_key_down(menu:get_value(azir_extra_semi_r_key)) then
    if myHero:distance_to(target.origin) < 300 then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
				CastR(target)
			end
    end
  end
end

-- Manual R

local function RSaveMe()

  target = selector:find_target(1500, mode_distance)
	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(azir_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(azir_extra_saveme_target) / 100

	if menu:get_value(azir_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) < 300 then
			if myHero:distance_to(target.origin) < target.attack_range then
				if target:is_facing(myHero) then
					if SaveMeHP and TargetHP then
						if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
    end
  end
end

-- Flee
local function Flee()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(azir_laneclear_min_mana) / 100

	if game:is_key_down(menu:get_value(azir_extra_flee_key)) then
		if GrabLaneClearMana and spellbook:get_spell_slot(SLOT_Q).can_cast and spellbook:get_spell_slot(SLOT_E).can_cast and SoldiersWReady() > 0 then
			FleeReady = true
		end

		if FleeReady and not flee_Efire and ml.Ready(SLOT_W) then
			local mouse = game.mouse_pos
			spellbook:cast_spell(SLOT_W, W.delay, mouse.x, mouse.y, mouse.z)
			flee_Efire = true
		end

		for _, soldier in pairs(soldiers) do
			if not flee_Qfire and flee_Efire and ml.Ready(SLOT_W) and myHero:distance_to(soldier.origin) <= 150 then
				local qmouse = game.mouse_pos
				spellbook:cast_spell(SLOT_Q, Q.delay, qmouse.x, qmouse.y, qmouse.z)
				flee_Qfire = true
			end

			if flee_Qfire and ml.Ready(SLOT_E) and myHero:distance_to(soldier.origin) >= 200 then
				local emouse = game.mouse_pos
				spellbook:cast_spell(SLOT_E, E.delay, emouse.x, emouse.y, emouse.z)
			end
		end
	end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(azir_extra_gapclose) then
    if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
	      if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) < 300 and ml.Ready(SLOT_R) then
	        CastR(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	if ml.IsValid(obj) then
    if menu:get_value(azir_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) < 300 and ml.Ready(SLOT_R) then
        	CastR(obj)
				end
			end
		end
	end
end

local function INSEC()

	target = selector:find_target(2000, mode_cursor)

	players = game.players
	for _, ally in ipairs(players) do

		if menu:get_value(azir_insec_direction) == 0 then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if ml.IsValid(target) and IsKillable(target) then
				 	if ally:distance_to(target.origin) <= 1500 then
						if AzirInsecReady() then
						 InsecReady = true
					 end

						if InsecReady and not Efire and not SoldiersInQRange() and myHero:distance_to(target.origin) < Q.range then
							CastW(target)
							Efire = true
						end

						for _, soldier in pairs(soldiers) do
							if InsecReady and ml.Ready(SLOT_W) and spellbook:get_spell_slot(SLOT_E).can_cast then
								if myHero:distance_to(soldier.origin) <= E.range and myHero:distance_to(soldier.origin) > 600 and target:distance_to(soldier.origin) <= Q.range then
									CastE(soldier)
									Qfire = true
								end
							end

							if Qfire and not Rfire and myHero:distance_to(soldier.origin) <= 200 then
								CastQ(target)
								if not spellbook:get_spell_slot(SLOT_Q).can_cast then
									Rfire = true
								end
							end

							if InsecReady and Rfire and myHero:distance_to(target.origin) <= 300 and ml.Ready(SLOT_R) then
								CastR(ally)
							end
						end
					end
				end
			end
		end

		if menu:get_value(azir_insec_direction) == 1 then
			turrets = game.turrets
			for i, turret in ipairs(turrets) do
				if turret and not turret.is_enemy and turret.is_alive then
					if ml.IsValid(target) and IsKillable(target) then
					 	if turret:distance_to(target.origin) <= 2000 then
							if AzirInsecReady() then
							 InsecReady = true
						 end

							if InsecReady and not Efire and not SoldiersInQRange() and myHero:distance_to(target.origin) < Q.range then
								CastW(target)
								Efire = true
							end

							for _, soldier in pairs(soldiers) do
								if InsecReady and ml.Ready(SLOT_W) and spellbook:get_spell_slot(SLOT_E).can_cast then
									if myHero:distance_to(soldier.origin) <= E.range and myHero:distance_to(soldier.origin) > 600 and target:distance_to(soldier.origin) <= Q.range then
										CastE(soldier)
										Qfire = true
									end
								end

								if Qfire and not Rfire and myHero:distance_to(soldier.origin) <= 200 then
									CastQ(target)
									if not spellbook:get_spell_slot(SLOT_Q).can_cast then
										Rfire = true
									end
								end

								if InsecReady and Rfire and myHero:distance_to(target.origin) <= 300 and ml.Ready(SLOT_R) then
									CastR(turret)
								end
							end
						end
					end
				end
			end
		end

		if menu:get_value(azir_insec_direction) == 2 then
			if ml.IsValid(target) and IsKillable(target) then
				if AzirInsecReady() then
					InsecReady = true
				end

				if InsecReady and not Efire and not SoldiersInQRange() and myHero:distance_to(target.origin) < Q.range then
					CastW(target)
					Efire = true
				end

				for _, soldier in pairs(soldiers) do
					if InsecReady and ml.Ready(SLOT_W) and not Qfire and spellbook:get_spell_slot(SLOT_E).can_cast then
						if myHero:distance_to(soldier.origin) <= E.range and myHero:distance_to(soldier.origin) > 600 and target:distance_to(soldier.origin) <= Q.range then
							CastE(soldier)
							Qfire = true
						end
					end

					if Qfire and not Rfire and myHero:distance_to(soldier.origin) <= 200 then
						CastQ(target)
						if not spellbook:get_spell_slot(SLOT_Q).can_cast then
							Rfire = true
						end
					end

					if InsecReady and Rfire and myHero:distance_to(target.origin) <= 300 and ml.Ready(SLOT_R) then
						local mouse = game.mouse_pos
						spellbook:cast_spell(SLOT_R, R.delay, mouse.x, mouse.y, mouse.z)
					end
				end
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_draw()

	screen_size = game.screen_size

	target = selector:find_target(2000, mode_health)
	targetvec = target.origin
	justme = myHero.origin

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(azir_draw_q) == 1 then
		if ml.Ready(SLOT_Q) or SupressedSpellReady(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 0, 255, 255)
		end
	end

  if menu:get_value(azir_draw_w) == 1 then
		if SoldiersWReady() > 0 then
			renderer:draw_circle(x, y, z, W.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(azir_draw_e) == 1 then
		if ml.Ready(SLOT_E) or SupressedSpellReady(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 255, 255)
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetEDmg(target) + GetRDmg(target)
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(azir_draw_kill) == 1 then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(azir_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

	local myherodraw = game:world_to_screen(justme.x, justme.y, justme.z)
	if menu:get_value(azir_draw_insec_ready) == 1 then
	 if AzirInsecReady() then
		 renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 50, "INSEC Ready!")
	 end
 end

	if menu:get_value(azir_draw_gapclose) == 1 then
		if menu:get_toggle_state(azir_extra_gapclose) then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle [R] Anti Gap Closer Enabled")
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(azir_combokey)) and menu:get_value(azir_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LASTHIT then
		Qlasthit()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(azir_extra_semi_r_key)) then
		orbwalker:move_to()
		ManualR()
	end

	if game:is_key_down(menu:get_value(azir_extra_flee_key)) then
		orbwalker:move_to()
		Flee()
	end

	AutoKill()
	RSaveMe()

	if game:is_key_down(menu:get_value(azir_insec_key)) then
		INSEC()
		orbwalker:move_to()
	end

	for index, soldier in pairs(soldiers) do
    if not soldier.is_alive then
        table.remove(soldiers, index)
    end
	end

	if not spellbook:get_spell_slot(SLOT_R).can_cast or not game:is_key_down(menu:get_value(azir_insec_key)) then
		Qfire = false
		Rfire = false
		Efire = false
		InsecReady = false
	end

	if not game:is_key_down(menu:get_value(azir_extra_flee_key)) then
		flee_Qfire = false
		flee_Efire = false
		FleeReady = false
	end

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_object_created", on_object_created)
