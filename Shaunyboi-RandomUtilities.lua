local UpdateDraw = false
do
  	local function AutoUpdate()
		local Version = 0.3
		local file_name = "Shaunyboi-RandomUtilities.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shaunyboi-RandomUtilities.lua"
		local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shaunyboi-RandomUtilities.lua.version.txt")
		console:log("Shaunyboi-RandomUtilities.lua Vers: "..Version)
		console:log("Shaunyboi-RandomUtilities.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
			console:log("Shauny's Utilities Successfully Loaded...")
		else
			http:download_file(url, file_name)
			console:log("Shaunyboi-Random Utilities Update Available...")
			console:log("Please Reload via F5!...")	
			UpdateDraw = true
		end	
  	end

  AutoUpdate()
end

--Ensuring that the librarys and sound files are downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

if not file_manager:file_exists("Shaun's Sexy Common//MaleFirstKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleFirstKillSound.wav", "Shaun's Sexy Common//MaleFirstKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//FemaleFirstKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleFirstKillSound.wav", "Shaun's Sexy Common//FemaleFirstKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//MaleSecondKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleSecondKillSound.wav", "Shaun's Sexy Common//MaleSecondKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//FemaleSecondKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleSecondKillSound.wav", "Shaun's Sexy Common//FemaleSecondKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//MaleThirdKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleThirdKillSound.wav", "Shaun's Sexy Common//MaleThirdKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//FemaleThirdKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleThirdKillSound.wav", "Shaun's Sexy Common//FemaleThirdKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//MaleForthKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleForthKillSound.wav", "Shaun's Sexy Common//MaleForthKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//FemaleForthKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleForthKillSound.wav", "Shaun's Sexy Common//FemaleForthKillSound.wav")
end

if not file_manager:file_exists("Shaun's Sexy Common//MalePentaKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MalePentaKillSound.wav", "Shaun's Sexy Common//MalePentaKillSound.wav")
end

local SoundsDownloaded = false
if not file_manager:file_exists("Shaun's Sexy Common//FemalePentaKillSound.wav") then
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemalePentaKillSound.wav", "Shaun's Sexy Common//FemalePentaKillSound.wav")
	console:log("--- ALL SOUNDS ARE DOWNLOADED PLEASE PRESS F5--- ")
	console:log("--- LOVE YOU ALL <3 ---")
	SoundsDownloaded = true
end


--Initialization lines:

local myHero = game.local_player
local local_player = game.local_player
--Initialization lines:
local ml = require "VectorMath"

local kill_1 = false
local kill_2 = false
local kill_3 = false
local kill_4 = false
local kill_5 = false
local startTime_kill_1 = nil
local startTime_kill_2 = nil
local startTime_kill_3 = nil
local startTime_kill_4 = nil
local startTime_kill_5 = nil
local endTime_kill_1 = nil
local endTime_kill_2 = nil
local endTime_kill_3 = nil
local endTime_kill_4 = nil
local endTime_kill_5 = nil

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	random_category = menu:add_category_sprite("Shauny's Random Utilities", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	random_category = menu:add_category("Shauny's Random Utilities")
end

random_enabled = menu:add_checkbox("Enabled", random_category, 1)
menu:add_label("Shauny's Random Utilities", random_category)
menu:add_label("#Loveyou", random_category)

thresh_grab = menu:add_subcategory("[Auto Thresh Lantern Features]", random_category)
thresh_lantern_key = menu:add_keybinder("Auto Lantern Grab Key ", thresh_grab, 32)
thresh_auto_ward = menu:add_checkbox("Use [Wards] On Enemy Thresh Lantern", thresh_grab, 1)

vision_wards = menu:add_subcategory("[Auto Ward On Vision Lost Settings]", random_category)
menu:add_label("Vision Lost In All Grass Area's While Holding Combo Key", vision_wards)
random_no_vision = menu:add_checkbox("Use [Ward] On Vision Lost", vision_wards, 1)
random_no_vision_blue = menu:add_checkbox("Use [Blue Ward] On Vision Lost", vision_wards, 1)
random_no_vision_yellow = menu:add_checkbox("Use [Yellow Ward] On Vision Lost", vision_wards, 1)
random_no_vision_control = menu:add_checkbox("Use [Control Ward] On Vision Lost", vision_wards, 1)

ping_vision = menu:add_subcategory("[Auto Ping New Vision]", random_category)
auto_ping_vision = menu:add_checkbox("Use [WARD HERE] Ping On New Enemy Wards", ping_vision, 1)

sounds_selector = menu:add_subcategory("[Kill Sounds Settings]", random_category)
sounds_selector_use = menu:add_checkbox("Use [Kill Sounds]", sounds_selector, 1)
sounds_selector_1 = menu:add_subcategory("[First Kill Sound] Settings", sounds_selector)
a_table = {}
a_table[1] = "Quake Male Voice"
a_table[2] = "Quake Female Voice"
a_table[3] = "Disabled"
sounds_selector_voice_1 = menu:add_combobox("[First Kill Selector]", sounds_selector_1, a_table, 0)

sounds_selector_2 = menu:add_subcategory("[Second Kill Sound] Settings", sounds_selector)
b_table = {}
b_table[1] = "Quake Male Voice"
b_table[2] = "Quake Female Voice"
b_table[3] = "Disabled"
sounds_selector_voice_2 = menu:add_combobox("[Second Kill Selector]", sounds_selector_2, b_table, 0)

sounds_selector_3 = menu:add_subcategory("[Third Kill Sound] Settings", sounds_selector)
c_table = {}
c_table[1] = "Quake Male Voice"
c_table[2] = "Quake Female Voice"
c_table[3] = "Disabled"
sounds_selector_voice_3 = menu:add_combobox("[Third Kill Selector]", sounds_selector_3, c_table, 0)

sounds_selector_4 = menu:add_subcategory("[Forth Kill Sound] Settings", sounds_selector)
d_table = {}
d_table[1] = "Quake Male Voice"
d_table[2] = "Quake Female Voice"
d_table[3] = "Disabled"
sounds_selector_voice_4 = menu:add_combobox("[Forth Kill Selector]", sounds_selector_4, d_table, 0)

sounds_selector_5 = menu:add_subcategory("[Penta Kill Sound] Settings", sounds_selector)
e_table = {}
e_table[1] = "Quake Male Voice"
e_table[2] = "Quake Female Voice"
e_table[3] = "Disabled"
sounds_selector_voice_5 = menu:add_combobox("[Penta Kill Selector]", sounds_selector_5, e_table, 0)

draw_killreset = menu:add_checkbox("Display Active Kill Reset Timer", sounds_selector, 1)


local function on_kda_updated(kill, death, assist)

  if menu:get_value(random_enabled) == 1 then

  	if menu:get_value(sounds_selector_use) == 1 then
  		if kill and not kill_1 and not kill_2 and not kill_3 and not kill_4 and not kill_5 then
  			startTime_kill_1 = os.time()
  			endTime_kill_1 = startTime_kill_1+10
  			if menu:get_value(sounds_selector_voice_1) == 0 then
  				client:play_sound("Shaun's Sexy Common//MaleFirstKillSound.wav")
  			elseif menu:get_value(sounds_selector_voice_1) == 1 then
  				client:play_sound("Shaun's Sexy Common//FemaleFirstKillSound")
  			end
  			kill_1 = true
  			return
  		end

  		-----------------------------------------------------------------------------------

  		if kill and kill_1 and not kill_2 and not kill_3 and not kill_4 and not kill_5 then
  			startTime_kill_2 = os.time()
  			endTime_kill_2 = startTime_kill_2+10
  			if menu:get_value(sounds_selector_voice_2) == 0 then
  				client:play_sound("Shaun's Sexy Common//MaleSecondKillSound.wav")
  			elseif menu:get_value(sounds_selector_voice_2) == 1 then
  				client:play_sound("Shaun's Sexy Common//FemaleSecondKillSound.wav")
  			end
  			kill_2 = true
  			return
  		end

  		-----------------------------------------------------------------------------------

  		if kill and kill_1 and kill_2 and not kill_3 and not kill_4 and not kill_5 then
  			startTime_kill_3 = os.time()
  			endTime_kill_3 = startTime_kill_3+10
  			if menu:get_value(sounds_selector_voice_3) == 0 then
  				client:play_sound("Shaun's Sexy Common//MaleThirdKillSound.wav")
  			elseif menu:get_value(sounds_selector_voice_3) == 1 then
  				client:play_sound("Shaun's Sexy Common//FemaleThirdKillSound.wav")
  			end
  			kill_3 = true
  			return
  		end

  		-----------------------------------------------------------------------------------

  		if kill and kill_1 and kill_2 and kill_3 and not kill_4 and not kill_5 then
  			startTime_kill_4 = os.time()
  			endTime_kill_4 = startTime_kill_4+30
  			if menu:get_value(sounds_selector_voice_4) == 0 then
  				client:play_sound("Shaun's Sexy Common//MaleForthKillSound.wav")
  			elseif menu:get_value(sounds_selector_voice_4) == 1 then
  				client:play_sound("Shaun's Sexy Common//FemaleForthKillSound.wav")
  			end
  			kill_4 = true
  			return
  		end

  		-----------------------------------------------------------------------------------

  		if kill and kill_1 and kill_2 and kill_3 and kill_4 and not kill_5 then
  			if menu:get_value(sounds_selector_voice_5) == 0 then
  				client:play_sound("Shaun's Sexy Common//MalePentaKillSound.wav")
  			elseif menu:get_value(sounds_selector_voice_5) == 1 then
  				client:play_sound("Shaun's Sexy Common//FemalePentaKillSound.wav")
  			end

  			kill_4 = false
  			kill_3 = false
  			kill_2 = false
  			kill_1 = false
  			kill_5 = false
  			endTime_kill_1 = nil
  			endTime_kill_2 = nil
  			endTime_kill_3 = nil
  			endTime_kill_4 = nil
  			kill_5 = false
  		end

  		-----------------------------------------------------------------------------------

  		if death then
  			kill_5 = false
  			kill_4 = false
  			kill_3 = false
  			kill_2 = false
  			kill_1 = false
  			endTime_kill_1 = nil
  			endTime_kill_2 = nil
  			endTime_kill_3 = nil
  			endTime_kill_4 = nil
  		end
  	end
  end
end

-- on_lose_vision --

local function BlueWardCheck()
	local inventory = ml.GetItems()
	for _, v in ipairs(inventory) do
		if ml.Ready(SLOT_WARD) and tonumber(v) == 3363 then
			return true
		end
	end
	return false
end

local function YellowWardCheck()
	local inventory = ml.GetItems()
	for _, v in ipairs(inventory) do
		if ml.Ready(SLOT_WARD) and tonumber(v) == 3340 then
			return true
		end
	end
	return false
end

local function ControlWardCheck()
  local control_ward = false
  local control_ward_slot = nil
  local inventory = ml.GetItems()
  	for _, v in ipairs(inventory) do
		if tonumber(v) == 2055 then
			local item = local_player:get_item(tonumber(v))
			if item ~= 0 then
				control_ward_slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
				if ml.Ready(control_ward_slot) then
					control_ward = true
				end
			end
		end
  	end
  return control_ward, control_ward_slot
end

local function on_lose_vision(obj)

	if menu:get_value(random_enabled) == 1 and menu:get_value(random_no_vision) == 1 then
		if nav_mesh:is_grass(obj.origin.x, obj.origin.y, obj.origin.z) and combo:get_mode() == 1 or combo:get_mode() == MODE_COMBO then
			
			local control_ward, control_ward_slot = ControlWardCheck()

			if menu:get_value(random_no_vision_blue) == 1 and myHero:distance_to(obj.origin) <= 1000 then
				if BlueWardCheck() then
					spellbook:cast_spell(SLOT_WARD, 0.5, obj.origin.x, obj.origin.y, obj.origin.z)
				end
			end
			if menu:get_value(random_no_vision_yellow) == 1 and myHero:distance_to(obj.origin) <= 600 then
				if YellowWardCheck() then
					spellbook:cast_spell(SLOT_WARD, 0.5, obj.origin.x, obj.origin.y, obj.origin.z)
				end
			end
			if menu:get_value(random_no_vision_control) == 1 and myHero:distance_to(obj.origin) <= 600 then
				if not YellowWardCheck() and not BlueWardCheck() and control_ward then
					if ml.Ready(control_ward_slot) then
						spellbook:cast_spell(control_ward_slot, 0.5, obj.origin.x, obj.origin.y, obj.origin.z)
					end
				end
			end
		end
	end	
end

local function on_object_created(obj, obj_name)
	if menu:get_value(auto_ping_vision) == 1 then
		if obj.is_ward and obj.is_enemy then
			game:send_ping(obj.origin.x, obj.origin.y, obj.origin.z, PING_VISION)
		end
	end	
end

-----------------------------------------------------------------------------------

local function on_draw()

	local screen_size = game.screen_size
	local justme = myHero.origin
	local myherodraw = game:world_to_screen(justme.x, justme.y, justme.z)

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

  	if menu:get_value(random_enabled) == 1 and menu:get_value(sounds_selector_use) == 1 then

		if menu:get_value(draw_killreset) == 1 and kill_1 and not kill_2 then
			if myHero.is_on_screen and endTime_kill_1 ~= nil then
				local countdown = endTime_kill_1 - os.time()
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 40, "Double Kill Reset Time")
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 80, tostring(countdown))
			end
		end
		if menu:get_value(draw_killreset) == 1 and kill_2 and not kill_3 then
			if myHero.is_on_screen and endTime_kill_2 ~= nil then
				local countdown = endTime_kill_2 - os.time()
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 40, "Triple Kill Reset Time")
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 80, tostring(countdown))
			end
		end
		if menu:get_value(draw_killreset) == 1 and kill_3 and not kill_4 then
			if myHero.is_on_screen and endTime_kill_3 ~= nil then
				local countdown = endTime_kill_3 - os.time()
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 40, "Quadra Kill Reset Time")
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 80, tostring(countdown))
			end
		end
		if menu:get_value(draw_killreset) == 1 and kill_4 then
			if myHero.is_on_screen and endTime_kill_4 ~= nil then
				local countdown = endTime_kill_4 - os.time()
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 40, "Penta Kill Reset Time")
				renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 80, tostring(countdown))
			end
		end
  	end

	if UpdateDraw then
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2 + 60, "Shaun's Utilities Update Available... Press F5")
	end	
	if SoundsDownloaded then
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2 + 80, "All Quake Kill Sounds Downloaded... Press F5")
	end	
end

local function on_tick()

  	if menu:get_value(random_enabled) == 1 and menu:get_value(sounds_selector_use) == 1 then

		if kill_1 and endTime_kill_1 ~= nil then
			if os.time() > endTime_kill_1 then
				if not kill_2 and not kill_3 and not kill_4 and not kill_5 then
					kill_5 = false
					kill_4 = false
					kill_3 = false
					kill_2 = false
					kill_1 = false
					endTime_kill_1 = nil
					endTime_kill_2 = nil
					endTime_kill_3 = nil
					endTime_kill_4 = nil
				end
			end
		end

		if kill_2 and endTime_kill_2 ~= nil then
			if os.time() > endTime_kill_2 then
				if not kill_3 and not kill_4 and not kill_5 then
					kill_5 = false
					kill_4 = false
					kill_3 = false
					kill_2 = false
					kill_1 = false
					endTime_kill_1 = nil
					endTime_kill_2 = nil
					endTime_kill_3 = nil
					endTime_kill_4 = nil
				end
			end
		end

		if kill_3 and endTime_kill_3 ~= nil then
			if os.time() > endTime_kill_3 then
				if not kill_4 and not kill_5 then
					kill_5 = false
					kill_4 = false
					kill_3 = false
					kill_2 = false
					kill_1 = false
					endTime_kill_1 = nil
					endTime_kill_2 = nil
					endTime_kill_3 = nil
					endTime_kill_4 = nil
				end
			end
		end

		if kill_4 and endTime_kill_4 ~= nil then
			if os.time() > endTime_kill_4 then
				if not kill_5 then
					kill_5 = false
					kill_4 = false
					kill_3 = false
					kill_2 = false
					kill_1 = false
					endTime_kill_1 = nil
					endTime_kill_2 = nil
					endTime_kill_3 = nil
					endTime_kill_4 = nil
				end
			end
		end


		if game:is_key_down(menu:get_value(thresh_lantern_key)) then
			allypets = game.pets
			for _, allyminion in ipairs(allypets) do
				if not allyminion.is_enemy and allyminion:distance_to(myHero.origin) <= myHero.attack_range and allyminion.object_name == "ThreshLantern" then
					spellbook:cast_spell_targetted(62, allyminion, 0.25)
				end
			end	
		end	

		if menu:get_value(thresh_auto_ward) == 1 then
			local control_ward, control_ward_slot = ControlWardCheck()
			pets = game.pets
			for _, minion in ipairs(pets) do
				if minion.is_enemy and minion:distance_to(myHero.origin) <= 600 and minion.object_name == "ThreshLantern" then
					if BlueWardCheck() or YellowWardCheck() then
						spellbook:cast_spell(SLOT_WARD, 0.5, minion.origin.x, minion.origin.y, minion.origin.z)
					else 
						if control_ward and ml.Ready(control_ward_slot) then
							spellbook:cast_spell(control_ward_slot, 0.5, minion.origin.x, minion.origin.y, minion.origin.z)
						end
					end	
				end
			end	
		end	
	end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_kda_updated", on_kda_updated)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_lose_vision", on_lose_vision)
client:set_event_callback("on_object_created", on_object_created)
