if game.local_player.champ_name ~= "Lucian" then
    return
end

local Lucian = {}
Lucian.__index = Lucian

function Lucian:new()
    local obj = {}
    setmetatable(obj, Lucian)
    obj:init()
    return obj
end

function Lucian:init()
    local LuaVersion = 0.1
	local LuaName = "ProPlay-Lucian"
	local lua_file_name = "ProPlay-Lucian.lua"
	local lua_url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ProPlay-Lucian.lua"
	local version_url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ProPlay-Lucian.lua.version.txt"
    do
		local function AutoUpdate()
			http:get_async(version_url, function(success, web_version)
				console:log(LuaName .. ".lua Vers: "..LuaVersion)
				console:log(LuaName .. ".Web Vers: "..tonumber(web_version))
				if tonumber(web_version) == LuaVersion then
					console:log(LuaName .. " Successfully Loaded..")
				else
					http:download_file_async(lua_url, lua_file_name, function(success)
						if success then
							console:log(LuaName .. " Update available..")
							console:log("Please Reload via F5!..")
						end
					end)
				end
			end)
		end
		AutoUpdate()
	end

    self.myHero = game.local_player
    self.qDelay = nil
    self.aaComplete = false
    self.version = 0.1
    self:create_menu()

    client:set_event_callback("on_tick_always", function() self:on_tick_always() end)
    client:set_event_callback("on_post_attack", function(target) self:on_post_attack(target) end)
    if file_manager:file_exists("DynastyOrb.lua") then
        orbwalker:AddCallback("OnAfterAttack", function(target) self:OnAfterAttack(target) end)
    end
end

function Lucian:create_menu()
    if not file_manager:directory_exists("Shaun's Sexy Common") then
        file_manager:create_directory("Shaun's Sexy Common")
    end

    if file_manager:directory_exists("Shaun's Sexy Common") then
        if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
            self.lucian_category = menu:add_category_sprite("Shaun's ProPlay-Lucian", "Shaun's Sexy Common//Logo.png")
        else
            http:download_file_async("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png", function() 
            end)
            self.lucian_category = menu:add_category("ProPlay-Lucian")
        end
    end

    self.lucian_enabled = menu:add_checkbox("Enabled", self.lucian_category, 1)
    menu:add_label("ProPlay-Lucian", self.lucian_category)

    self.lucian_combo = menu:add_subcategory("Combo", self.lucian_category)
        self.combo_q = menu:add_checkbox("Use [Q]", self.lucian_combo, 1)
        self.combo_w = menu:add_checkbox("Use [W]", self.lucian_combo, 1)
        self.combo_e = menu:add_checkbox("Use [E]", self.lucian_combo, 1)
    --

    self.lucian_harass = menu:add_subcategory("Harass", self.lucian_category)
        self.harass_mana = menu:add_slider("Mana [%]", self.lucian_harass, 1, 100, 20)
        self.harass_q = menu:add_checkbox("Use [Q]",  self.lucian_harass, 1)
        self.harass_w = menu:add_checkbox("Use [W]",  self.lucian_harass, 1)
        self.harass_e = menu:add_checkbox("Use [E]",  self.lucian_harass, 1)
    --
    menu:add_label("version "..(tostring(self.version)), self.lucian_category)
end    

function Lucian:ready(spell)
    return spellbook:can_cast(spell)
end

function Lucian:on_post_attack(target)
    if file_manager:file_exists("DynastyOrb.lua") then return end
    if not target.is_hero then return end 
    self.aaComplete = true
end

if not file_manager:file_exists("DynastyOrb.lua") then
    goto crazybastards
end

function Lucian:OnAfterAttack(target)      
	if not target.is_hero then return end
    self.aaComplete = true
end

::crazybastards::

function Lucian:comboMotherfuckers()
    local use_q = menu:get_value(self.combo_q) == 1 
    local use_w = menu:get_value(self.combo_w) == 1 
    local use_e = menu:get_value(self.combo_e) == 1 

    local target = orbwalker:get_orbwalker_target()
    if not target then return end 

    if use_q and self:ready(SLOT_Q) and not self.myHero:has_buff("LucianPassiveBuff") then
        spellbook:cast_spell_targetted(SLOT_Q, target, self.qDelay)
        self.aaComplete = false
    end

    if not self.aaComplete or not target then return end
    
    if use_w and self:ready(SLOT_W) and not self:ready(SLOT_Q) and not self:ready(SLOT_E) then
        local p = target.origin
        spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
        self.aaComplete = false

    elseif use_e and self:ready(SLOT_E) and not self:ready(SLOT_Q) then
        local m = game.mouse_pos
        spellbook:cast_spell(SLOT_E, 0.1, m.x, m.y, m.z)
        self.aaComplete = false
    end
end

function Lucian:harassGayboys()
    local use_q = menu:get_value(self.harass_q) == 1 
    local use_w = menu:get_value(self.harass_w) == 1 
    local use_e = menu:get_value(self.harass_e) == 1 
    local mana = menu:get_value(self.harass_mana)
    if self.myHero:mana_percentage() < mana then return end

    local target = orbwalker:get_orbwalker_target()
    if not target then return end 

    if use_q and self:ready(SLOT_Q) and not self.myHero:has_buff("LucianPassiveBuff") then
        spellbook:cast_spell_targetted(SLOT_Q, target, self.qDelay)
        self.aaComplete = false
    end

    if not self.aaComplete or not target then return end
    
    if use_w and self:ready(SLOT_W) and not self:ready(SLOT_Q) and not self:ready(SLOT_E) then
        local p = target.origin
        spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
        self.aaComplete = false

    elseif use_e and self:ready(SLOT_E) and not self:ready(SLOT_Q) then
        local m = game.mouse_pos
        spellbook:cast_spell(SLOT_E, 0.1, m.x, m.y, m.z)
        self.aaComplete = false
    end
end

function Lucian:on_tick_always()
    if menu:get_value(self.lucian_enabled) == 0 then return end 
    if self.myHero.is_winding_up then return end 

    if combo:get_mode() == 1 then
        self:comboMotherfuckers()
    elseif combo:get_mode() == 2 then
        self:harassGayboys()
    end

    if not self:ready(SLOT_Q) then
        goto fuckthis
    end

    self.qDelay = 0.4 - 0.15 / 17 * (spellbook:get_spell_slot(SLOT_Q).level - 1)
    ::fuckthis::
end

local lucianScript = Lucian:new()
