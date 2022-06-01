if game.local_player.champ_name ~= "Kalista" then
	return
end

Updatedraw = false

--[[do
    local function AutoUpdate()
		local Version = 0.1
		local file_name = "Kalista-WatchMeDance.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Kalista-WatchMeDance.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Kalista-WatchMeDance.lua.version.txt")
        console:log("Kalista-WatchMeDance.Lua Vers: "..Version)
		console:log("Kalista-WatchMeDance.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then

			console:log("Shaun's kalista Successfully Loaded...")

        else
			http:download_file(url, file_name)
			console:log("Shaun's Kalista Update available.....")
			console:log("Please Reload via F5!.....")
			Updatedraw = true
        end

    end

    AutoUpdate()
end]]

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
  console:log("You Are VIP! Thanks For Supporting <3 #Family..")
end

pred:use_prediction()
arkpred = _G.Prediction

--Ensuring that the librarys are downloaded:

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark223 Prediction Library Downloaded")
   console:log("Please Reload with F5")
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
end

require "PKDamageLib"
myHero = game.local_player

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	kal_category = menu:add_category_sprite("Shaun's Sexy Kalista", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	kal_category = menu:add_category("Shaun's Sexy Kalista")
end

kal_enabled = menu:add_checkbox("Enabled", kal_category, 1)
kal_combokey = menu:add_keybinder("Combo Mode Key", kal_category, 88)
menu:add_label("Shaun's Kalista", kal_category)
menu:add_label("#Lets Go Dancing baby!", kal_category)

kal_prediction = menu:add_subcategory("[Pred Settings]", kal_category)
kal_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", kal_prediction, 1, 99, 50)

kal_ks_function = menu:add_subcategory("[Kill Steal]", kal_category)
kal_ks_use_q = menu:add_checkbox("Use [Q]", kal_ks_function, 1)
kal_ks_use_e = menu:add_checkbox("Use [E]", kal_ks_function, 1)

kal_combo = menu:add_subcategory("[Combo]", kal_category)
kal_combo_use_q = menu:add_checkbox("Use [Q]", kal_combo, 1)

kal_harass = menu:add_subcategory("[Harass]", kal_category)
kal_harass_use_q = menu:add_checkbox("Use [Q]", kal_harass, 1)
kal_harass_min_mana = menu:add_slider("Minimum [%] Mana To Harass", kal_harass, 1, 100, 20)

kal_auto_settings = menu:add_subcategory("[Auto Features]", kal_category)
menu:add_label("Increasing Incoming Hit-Time Will Calculate Incoming Damage Earlier", kal_auto_settings)
kal_laneclear_auto_e = menu:add_checkbox("Use Auto [E] Minion Last Hit", kal_auto_settings, 0)
kal_auto_e_death = menu:add_checkbox("Use Auto [E] On Death", kal_auto_settings, 1)
kal_r_use = menu:add_checkbox("Use Auto Save Ally [R]", kal_auto_settings, 1)
kal_hittime = menu:add_slider("Increase Incoming Hit-Time (milliseconds)", kal_auto_settings, 0, 1000, 350)

kal_laneclear = menu:add_subcategory("[Lane Clear]", kal_category)
menu:add_label("[Q] Will Cast IF You Can Hit Enemy Hero Through Minion!", kal_laneclear)
kal_laneclear_q = menu:add_checkbox("Use [Q]", kal_laneclear, 1)
kal_laneclear_e = menu:add_checkbox("Use [E] Last Hit", kal_laneclear, 1)

kal_jungleclear = menu:add_subcategory("[Jungle Clear]", kal_category)
kal_jungleclear_e = menu:add_checkbox("Use [Q] + [E] Jungle Combo Kill", kal_jungleclear, 1)

kal_draw = menu:add_subcategory("[Drawing] Features", kal_category)
kal_draw_q = menu:add_checkbox("Draw [Q] Range", kal_draw, 1)
kal_draw_er = menu:add_checkbox("Draw [E] & [R] Range", kal_draw, 1)

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

local function GetEnemyCountCicular(range, target)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(target.origin, unit.origin) < Range and IsValid(unit) then
        count = count + 1
        end
    end
    return count
end

local function GetAllyCount(range, unit)
	count = 0
	for i, hero in ipairs(GetAllyHeroes()) do
	Range = range * range
		if unit.object_id ~= hero.object_id and GetDistanceSqr(unit, hero) < Range and IsValid(hero) then
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

local function GetJungleCount(range, unit)
	count = 0
	minions = game.jungle_minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if IsValid(minion) and unit.object_id ~= minion.object_id and GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

local function EpicMonster(unit)
	if unit.champ_name == "SRU_Baron"
		or unit.champ_name == "SRU_RiftHerald"
		or unit.champ_name == "SRU_Dragon_Water"
		or unit.champ_name == "SRU_Dragon_Fire"
		or unit.champ_name == "SRU_Dragon_Earth"
		or unit.champ_name == "SRU_Dragon_Air"
		or unit.champ_name == "SRU_Dragon_Elder"
		or unit.champ_name == "SRU_Dragon_Chemtech"
		or unit.champ_name == "SRU_Dragon_Hextech"
		or unit.champ_name == "SRU_ChaosMinionSiege" then
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

local function IsKillable(unit)
	if unit:has_buff_type(16) or unit:has_buff_type(18) or unit:has_buff_type(38) then
		return false
	end
	return true
end


local function IsImmobile(unit)
	if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(10) or unit:has_buff_type(22) or unit:has_buff_type(23) or unit:has_buff_type(30) or unit:has_buff_type(11) or unit:has_buff_type(12) then
        return true
    end
    return false
end

-- Damages 

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GotBuff(unit)
    local buff = unit:get_buff("kalistaexpungemarker")
	if buff.count > 0 then 
		return buff.count
    end
	return 0
end

local function GetEDmg(unit)
	local EDmg = getdmg("E", unit, myHero, 1)
	return EDmg
end

--[[local function GetEDmg(unit)
    count = GotBuff(unit)
    level = myHero:get_spell_slot(SLOT_E).level
    if count > 0 and level > 0 then
        dmg = (({20, 30, 40, 50, 60})[level] + 0.7 * (myHero.total_attack_damage)) + ((count - 1) * (({10, 16, 22, 28, 34})[level] + ({0.232, 0.2755, 0.319, 0.3625, 0.406})[level] * (myHero.total_attack_damage)))
        if not EpicMonster(unit) then
            return unit:calculate_phys_damage(dmg)
        else
            return unit:calculate_phys_damage(dmg / 2)
        end
    end
    return 0
end]]

-- Ranges

local Q = { 
    range = 1100,
	delay = 0.25,
	speed = 2400,
	width = 80,
	radius = 40
}

local Q_input = {
	source = myHero,
	speed = Q.speed, range = Q.range,
	delay = Q.delay, radius = Q.radius,
	collision = {"minion", "enemy_hero"},
	type = "linear", hitbox = true
}

local E = { 
    range = 1100,
	delay = 0.25,
}

local R = { 
    range = 1100,
	delay = 0.1,
}

-- Get Line Target Count Minion

local function cmp(a, b)
    return a:distance_to(myHero.origin) < b:distance_to(myHero.origin)
end

local function GetFirst(tab)
    if tab[0] ~= nil then
        return tab[0]
    else
        return tab[1]
    end
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

local function TotalLineTest(source, delay, speed, width, target)
    local count = 0
    local table_output = {}
    local hit_chance = 0.60
    players = game.minions
    for _, player in ipairs(players) do
        local Range = Q.range
        if IsValid(player) and player:distance_to(myHero.origin) < Range and player.is_targetable and GetQDmg(player) > player.health and GetEDmg(player) > 0 then
            local aimPos = arkpred:get_position_after(player, Q.delay / 2)
            local localPredPos = arkpred:get_position_after(myHero, Q.delay / 2)
            local output = arkpred:get_prediction(Q_input, target)
            local inv = arkpred:get_invisible_duration(target)
            if output.hit_chance > hit_chance and inv < (Q.delay / 2) then
                local targetPos = output.cast_pos
                local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(localPredPos, aimPos, targetPos)
                if pointSegment and isOnSegment and target:distance_to(vec3.new(pointSegment.x, 0, pointSegment.y)) <= ((target.bounding_radius / 2) + width) then
                    count = count + 1
                    table.insert(table_output, player)
                end
            end
     	end
 	end
	return count, table_output
end

--[[local function GetLineTargetCountMinion(source, aimPos, delay, spellrange, speed, radius)
    local Count = 0
    for _, target in ipairs(game.minions) do
        Range = spellrange * spellrange
        if IsValid(target) and target.is_enemy and --[[GetQDmg(target) > target.health and GetDistanceSqr(myHero, target) < Range then

            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + radius) * (target.bounding_radius + radius)) then
                Count = Count + 1
            end
        end
    end
    return Count
end]]

-- Casting

local function CastQ(unit)
	local output = arkpred:get_prediction(Q_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(kal_q_hitchance) / 100 and inv < Q.delay / 2 then
		local p = output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
	end
end

local function CastE()
	spellbook:cast_spell(SLOT_E, E.delay)
end

local function CastR()
	spellbook:cast_spell(SLOT_R, R.delay)
end

-- Combo

local function Combo()

	target = selector:find_target(Q.range, mode_health)
	if menu:get_value(kal_combo_use_q) == 1 and Ready(SLOT_Q) and not myHero.is_winding_up then
        if IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				CastQ(target)
			end
		end
    end
end

--Harass

local function Harass()

    Mana = myHero.mana/myHero.max_mana >= menu:get_value(kal_harass_min_mana) / 100
	target = selector:find_target(Q.range, mode_health)
	if menu:get_value(kal_harass_use_q) == 1 and Ready(SLOT_Q) and Mana and not myHero.is_winding_up then
        if IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				CastQ(target)
			end
		end
    end
end	

-- KillSteal

local function AutoKill()

	for _, target in ipairs(GetEnemyHeroes()) do
		if IsValid(target) and IsKillable(target) then
            if menu:get_value(kal_ks_use_e) == 1 and Ready(SLOT_E) then
				if GetEDmg(target) > target.health then
					CastE()
				end
			end	

			if menu:get_value(kal_ks_use_q) == 1 and Ready(SLOT_Q) and not myHero.is_winding_up then
				if myHero:distance_to(target.origin) <= Q.range then
					if GetQDmg(target) > target.health then
						CastQ(target)
					end
				end
			end	
		end	
	end
end

-- Lane Clear

local function Clear()

	if Ready(SLOT_E) and menu:get_value(kal_laneclear_e) == 1 and menu:get_value(kal_laneclear_auto_e) == 0 then
		for _, target in ipairs(game.minions) do
			if target.is_enemy and IsValid(target) and IsKillable(target) then
				if GetEDmg(target) > target.health then
					CastE()
				end
			end
		end
	end

    if menu:get_value(kal_laneclear_q) == 1 and Ready(SLOT_Q) then
        for _, hero in ipairs(GetEnemyHeroes()) do
            if IsValid(hero) and myHero:distance_to(hero.origin) <= Q.range then
                count, targets = TotalLineTest(myHero, Q.delay, Q.speed, Q.width, hero)
				if count > 0 and size(targets) > 0 then
					q_target = GetFirst(table.sort(targets, cmp))
					CastQ(q_target)
				end
            end
        end
    end    
end

local function Auto_Incoming_Logic()

	if Ready(SLOT_E) and menu:get_value(kal_auto_e_death) == 1 then
		hittime = menu:get_value(kal_hittime) / 1000
		incoming_dmg = getincommingdmg(myHero, hittime)
		if incoming_dmg >= myHero.health then
			CastE()
		end 
	end

	if menu:get_value(kal_r_use) == 1 and Ready(SLOT_R) then
		for _, ally in ipairs(GetAllyHeroes()) do
			if IsValid(ally) and ally:has_buff("kalistacoopstrikeally") then
				ally_hittime = menu:get_value(kal_hittime) / 1000
				ally_incoming_dmg = getincommingdmg(ally, ally_hittime)
				if ally_incoming_dmg >= ally.health then
					CastR()
				end 
				
				if GetEnemyCountCicular(500, ally) >= 2 and ally:health_percentage() <= 10 then 
					CastR()
				end	
			end
		end
	end
end	

-- object returns, draw and tick usage

screen_size = game.screen_size
local function on_draw()

	if menu:get_value(kal_enabled) == 1 and myHero.is_alive then

		if Updatedraw and myHero.is_on_screen then
			renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2, "Shaun's Kalista Updated.. Press F5")
		end	

		if menu:get_value(kal_draw_q) == 1 and Ready(SLOT_Q) then
			renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, Q.range, 255, 255, 255, 255)
		end
		
		if menu:get_value(kal_draw_er) == 1 then
			if Ready(SLOT_E) or Ready(SLOT_R) then
				renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, E.range, 0, 255, 255, 255)
			end
		end
        
		--------------------------------------------------------------------------------------------------------------------------------

        for _, target in ipairs(GetEnemyHeroes()) do
            if IsValid(target) then
                local dmg = GetEDmg(target)
                if dmg > 0 then
                    target:draw_damage_health_bar(dmg)
                end
            end
        end

        for _, jungle in ipairs(game.jungle_minions) do
            if menu:get_value(kal_jungleclear_e) == 1 and IsValid(jungle) and EpicMonster(jungle) then
                local jungledmg = GetEDmg(jungle)
                if jungledmg > 0 then
					neg_dmg = jungle.health - jungledmg
					a = game:world_to_screen(jungle.origin.x, jungle.origin.y, jungle.origin.z)
					formated = tonumber(string.format("%.1f", neg_dmg))
					renderer:draw_text_big_centered(a.x, a.y + 50, tostring(formated) .. "  Damage Remaining To Auto [E]")
                end
            end
        end
	end
end

local function on_tick()

	if menu:get_value(kal_enabled) == 1 then

		for _, target in ipairs(game.jungle_minions) do
			if menu:get_value(kal_jungleclear_e) == 1 and Ready(SLOT_E) and IsValid(target) and IsKillable(target) then
				if EpicMonster(target) then
	
					if GetEDmg(target) > target.health then
						CastE()
					end
					
					local ComboDmg = GetQDmg(target) + GetEDmg(target)
					if Ready(SLOT_Q) and ComboDmg >= target.health then
						local output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
						if output.can_cast then
							local castPos = output.cast_pos
							spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end	
			end   
		end

		if menu:get_value(kal_laneclear_e) == 1 and menu:get_value(kal_laneclear_auto_e) == 1 and Ready(SLOT_E) then
			for _, target_e in ipairs(game.minions) do
				if target_e.is_enemy and IsValid(target_e) and IsKillable(target_e) then
					if GetEDmg(target_e) > target_e.health then
						CastE()
					end
				end
			end
        end

		--------------------------------------------------------------------------------------------------------------------------------

		if game:is_key_down(menu:get_value(kal_combokey)) then
			Combo()
        end

		if combo:get_mode() == MODE_HARASS then
			Harass()
        end

		if combo:get_mode() == MODE_LANECLEAR then
			Clear()
        end
	
		Auto_Incoming_Logic()
		AutoKill()

	end	
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
