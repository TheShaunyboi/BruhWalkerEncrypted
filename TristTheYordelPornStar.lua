if game.local_player.champ_name ~= "Tristana" then
	return
end

--[[do
    local function AutoUpdate()
		local Version = 1
		local file_name = "TristyTheBitchy.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/TristyTheBitchy.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/TristyTheBitchy.lua.version.txt")
        console:log("TristyTheBitchy.lua Vers: "..Version)
		console:log("TristyTheBitchyn.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".......................................................................................")
						console:log(".......................................................................................")
            console:log("Shaun's Sexy Tristana v1 Successfully Loaded")
						console:log(".......................................................................................")
						console:log(".......................................................................................")

        else
			http:download_file(url, file_name)
			      console:log("Sexy Tristana Update available.....")
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
end]]

pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player
local TristJumped = false
local LastPos = nil

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { delay = .1 }
local W = { range = 900, delay = .25, width = 350, speed = 1100 }
local E = { delay = .1, width = 300, speed = 2400  }
local R = { delay = .25, width = 200, speed = 2000 }
local QERrange = { 525, 533, 541, 549, 557, 565, 573, 581, 589, 597, 605, 613, 621, 629, 637, 645, 653, 661 }

-- Return game data and maths

--Converts from Degrees to Radians
local function D2R(degrees)
  radians = degrees * (math.pi / 180)
  return radians
end

--Subtract two vectors
local function Sub(vec1, vec2)
  new_x = vec1.x - vec2.x
  new_y = vec1.y - vec2.y
  new_z = vec1.z - vec2.z
  sub = vec3.new(new_x, new_y, new_z)
  return sub
end

--Multiplies vector by magnitude
local function VectorMag(vec, mag)
  x, y, z = vec.x, vec.y, vec.z
  new_x = mag * x
  new_y = mag * y
  new_z = mag * z
  output = vec3.new(new_x, new_y, new_z)
  return output
end

--Dot product of two vectors
local function DotProduct(vec1, vec2)
  dot = (vec1.x * vec2.x) + (vec1.y * vec2.y) + (vec1.z * vec2.z)
  return dot
end

--Vector Magnitude
local function Magnitude(vec)
  mag = math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
  return mag
end

--Returns the angle formed from a vector to both input vectors
local function AngleBetween(vec1, vec2)
  dot = DotProduct(vec1, vec2)
  mag1 = Magnitude(vec1)
  mag2 = Magnitude(vec2)
  output = (math.acos(dot / (mag1 * mag2)))
  return output
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

function Extend(vec, distance)
    ratio = (Magnitude(vec) + distance) / (Magnitude(vec))
    output = VectorMag(vec, ratio)
    return output
end

-- Best Prediction Start

local function GetCenter(points)
	local sum_x = 0
	local sum_z = 0

	for i = 1, #points do
		sum_x = sum_x + points[i].origin.x
		sum_z = sum_z + points[i].origin.z
	end

	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
	return center
end

local function ContainsThemAll(circle, points)
	local radius_sqr = circle.radi*circle.radi
	local contains_them_all = true
	local i = 1

	while contains_them_all and i <= #points do
		contains_them_all = GetDistanceSqr2(points[i].origin, circle.center) <= radius_sqr
		i = i + 1
	end
	return contains_them_all
end

local function FarthestFromPositionIndex(points, position)
	local index = 2
	local actual_dist_sqr
	local max_dist_sqr = GetDistanceSqr2(points[index].origin, position)

	for i = 3, #points do
		actual_dist_sqr = GetDistanceSqr2(points[i].origin, position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end
	return index
end

local function RemoveWorst(targets, position)
	local worst_target = FarthestFromPositionIndex(targets, position)
	table.remove(targets, worst_target)
	return targets
end

local function GetInitialTargets(radius, main_target)
	local targets = {main_target}
	local diameter_sqr = 4 * radius * radius

	for i, target in ipairs(GetEnemyHeroes()) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and IsValid(target) and GetDistanceSqr(main_target, target) < diameter_sqr then
			table.insert(targets, target)
		end
	end
	return targets
end

local function GetPredictedInitialTargets(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local predicted_main_target = pred:predict(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	if predicted_main_target.can_cast then
		local predicted_targets = {main_target}
		local diameter_sqr = 4 * radius * radius

		for i, target in ipairs(GetEnemyHeroes()) do
			if target.object_id ~= 0 and IsValid(target) then
				predicted_target = pred:predict(math.huge, delay, 1800, radius, target, false, false)
				if predicted_target.can_cast and target.object_id ~= main_target.object_id and GetDistanceSqr2(predicted_main_target.cast_pos, predicted_target.cast_pos) < diameter_sqr then
					table.insert(predicted_targets, target)
				end
			end
		end
	return predicted_targets
	end
end

local function GetBestAoEPosition(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local targets = GetPredictedInitialTargets(speed ,delay, range, radius, main_target, ColWindwall, ColMinion) or GetInitialTargets(radius, main_target)
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = {pos = position, radi = radius}
	circle.center = position

	if #targets >= 2 then best_pos_found = ContainsThemAll(circle, targets) end

	while not best_pos_found do
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end
	return vec3.new(position.x, position.y, position.z), #targets
end

local function AoEDraw()
	for i, unit in ipairs(GetEnemyHeroes()) do
		local Dist = myHero:distance_to(unit.origin)
		if unit.object_id ~= 0 and IsValid(unit) and Dist < 1500 then
			local CastPos, targets = GetBestAoEPosition(R.speed, R.delay, R.range, R.width, unit, false, false)
			if CastPos then
				renderer:draw_circle(CastPos.x, CastPos.y, CastPos.z, 50, 0, 137, 255, 255)
				screen_pos = game:world_to_screen(CastPos.x, CastPos.y, CastPos.z)
				x, y = screen_pos.x, screen_pos.y
				renderer:draw_text_big(x, y, "Count = "..tostring(targets), 220, 20, 60, 255)
			end
		end
	end
end

-- Best Prediction End

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

local function GetLineTargetCount(StartPos, EndPos, delay, speed, width)
	local castpos = nil
	local minions = game.minions
	for i, unit in ipairs(minions) do
		if IsValid(unit) and unit.team ~= myHero.team and game.local_player:distance_to(unit.origin) < 650 then

			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, unit.origin)

			if pointSegment and isOnSegment and (GetDistanceSqr2(unit.origin, pointSegment) <= width * width) then
				castpos = unit
			end
		end
	end
	return castpos
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

local function GetMinionCountCicular(range, p1)
		count = 0
		minions = game.minions
		for i, minion in ipairs(minions) do
				Range = range * range
        if minion.is_enemy and IsValid(minion) and minion.object_id ~= minion.object_id and GetDistanceSqr(p1, minion.origin) < Range then
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

local function HasPoison(unit)
    if unit:has_buff_type(23) then
        return true
    end
    return false
end

local function HasHealingBuff(unit)
    if myHero:distance_to(unit.origin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
        return true
    end
    return false
end

local function ECount(unit)
    if unit:has_buff"tristanaecharge") then
        buff = unit:get_buff("tristanaecharge")
        if buff.count > 0 then
            return buff
        end
    end
    return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end


local function HasECharge(unit)
	if unit:has_buff("tristanaecharge") then
		return true
	end
	return false
end

local function HasBuff(unit)
	if unit:has_buff(buff) then
		return true
	end
	return false
end


local function GetGameTime()
	return tonumber(game.game_time)
end

local function Is_Me(unit)
	if unit.champ_name == myHero.champ_name then
		return true
	end
	return false
end

local function IsImmobileTarget(unit)
    if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(10) or unit:has_buff_type(11) or unit:has_buff_type(21) or unit:has_buff_type(22) or unit:has_buff_type(24) or unit:has_buff_type(29) then
        return true
    end
    return false
end


local function EpicMonsterPlusSiege(unit)
	if unit.champ_name == "SRU_Baron"
		or unit.champ_name == "SRU_RiftHerald"
		or unit.champ_name == "SRU_Dragon_Water"
		or unit.champ_name == "SRU_Dragon_Fire"
		or unit.champ_name == "SRU_Dragon_Earth"
		or unit.champ_name == "SRU_Dragon_Air"
		or unit.champ_name == "SRU_Dragon_Elder"
		or unit.champ_name == "SRU_ChaosMinionSiege"
		or unit.champ_name == "SRU_OrderMinionSiege" then
		return true
	else
		return false
	end
end

local function IsUnderTurret(unit)
    turrets = game.turrets
    for i, v in ipairs(turrets) do
        if v and v.is_enemy then
            local range = (v.bounding_radius / 2 + 1000 + unit.bounding_radius / 2)
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
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
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

-- Damage Cals

local function GetEDmg(unit)
	local eLvl = spellbook:get_spell_slot(SLOT_E).level
	if eLvl > 0 then
		local raw = ({ 154, 176, 198, 220, 242 })[eLvl]
		local m = ({ 1.1, 1.65, 2.2, 2.75, 3.3 })[eLvl]
		local bonusDmg = (m * myHero.bonus_attack_damage) + (1.1 * myHero.ability_power)
		local FullDmg = raw + bonusDmg
		return unit:calculate_phys_damage(FullDmg)
	end
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
	trist_category = menu:add_category_sprite("Shaun's Sexy Tristana", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	trist_category = menu:add_category("Shaun's Sexy Tristana")
end

trist_enabled = menu:add_checkbox("Enabled", trist_category, 1)
trist_combokey = menu:add_keybinder("Combo Mode Key", trist_category, 32)
menu:add_label("Welcome To Shaun's Sexy Tristana", trist_category)
menu:add_label("#BigGunSmall....Penis?", trist_category)

trist_ks_function = menu:add_subcategory("Kill Steal", trist_category)
trist_ks_use_er = menu:add_checkbox("Use [E] + [R]", trist_ks_e, 1)
trist_ks_w = menu:add_subcategory("[W] + [R] Smart Settings", trist_ks_function, 1)
trist_ks_use_w = menu:add_checkbox("Use Smart [W] + [R]", trist_ks_w, 1)
trist_ks_use_w_back = menu:add_slider("[W] Back To Original Position IF My HP < than [%]", trist_ks_w, 1, 100, 20)
trist_ks_use_w_count = menu:add_slider("Only [W] + [R] IF Target Count <= 'X' Number", trist_ks_w, 1, 5, 2)
trist_ks_r = menu:add_subcategory("[R] Smart Settings", trist_ks_function, 1)
trist_ks_use_r = menu:add_checkbox("Use [R]", trist_ks_r, 1)
trist_ks_use_r_aa = menu:add_slider("Don't Use [R] IF 'X' AA Can Kill", trist_ks_r, 1, 10, 3)
trist_ks_blacklist = menu:add_subcategory("Kill Steal Blacklist", trist_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Kill Steal Blacklist: "..tostring(t.champ_name), trist_ks_blacklist, 1)
    end
end

trist_combo = menu:add_subcategory("Combo", trist_category)
trist_combo_q = menu:add_subcategory("[Q] Settings", trist_combo)
trist_combo_use_q = menu:add_checkbox("Use [Q]", trist_combo_q, 1)
trist_combo_w = menu:add_subcategory("[W] Smart Settings", trist_combo)
trist_combo_use_w = menu:add_checkbox("Use Smart [W]", trist_combo_w, 1)
trist_combo_use_w_hp = menu:add_slider("[W] IF Target HP lower than [%]", trist_combo_w, 1, 100, 30)
trist_combo_use_w_count = menu:add_slider("Only [W] IF Target Count <= 'X' Number", trist_combo_w, 1, 5, 1)
trist_combo_e = menu:add_subcategory("[E] Settings", trist_combo)
trist_combo_use_e = menu:add_checkbox("Use [E]", trist_combo_e, 1)

trist_harass = menu:add_subcategory("Harass", trist_category)
trist_harass_q = menu:add_subcategory("[Q] Settings", trist_harass)
trist_harass_use_q = menu:add_checkbox("Use [Q]", trist_harass_q, 1)
trist_harass_e = menu:add_subcategory("[E] Settings", trist_harass)
trist_harass_use_e = menu:add_checkbox("Use [E]", trist_harass_e, 1)
trist_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", trist_harass, 1, 100, 20)
trist_harass_blacklist = menu:add_subcategory("Harass Target Blacklist", trist_harass)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Harass Blacklist: "..tostring(t.champ_name), trist_harass_blacklist, 1)
    end
end

trist_laneclear = menu:add_subcategory("Lane Clear", trist_category)
trist_laneclear_use_q = menu:add_checkbox("Use [Q]", trist_laneclear, 1)
trist_laneclear_use_e = menu:add_checkbox("Use [E] On Cannon Minion", trist_laneclear, 1)
trist_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", trist_laneclear, 1, 100, 20)
trist_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", trist_laneclear, 1, 10, 3)

trist_jungleclear = menu:add_subcategory("Jungle Clear", trist_category)
trist_jungleclear_use_q = menu:add_checkbox("Use [Q]", trist_jungleclear, 1)
trist_jungleclear_use_e = menu:add_checkbox("Use [E]", trist_jungleclear, 1)
trist_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", trist_jungleclear, 1, 100, 20)

trist_extra = menu:add_subcategory("[Sexy] Extra Features", trist_category)
trist_extra_turret = menu:add_checkbox("Smart [E] Turrent Usage", trist_extra, 1)
trist_extra_semi_r_key = menu:add_keybinder("[R] Semi Manual Key - Target Closest To Cursor", trist_extra, 65)
trist_extra_gapclose = menu:add_checkbox("[R] Anti Gap Closer", trist_extra, 1)
trist_extra_interrupt = menu:add_checkbox("[R] Interrupt Major Channel Spells", trist_extra, 1)
trist_extra_gapclose_blacklist = menu:add_subcategory("Anti Gap Closer Blacklist", trist_extra)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Anti Gap Closer Blacklist: "..tostring(t.champ_name), trist_extra_gapclose_blacklist, 1)
    end
end

trist_extra_interrupt_blacklist = menu:add_subcategory("Interrupt Blacklist", trist_extra)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Interrupt Blacklist: "..tostring(t.champ_name), trist_extra_interrupt_blacklist, 1)
    end
end

trist_draw = menu:add_subcategory("The Drawing Features", trist_category)
trist_draw_w = menu:add_checkbox("Draw [W] Range", trist_draw, 1)
trist_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", trist_draw, 1)
trist_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo Colours On Target Health Bar", trist_draw, 1)

-- Casting

local function CastQ()
	spellbook:cast_spell(SLOT_Q, Q.delay)
end

local function CastW(unit)
	pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_W, W.delay, castPos.x + 400, castPos.y, castPos.z)
	end
end

local function CastE(unit)
	origin = target.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
	orbwalker:reset_aa()
end

local function CastR(unit)
	origin = target.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
	orbwalker:reset_aa()
end

-- Combo

local function Combo()

	target = selector:find_target(1500, mode_health)

	if menu:get_value(trist_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and HasECharge(target) then
				CastQ()
			end
		end
	end

	if menu:get_value(trist_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) > QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= W.range and GetEnemyCountCicular(1500, target.origin) <= menu:get_value(trist_combo_use_w_count) then
		   	if Ready(SLOT_W) and Ready(SLOT_E) and menu:get_value(trist_combo_use_w_hp) < target.health and not IsUnderTurret(target) then
					CastW(target)
				end
			end
		end
	end


	if menu:get_value(trist_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) < QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_E) then
				CastE(target)
			end
		end
	end
end

-- Combo

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(trist_harass_min_mana) / 100
	target = selector:find_target(W.range, mode_health)

	if menu:get_value(trist_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and HasECharge(target) then
				if GrabHarassMana then
					if menu:get_value_string("Harass Blacklist: "..tostring(target.champ_name)) == 1 then
						CastQ()
					end
				end
			end
		end
	end

	if menu:get_value(trist_harass_use_e) == 1 then
		if myHero:distance_to(target.origin) and IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= QERrange[myHero.level] then
				if GrabHarassMana then
					if menu:get_value_string("Harass Blacklist: "..tostring(target.champ_name)) == 1 then
						CastE(target)
					end
				end
			end
		end
	end
end


-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if menu:get_value(trist_ks_use_er) == 1 and HasECharge(target) then
				if menu:get_value_string("Kill Steal Blacklist: "..tostring(target.champ_name)) == 1 then
					local Buff = ECount(target)
					if Buff and Buff.count >= 3 then
						local FullDMG = (GetEDmg(target) + GetRDmg(target))
						if FullDMG > target.health and Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and myHero:distance_to(target.origin) > QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if menu:get_value(trist_ks_use_w) == 1 and GetEnemyCountCicular(1500, target.origin) <= menu:get_value(trist_ks_use_w_count) then
				if menu:get_value_string("Kill Steal Blacklist: "..tostring(target.champ_name)) == 1 then
					if GetRDmg(target) > target.health then
						if Ready(SLOT_W) and Ready(SLOT_R) then
							local LastPos = myHero.origin
							local TristJumped = true
							CastW(target)
						end
					end
				end
			end
		end

		if TristJumped then
			CastR(target)

			local TristHPLow = myHero.health/myHero.max_health <= menu:get_value(trist_ks_use_w_back) / 100
			if TristHPLow and not Ready(SLOT_R) then
				origin = LastPos.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
				LastPos = nil
				TristJumped = false
			end
			if not TristHPLow then
				LastPos = nil
				TristJumped = false
			end
		end

		local AATotalDMG = menu:get_value(trist_ks_use_r_aa) * myHero.total_attack_damage
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= QERrange[myHero.level] and IsValid(target) and IsKillable(target) then
			if menu:get_value(trist_ks_use_r) == 1 then
				if menu:get_value_string("Kill Steal Blacklist: "..tostring(target.champ_name)) == 1 then
					if AATotalDMG > GetRDmg(target) then
						if GetRDmg(target) > target.health then
							CastR(target)
						end
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(trist_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(trist_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < QERrange[myHero.level] then
				if GetMinionCount(QERrange[myHero.level], myHero) >= menu:get_value(trist_laneclear_q_min) then
					if GrabLaneClearMana and Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if menu:get_value(trist_laneclear_use_e) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < QERrange[myHero.level] then
				if EpicMonsterPlusSiege(target) then
					if GrabLaneClearMana and Ready(SLOT_E) then
            CastE(target)
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(trist_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(trist_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < QERrange[myHero.level] then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_Q) then
					CastQ()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(trist_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < QERrange[myHero.level] then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_E) then
          CastE(target)
				end
			end
		end
	end
end

-- Manual R

local function ManualR()
  target = selector:find_target(W.range, mode_cursor)

  if game:is_key_down(menu:get_value(trist_extra_semi_r_key)) then
    if myHero:distance_to(target.origin) < QERrange[myHero.level] then
			if IsValid(target) and IsKillable(target) and Ready(SLOT_R) then
				CastR(target)
			end
    end
  end
end

-- Gap Close

local function on_gap_close(obj, data)

	if menu:get_value(trist_extra_gapclose) == 1 then
    if IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Blacklist: "..tostring(target.champ_name)) == 1 then
	      if myHero:distance_to(obj.origin) < 400 and Ready(SLOT_R) then
	        CastR(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)
	if IsValid(obj) then
    if menu:get_value(trist_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Blacklist: "..tostring(target.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) < QERrange[myHero.level] and Ready(SLOT_R) then
        	CastQ(obj)
				end
			end
		end
	end
end

local function AutoETurret()

	if menu:get_value(trist_extra_turret) == 1 then

		turrets = game.turrets
		for i, target in ipairs(turrets) do

			if target and target.is_enemy then
				if target.is_alive then
					if myHero:distance_to(target.origin) < QERrange[myHero.level]
						if GetEnemyCountCicular(1500, target.origin) == 0 then
							if IsUnderTurret(myHero) and Ready(SLOT_E) then
								CastE(target)
							end
						end
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

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

  if menu:get_value(trist_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end


	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetEDmg(target) + (myHero.total_attack_damage * 3) + GetRDmg(target)
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
			if menu:get_value(trist_draw_kill) == 1 then
				if fulldmg > target.health and IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
					end
				end
			end
		end

		if IsValid(target) and menu:get_value(trist_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(trist_combokey)) and menu:get_value(trist_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(trist_extra_semi_r_key)) then
		ManualR()
	end

	AutoKill()
	AutoETurret()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
