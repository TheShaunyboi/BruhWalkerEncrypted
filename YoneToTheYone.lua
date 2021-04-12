if game.local_player.champ_name ~= "Yone" then
	return
end

-- AutoUpdate
do
    local function AutoUpdate()
		local Version = 1
		local file_name = "YoneToTheYone.lua"
		local url = "http://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/YoneToTheYone.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/YoneToTheYone.lua.version.txt")
        console:log("YoneToTheYone.Lua Vers: "..Version)
		console:log("YoneToTheYone.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Sexy Yone successfully loaded.....")
        else
			http:download_file(url, file_name)
            console:log("Sexy Yone Update available.....")
			console:log("Please reload via F5.....")
        end

    end

    AutoUpdate()

end

pred:use_prediction()

local myHero = game.local_player
local local_player = game.local_player

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 450, delay = .25 }
local W = { range = 600, delay = .35, width = 700 , speed = 0 }
local R = { range = 1000, delay = .75, width = 225, speed = 0 }


-- Return game data

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

local function GetDistanceSqr2(unit, p2)
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.origin
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

-- Menu Config

yone_category = menu:add_category("Shaun's Sexy Yone")
yone_enabled = menu:add_checkbox("Enabled", yone_category, 1)
yone_combokey = menu:add_keybinder("Combo Mode Key", yone_category, 32)

yone_ks_function = menu:add_subcategory("Kill Steal", yone_category)
yone_ks_use_q = menu:add_checkbox("Use Q", yone_ks_function, 1)
yone_ks_use_w = menu:add_checkbox("Use W", yone_ks_function, 1)
yone_ks_use_r = menu:add_checkbox("Use R", yone_ks_function, 1)

yone_lasthit = menu:add_subcategory("Last Hit", yone_category)
yone_lasthit_use = menu:add_checkbox("Use Q Last Hit", yone_lasthit, 1)
yone_lasthit_auto = menu:add_checkbox("Auto Q Only Last Hit", yone_lasthit, 1)

yone_combo = menu:add_subcategory("Combo", yone_category)
yone_combo_use_q = menu:add_checkbox("Use Q", yone_combo, 1)
yone_combo_use_w = menu:add_checkbox("Use W", yone_combo, 1)
yone_combo_use_r = menu:add_checkbox("Use R", yone_combo, 1)

yone_harass = menu:add_subcategory("Harass", yone_category)
yone_harass_use_q = menu:add_checkbox("Use Q", yone_harass, 1)
yone_harass_use_w = menu:add_checkbox("Use W", yone_harass, 1)

yone_laneclear = menu:add_subcategory("Lane Clear", yone_category)
yone_laneclear_use_q = menu:add_checkbox("Use Q", yone_laneclear, 1)
yone_laneclear_use_w = menu:add_checkbox("Use W", yone_laneclear, 1)
yone_laneclear_min_q = menu:add_slider("Minimum Minion To Q", yone_combo_r_options, 1, 10, 1)
yone_laneclear_min_w = menu:add_slider("Minimum Minion To w", yone_combo_r_options, 1, 10, 3)

yone_jungleclear = menu:add_subcategory("Jungle Clear", yone_category)
yone_jungleclear_use_q = menu:add_checkbox("Use Q", yone_jungleclear, 1)
yone_jungleclear_use_w = menu:add_checkbox("Use W", yone_jungleclear, 1)

yone_combo_r_options = menu:add_subcategory("R Settings", yone_category)
yone_combo_r_enemy_hp = menu:add_slider("Use Combo R if Enemy HP is lower than [%]", yone_combo_r_options, 1, 100, 50)
yone_combo_r_my_hp = menu:add_slider("Only Combo R if My HP is Greater than [%]", yone_combo_r_options, 1, 100, 20)
yone_combo_r_auto = menu:add_checkbox("Use Auto R", yone_combo_r_options, 0)
yone_combo_r_auto_x = menu:add_slider("Number Of Targets To Perform Auto R", yone_combo_r_options, 1, 5, 3)
yone_combo_r_set_key = menu:add_keybinder("Semi Manual R Key", yone_combo_r_options, 65)

yone_draw = menu:add_subcategory("Drawing Features", yone_category)
yone_draw_q = menu:add_checkbox("Draw Q", yone_draw, 1)
yone_draw_w = menu:add_checkbox("Draw W", yone_draw, 1)
yone_draw_r = menu:add_checkbox("Draw R", yone_draw, 1)
yone_lasthit = menu:add_checkbox("Draw Auto Q Last Hit", yone_draw, 1)
BColorR = menu:add_slider("Red", yone_draw, 1, 255, 220)
BColorG = menu:add_slider("Green", yone_draw, 1, 255, 55)
BColorB = menu:add_slider("Blue", yone_draw, 1, 255, 14)
BColorA = menu:add_slider("Alpha", yone_draw, 1, 255, 255)

-- Damage

local function GetQDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_Q).level
	local BonusDmg = myHero.total_attack_damage
	local QDamage = (({20, 40, 60, 80, 100})[level] + BonusDmg)
	if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_phys_damage(Damage)
end

local function GetWDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_W).level
	local BonusDmg = ({0.055, 0.06, 0.065, 0.07, 0.075})[level] * unit.max_health
	local WDamage = (({5, 10, 15, 20, 25})[level] + BonusDmg)
	if HasHealingBuff(unit) then
      Damage = WDamage - 10
  else
			Damage = WDamage
  end
	return unit:calculate_phys_damage(Damage)
end

local function GetRDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_R).level
	local BonusDmg = (0.4 * myHero.total_attack_damage)
	local RDamage = (({100, 200, 300})[level] + BonusDmg)
	if HasHealingBuff(unit) then
			Damage = RDamage - 10
	else
			Damage = RDamage
	end
	return unit:calculate_phys_damage(Damage)
end

-- Casting

local function CastQ(unit)
	target = selector:find_target(Q.range, health)

	if target.object_id ~= 0 then
		if Ready(SLOT_Q) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
			orbwalker:reset_aa()
		end
	end
end

local function CastW(unit)
	target = selector:find_target(W.range, health)

	if target.object_id ~= 0 then
		if Ready(SLOT_W) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

local function CastR(unit)
	target = selector:find_target(R.range, health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			if target:health_percentage() <= menu:get_value(yone_combo_r_enemy_hp) then
				if local_player:health_percentage() >= menu:get_value(yone_combo_r_my_hp) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

					if pred_output.can_cast then
        		castPos = pred_output.cast_pos
        		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

-- Combo

local function Combo()
	if menu:get_value(yone_combo_use_q) == 1 then
			CastQ(target)
		end
	end

	if menu:get_value(yone_combo_use_w) == 1 and not Ready(SLOT_Q) then
		if not orbwalker:can_attack() then
			CastW(target)
		end
	end

	if menu:get_value(yone_combo_use_r) == 1 then
		CastR(target)
	end
end

--Harass

local function Harass()
	if menu:get_value(yone_harass_use_q) == 1 then
		CastQ(target)
	end


	if menu:get_value(yone_harass_use_w) == 1 then
			CastW(target)
		end
	end
end

-- KillSteal

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and Ready(SLOT_Q) and IsValid(target) then
			if menu:get_value(yone_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
						orbwalker:reset_aa()
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <=  W.range and Ready(SLOT_W) and IsValid(target) then
			if menu:get_value(yone_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)

						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and Ready(SLOT_R) and IsValid(target) then
			if menu:get_value(yone_ks_use_r) == 1 then
				if GetRDmg(target) > target.health then
					if Ready(SLOT_R) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

						if pred_output.can_cast then
	        		castPos = pred_output.cast_pos
	        		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(yone_laneclear_use_q) == 1 and menu:get_value(yone_lasthit_auto) == 0 then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= menu:get_value(yone_laneclear_min_q) then
					if not orbwalker:can_attack() or myHero.attack_range < myHero:distance_to(target.origin)
						if Ready(SLOT_Q) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
							orbwalker:reset_aa()
						end
					end
				end
			end
		end
		if menu:get_value(yone_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range and IsValid(target) then
				if GetMinionCount(W.range, target) >= menu:get_value(yone_laneclear_min_w) then
					if not Ready(SLOT_Q) then
						if Ready(SLOT_W) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)

							if pred_output.can_cast then
								castPos = pred_output.cast_pos
								spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
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
	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(yone_jungleclear_use_q) == 1 and Ready(SLOT_Q) and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if Ready(SLOT_Q) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
				orbwalker:reset_aa()
			end
		end
		if target.object_id ~= 0 and menu:get_value(yone_jungleclear_use_w) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < W.range and IsValid(target) then
			if not Ready(SLOT_Q) then
				if Ready(SLOT_W) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	target = selector:find_target(R.range, health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

-- Auto R >= Targets

local function AutoRxTargets()
	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and Ready(SLOT_R) and IsValid(target) then
			if GetEnemyCount(R.range, myHero) >= menu:get_value(yone_combo_r_auto_x) then
				if Ready(SLOT_R) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)
					if GetEnemyCount(R.range, pred_output) >= menu:get_value(yone_combo_r_auto_x) then
						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
	end
end

-- Auto Q last Hit

local function AutoQLastHit(target)
	minions = game.minions
	for i, target in ipairs(minions) do
		if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if GetMinionCount(Q.range, target) >= 1 then
				if GetQDmg(target) > target.health then
					if not orbwalker:can_attack() or myHero.attack_range < myHero:distance_to(target.origin)
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
						orbwalker:reset_aa()
					end
				end
			end
		end
	end
end

-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z

		if menu:get_value(yone_draw_q) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, Q.range, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end

		if menu:get_value(yone_draw_w) == 1 then
			if Ready(SLOT_W) then
				renderer:draw_circle(x, y, z, W.range, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end

		if menu:get_value(yone_draw_r) == 1 then
			if Ready(SLOT_R) then
				renderer:draw_circle(x, y, z, R.range, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end
	end

	if menu:get_value(yone_lasthit_draw) == 1 and menu:get_value(yone_lasthit_auto) == 1 then
		renderer:draw_text(screen_size.width / 2, screen_size.height / 20, "Auto Q Only Last Hit Enabled")
	end
end

local function on_tick()
	if game:is_key_down(menu:get_value(yone_combokey)) and menu:get_value(yone_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(yone_combo_r_set_key)) then
		ManualRCast()
	end

	if menu:get_value(yone_combo_r_auto) == 1 then
		AutoRxTargets()
	end

	if combo:get_mode() == MODE_LASTHIT and menu:get_value(yone_lasthit_use) == 1 and menu:get_value(yone_lasthit_auto) == 0 then
	elseif menu:get_value(yone_lasthit_auto) == 1 then
		AutoQLastHit()
	end
	KillSteal()
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
