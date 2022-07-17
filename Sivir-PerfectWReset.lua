if game.local_player.champ_name ~= "Sivir" then
	return
end

local myHero = game.local_player

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
menu:add_label("Shaun's Sivir [W] Reset", sivir_category)
sivir_w_combo = menu:add_checkbox("Use Combo", sivir_category, 1)
sivir_w_harass = menu:add_checkbox("Use Harass", sivir_category, 0)
sivir_w_clear = menu:add_checkbox("Use Clear", sivir_category, 0)

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

client:set_event_callback("on_post_attack", on_post_attack)
