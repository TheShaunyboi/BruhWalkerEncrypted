if game.local_player.champ_name ~= "kennen" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.3
		local file_name = "Worlds2021-Kennen.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Worlds2021-Kennen.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Worlds2021-Kennen.lua.version.txt")
        console:log("Worlds2021-Kennen.lua Vers: "..Version)
		console:log("Worlds2021-Kennen.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then

            console:log("...Shaun's Worlds Kennen Successfully Loaded.....")


        else
			http:download_file(url, file_name)
			      console:log("Worlds Kennen Update available.....")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
        end

    end

    AutoUpdate()
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

local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark223 Prediction Library Downloaded")
   console:log("Please Reload with F5")
end

pred:use_prediction()
arkpred = _G.Prediction

local myHero = game.local_player
local local_player = game.local_player

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

local function GetAllyHeroes()
	local _AllyHeroes = {}
	players = game.players
	for i, unit in ipairs(players) do
		if unit and not unit.is_enemy and unit.object_id ~= myHero.object_id then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
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

local function GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

local function GetEnemyCount(range, unit)
	count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	Range = range * range
		if unit.object_id ~= hero.object_id and GetDistanceSqr(unit, hero) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetEnemyCountCicular(range, p1)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(p1, unit.origin) < Range and IsValid(unit) then
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
		if minion.is_enemy and IsValid(minion) and unit.object_id ~= minion.object_id and GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

local function HasPassiveStack(unit)
  if unit:has_buff(kennenmarkofstorm) then
    buff = unit:get_buff(PassiveStack)
    if buff.count > 0 then
      return buff.count
    end
  end
  return 0
end

local function HasBuff(unit)
	if unit:has_buff(BuffName) then
		return true
	end
	return false
end

function IsImmobile(unit)
  if unit:has_buff_type(5) or unit:has_buff_type(12) or unit:has_buff_type(30) or unit:has_buff_type(25) then
    return true
  end
  return false
end

local function EpicMonster(unit)
	if unit.champ_name == "SRU_Baron"
		or unit.champ_name == "SRU_RiftHerald"
		or unit.champ_name == "SRU_Dragon_Water"
		or unit.champ_name == "SRU_Dragon_Fire"
		or unit.champ_name == "SRU_Dragon_Earth"
		or unit.champ_name == "SRU_Dragon_Air"
		or unit.champ_name == "SRU_Dragon_Elder" then
		return true
	else
		return false
	end
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

function IsKillable(unit)
	if unit:has_buff_type(16) or unit:has_buff_type(18) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
end

local function IsFlashSlotF()
flash = spellbook:get_spell_slot(SLOT_F)
FData = flash.spell_data
FName = FData.spell_name
if FName == "SummonerFlash" then
    return true
end
return false
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	kennen_category = menu:add_category_sprite("Shaun's Sexy Kennen", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	kennen_category = menu:add_category("Shaun's Worlds Kennen")
end

kennen_enabled = menu:add_checkbox("Enabled", kennen_category, 1)
kennen_combokey = menu:add_keybinder("Combo Mode Key", kennen_category, 32)
menu:add_label("Shaun's Worlds Kennen", kennen_category)
menu:add_label("#2021 Worlds Hype..", kennen_category)


kennen_ark_pred = menu:add_subcategory("[Ark Pred Settings]", kennen_category)
kennen_ark_pred_q = menu:add_subcategory("[Q] Settings", kennen_ark_pred, 1)
kennen_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", kennen_ark_pred_q, 1, 99, 50)

kennen_ks_function = menu:add_subcategory("[Kill Steal]", kennen_category)
kennen_ks_use_q = menu:add_checkbox("Use [Q]", kennen_ks_function, 1)
kennen_ks_use_w = menu:add_checkbox("Use [W]", kennen_ks_function, 1)
kennen_ks_use_r = menu:add_checkbox("Use [R]", kennen_ks_function, 1)
kennen_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Whitelist", kennen_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), kennen_ks_r_blacklist, 1)
    end
end

kennen_combo = menu:add_subcategory("[Combo]", kennen_category)
kennen_combo_q = menu:add_subcategory("[Q] Settings", kennen_combo)
kennen_combo_use_q = menu:add_checkbox("Use [Q]", kennen_combo_q, 1)
kennen_combo_w = menu:add_subcategory("[W] Settings", kennen_combo)
kennen_combo_use_w = menu:add_checkbox("Use [W]", kennen_combo_w, 1)
kennen_combo_use_w_passive = menu:add_slider("Number Of Passive Stacks To Use [W]", kennen_combo_w, 1, 2, 2)
kennen_combo_use_w_auto = menu:add_checkbox("Auto Use [W] IF Outside [AA] Range", kennen_combo_w, 1)

kennen_harass = menu:add_subcategory("[Harass]", kennen_category)
kennen_harass_use_q = menu:add_checkbox("Use [Q]", kennen_harass, 1)
kennen_harass_use_w = menu:add_checkbox("Use [W]", kennen_harass, 1)
kennen_harass_use_w_passive = menu:add_slider("Number Of Passive Stacks To Use [W]", kennen_harass_w, 1, 2, 2)
kennen_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", kennen_harass, 1, 100, 20)

kennen_autmated_features = menu:add_subcategory("[Automated Features]", kennen_category)
kennen_auto_w = menu:add_checkbox("Auto [Q] Immobilised Targets", kennen_extra_w, 1)
kennen_auto_gapclose = menu:add_checkbox("[E] Anti Gap Close", kennen_autmated_features, 1)
kennen_auto_r = menu:add_subcategory("Auto [R] Settings", kennen_autmated_features, 1)
kennen_auto_r_use = menu:add_checkbox("Use Auto [R]", kennen_auto_r, 1)
kennen_auto_r_min = menu:add_slider("Minimum Targets To Perform Auto [R]", kennen_auto_r, 1, 5, 3)

kennen_laneclear = menu:add_subcategory("[Lane Clear]", kennen_category)
kennen_laneclear_use_q = menu:add_checkbox("Use [Q]", kennen_laneclear, 1)
kennen_laneclear_use_w = menu:add_checkbox("Use [W]", kennen_laneclear, 1)
kennen_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", kennen_laneclear, 1, 100, 20)
kennen_laneclear_w_min = menu:add_slider("Number Of Passive Stacks To Use [W]", kennen_laneclear, 1, 2, 2)

kennen_jungleclear = menu:add_subcategory("[Jungle Clear]", kennen_category)
kennen_jungleclear_use_q = menu:add_checkbox("Use [Q]", kennen_jungleclear, 1)
kennen_jungleclear_use_w = menu:add_checkbox("Use [W]", kennen_jungleclear, 1)
kennen_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", kennen_jungleclear, 1, 100, 20)
kennen_jungleclear_w_min = menu:add_slider("Number Of Passive Stacks To Use [W]", kennen_jungleclear, 1, 2, 2)

kennen_draw = menu:add_subcategory("[Drawing Features]", kennen_category)
kennen_draw_q = menu:add_checkbox("Draw [Q] Range", kennen_draw, 1)
kennen_draw_w = menu:add_checkbox("Draw [W] Range", kennen_draw, 1)
kennen_draw_r = menu:add_checkbox("Draw [R] Range", kennen_draw, 1)
kennen_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", kennen_draw, 1)
kennen_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", kennen_draw, 1)

-- Spell Data

local Q = { range = 1000, delay = .175 }
local W = { range = 750, delay = .25 }
local E = { delay = .1 }
local R = { range = 550, delay = .25 }

local Q_input = {
    source = myHero,
		speed = 1650, range = 1000,
    delay = 0.175, radius = 150,
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 2)
	return RDmg

end

-- Casting

local function CastQ(unit)

	local output = arkpred:get_prediction(Q_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(kennen_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
		local p = output.cast_pos
	  spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
	end
end

local function CastW()
	spellbook:cast_spell(SLOT_W, W.delay)
end

local function CastE(unit)
	spellbook:cast_spell(SLOT_E, E.delay)
end

local function CastR()
	spellbook:cast_spell(SLOT_R, R.delay)
end

-- Combo

local function Combo()

	target = selector:find_target(Q.range, mode_health)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if menu:get_value(kennen_combo_use_q) == 1 and Ready(SLOT_Q) then
		if IsValid(target) and IsValid(target) and IsKillable(target) then
			CastQ(target)
		end
	end

	if menu:get_value(kennen_combo_use_w) == 1 and Ready(SLOT_W) then
		if IsValid(target) myHero:distance_to(target.origin) <= W.range and IsKillable(target) then
      if HasPassiveStack(target) >= menu:get_value(kennen_combo_use_w_passive) then
				CastW()
			end
		end
	end

	if menu:get_value(kennen_combo_use_w) == 1 and menu:get_value(kennen_combo_use_w_auto) == 1 and Ready(SLOT_W) then
		if IsValid(target) and myHero:distance_to(target.origin) <= W.range and IsKillable(target) then
			if HasPassiveStack(target) >= 0 and myHero:distance_to(target.origin) > TrueAARange then
				CastW()
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(Q.range, mode_health)
	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(kennen_harass_min_mana) / 100
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if menu:get_value(kennen_harass_use_q) == 1 and Ready(SLOT_Q) and GrabMana then
		if IsValid(target) and IsValid(target) and IsKillable(target) then
			CastQ(target)
		end
	end

	if menu:get_value(kennen_harass_use_w) == 1 and Ready(SLOT_W) and GrabMana then
		if IsValid(target) myHero:distance_to(target.origin) <= W.range and IsKillable(target) then
      if HasPassiveStack(target) >= menu:get_value(kennen_harass_use_w_passive) then
				CastW()
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if Ready(SLOT_Q) and IsValid(target) and myHero:distance_to(target.origin) <= Q.range and IsKillable(target) then
			if menu:get_value(kennen_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					CastQ(target)
				end
			end
		end

		if Ready(SLOT_W) and IsValid(target) and myHero:distance_to(target.origin) <= W.range and IsKillable(target) then
			if menu:get_value(kennen_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					CastW()
				end
			end
		end

		if Ready(SLOT_R) and IsValid(target) and myHero:distance_to(target.origin) <= R.range and IsKillable(target) then
			if menu:get_value(kennen_ks_use_r) == 1 then
        if GetRDmg(target) > target.health then
				  if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
					  CastR()
          end
			  end
		  end
    end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(kennen_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(kennen_laneclear_use_q) == 1 and Ready(SLOT_Q) then
			if IsValid(target) and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GrabLaneClearMana then
					pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
					 if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end

		if menu:get_value(kennen_laneclear_use_w) == 1 then
			if IsValid(target) and target.is_enemy and myHero:distance_to(target.origin) < W.range then
				if HasPassiveStack(target) >= menu:get_value(kennen_laneclear_w_min) then
					if GrabLaneClearMana and Ready(SLOT_W) then
						CastW()
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(kennen_laneclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if menu:get_value(kennen_jungleclear_use_q) == 1 and Ready(SLOT_Q) then
			if IsValid(target) and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GrabJungleClearMana then
					pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
					 if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end

		if menu:get_value(kennen_jungleclear_use_w) == 1 and Ready(SLOT_W) then
			if IsValid(target) and target.is_enemy and myHero:distance_to(target.origin) < W.range then
				if HasPassiveStack(target) >= menu:get_value(kennen_jungleclear_w_min) then
					if GrabJungleClearMana then
						CastW()
					end
				end
			end
		end
	end
end

-- Auto R >= Targets

local function AutoR()
  if menu:get_value(kennen_auto_r_use) == 1 and Ready(SLOT_R) then
    if GetEnemyCountCicular(R.range, myHero.origin) >= menu:get_value(kennen_auto_r_min) then
      CastR()
    end
  end
end

-- Gap Close

local function on_dash(obj, dash_info)

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if menu:get_value(kennen_auto_gapclose) == 1 then
		if IsValid(obj) and Ready(SLOT_E) then
			if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) < TrueAARange then
				CastE()
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_draw()

	local_player = game.local_player
	screen_size = game.screen_size
	target = selector:find_target(2000, mode_health)
	targetvec = target.origin

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(kennen_draw_q) == 1 and myHero.is_alive then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(kennen_draw_w) == 1 and myHero.is_alive then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(kennen_draw_r) == 1 and myHero.is_alive then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		if menu:get_value(kennen_draw_kill) == 1 and Ready(SLOT_R) and IsValid(target) then
			local fulldmg = GetQDmg(target) + GetWDmg(target) + GetRDmg(target)
			if myHero:distance_to(target.origin) <= 1000 then
				if fulldmg > target.health then
					if enemydraw.is_valid and target.is_on_screen and myHero.is_alive then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(kennen_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(kennen_combokey)) and menu:get_value(kennen_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

  AutoR()
	AutoKill()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
