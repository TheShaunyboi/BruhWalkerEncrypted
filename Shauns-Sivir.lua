if game.local_player.champ_name ~= "Sivir" then
	return
end

myHero = game.local_player
arkpred = _G.Prediction

do
    local function AutoUpdate()
		local Version = 0.1
		local file_name = "Shauns-Sivir.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shauns-Sivir.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shauns-Sivir.lua.version.txt")
        console:log("Shauns-Sivir.lua Vers: "..Version)
		console:log("Shauns-Sivir.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
			console:log("Sivir Successfully Loaded..")
        else
			http:download_file(url, file_name)
			console:log("Shauns-Sivir Update Available..")
			console:log("Please Reload via F5!..")
        end
    end
    AutoUpdate()
end

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark Prediction Library Downloaded")
   console:log("Please Reload with F5")
end

local file_name = "Evade.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Evade.lua"
   http:download_file(url, file_name)
   console:log("Ark Evade Downloaded")
   console:log("Please Reload with F5")
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	sivir_category = menu:add_category_sprite("Shaun's Sivir", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	sivir_category = menu:add_category("Shaun's Sivir")
end

sivir_enabled = menu:add_checkbox("Enabled", sivir_category, 1)
menu:add_label("Shaun's Sivir", sivir_category)
q_hitchance = menu:add_slider("[Q] Hit Chance", sivir_category, 1, 100, 50)
combo = menu:add_subcategory("Combo", sivir_category)
sivir_q_combo = menu:add_checkbox("Use [Q]", combo, 1)
sivir_w_combo = menu:add_checkbox("Use [W]", combo, 1)
harass = menu:add_subcategory("Harass", sivir_category)
sivir_q_harass = menu:add_checkbox("Use [Q]", harass, 0)
sivir_w_harass = menu:add_checkbox("Use [W]", harass, 0)
clear = menu:add_subcategory("Clear", sivir_category)
sivir_w_clear = menu:add_checkbox("Use [W]", clear, 0)
e_settings = menu:add_subcategory("[E] & [R] Evade Settings", sivir_category)
sivir_e_low = menu:add_checkbox("Use [E] On Low Chance Of Dodge", e_settings, 1)
sivir_e_imposs = menu:add_checkbox("Use [E] On Impossible To Dodge", e_settings, 1)
danger_lvl = menu:add_slider("Minimum SkillShot Danger Level", e_settings, 1, 5, 2)
menu:add_label("Recalculate Impossible Dodge With [R] Speed When [E] Is On Cooldown", e_settings)
sivir_r = menu:add_checkbox("Use [R] On Impossible To Dodge", e_settings, 1)
draw = menu:add_subcategory("Draw", sivir_category)
draw_q = menu:add_checkbox("Draw [Q] Range", draw, 1)

local function on_post_attack()
	if menu:get_value(sivir_enabled) == 1 and spellbook:can_cast(SLOT_W) then 
	 	if combo:get_mode() == 1 and menu:get_value(sivir_w_combo) == 1 then
			spellbook:cast_spell(SLOT_W, 0.25)
		elseif combo:get_mode() == 2 and menu:get_value(sivir_w_harass) == 1 then
			spellbook:cast_spell(SLOT_W, 0.25)
		elseif combo:get_mode() == 3 and menu:get_value(sivir_w_clear) == 1 then
			spellbook:cast_spell(SLOT_W, 0.25)
		end
	end
end

local function on_tick()
	if spellbook:can_cast(SLOT_E) then
		if menu:get_value(sivir_e_low) == 1 then
			evade:on_low_chance_of_dodge(function(skillshots)
				for _, skillshot in ipairs(skillshots) do
					if skillshot.dangerLevel >= menu:get_value(danger_lvl) then
						spellbook:cast_spell(SLOT_E, 0.25)
						return
					end
				end
			end)
		end

		if menu:get_value(sivir_e_imposs) == 1 then
			evade:on_impossible_dodge(function(skillshots)
				for _, skillshot in ipairs(skillshots) do
					if skillshot.dangerLevel >= menu:get_value(danger_lvl) then
						spellbook:cast_spell(SLOT_E, 0.25)
						return
					end
				end
			end)
		end
	end

	if menu:get_value(sivir_r) == 1 and spellbook:can_cast(SLOT_R) and not spellbook:can_cast(SLOT_E) then
		evade:on_impossible_dodge(function(skillshots)
			for _, skillshot in ipairs(skillshots) do
				if skillshot.dangerLevel == 5 then
					spellbook:cast_spell(SLOT_R, 0.25)
					client:delay_action(function() evade:recalculate_path() end, 0.05)
					return
				end
			end
		end)
	end

	Q_input = { source = myHero, speed = 1450, range = 1250, delay = 0.25, radius = 90, collision = {}, type = "linear", hitbox = true }	
	if combo:get_mode() == 1 and menu:get_value(sivir_q_combo) == 1 or combo:get_mode() == 2 and menu:get_value(sivir_q_harass) == 1 then
		target = selector:find_target(Q_input.Range, mode_health)
		if spellbook:can_cast(SLOT_Q) and target.is_valid and myHero:distance_to(target.origin) <= Q_input.Range then
			output = arkpred:get_prediction(Q_input, target)
			inv = arkpred:get_invisible_duration(target)
			if output.hit_chance >= menu:get_value(q_hitchance) / 100 and inv < Q_input.delay / 2 then
				p = output.cast_pos
				spellbook:cast_spell(SLOT_Q, Q_input.delay, p.x, p.y, p.z)
			end
		end
	end
end

local function on_draw()
	if menu:get_value(draw_q) == 1 and myHero.is_alive and spellbook:can_cast(SLOT_Q) then
		renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, Q_input.Range, 255, 255, 255, 255)
	end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_post_attack", on_post_attack)
