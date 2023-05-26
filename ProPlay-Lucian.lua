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
    local LuaVersion = 0.6
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
    self.rTarget = nil
    self.version = 0.5
    self:create_menu()

    client:set_event_callback("on_tick_always", function() self:on_tick_always() end)
    client:set_event_callback("on_post_attack", function(target) self:on_post_attack(target) end)
    client:set_event_callback("on_draw", function() self:on_draw() end)
    _G.DynastyOrb:AddCallback("OnAfterAttack", function(target) self:OnAfterAttack(target) end)
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
        self.e_mouse_combo = menu:add_checkbox("Only Use [E] When Holding Key", self.lucian_combo, 0)
        self.e_key = menu:add_keybinder("[E] When Holding Key", self.lucian_combo, string.byte("X"))
    --

    self.lucian_harass = menu:add_subcategory("Harass", self.lucian_category)
        self.harass_mana = menu:add_slider("Mana [%]", self.lucian_harass, 1, 100, 20)
        self.harass_q = menu:add_checkbox("Use [Q]",  self.lucian_harass, 1)
        self.harass_w = menu:add_checkbox("Use [W]",  self.lucian_harass, 1)
        self.harass_e = menu:add_checkbox("Use [E]",  self.lucian_harass, 0)
        self.e_mouse_harass = menu:add_checkbox("Only Use [E] When Holding Key", self.lucian_harass, 0)
    --

    self.lucian_r = menu:add_subcategory("[R] Features", self.lucian_category)
        self.r_key = menu:add_keybinder("Semi Manual [R] Key - Target Closest To Cursor", self.lucian_r, string.byte("A"))
        self.magnet_enabled = menu:add_checkbox("Use [R] Magnet",  self.lucian_r, 1)
    --

    self.lucian_draw = menu:add_subcategory("Draw Features", self.lucian_category)
        self.r_draw = menu:add_checkbox("Draw [R] Range",  self.lucian_draw, 1)
    --

    menu:add_label("version "..(tostring(self.version)), self.lucian_category)
end    

function Lucian:ready(spell)
    return spellbook:can_cast(spell)
end

function Lucian:on_post_attack(target)
    if not target.is_hero then return end 
    self.aaComplete = true
end

function Lucian:OnAfterAttack(target)    
	if not target.is_hero then return end
    self.aaComplete = true
end

function Lucian:cross(v1, v2)
    local x = v1.y * v2.z - v1.z * v2.y
    local y = v1.z * v2.x - v1.x * v2.z
    local z = v1.x * v2.y - v1.y * v2.x
    local v = vec3.new(x, y, z)
    return v
end

function Lucian:getRTarget()
    if self.rTarget then return end
    if self.myHero:has_buff("LucianR") then return end
    if not self:ready(SLOT_R) then return end

    local rRange = 1200
    local newTarget = selector:find_target(rRange, mode_cursor)
    if newTarget then
        local p = newTarget.origin
        spellbook:cast_spell(SLOT_R, 0.25, p.x, p.y, p.z)
        self.rTarget = newTarget
    end
end

function Lucian:magnetTarget()
    if not self.rTarget then return end

    local targetPos = self.rTarget.origin
    local targetMoveDir = self.rTarget.direction
    targetMoveDir:normalize()

    local myPos = self.myHero.origin
    local dirToTarget = targetPos:subtract(myPos)
    dirToTarget:normalize()

    local followDistance = 500

    -- Calculate the cross product manually
    local x3 = targetMoveDir.y * 0 - 0 * targetMoveDir.z
    local y3 = 0 * targetMoveDir.x - targetMoveDir.z * 0
    local z3 = targetMoveDir.x * 0 - 0 * targetMoveDir.y
    local offsetDir = vec3.new(x3, y3, z3)

    local newPos = targetPos:subtract(dirToTarget:multiply(vec3.new(followDistance, followDistance, followDistance)))
    newPos = newPos:add(offsetDir:multiply(vec3.new(followDistance, followDistance, followDistance)))

    if self.myHero:distance_to(targetPos) <= followDistance then 
        issueorder:stop(newPos)
    else
        issueorder:move(newPos)
    end
end

function Lucian:letsGoBaby()
    local keyHeld = game:is_key_down(menu:get_value(self.r_key))
    local use_magnet = menu:get_value(self.magnet_enabled) == 1 
    
    if keyHeld and not self.rTarget then
        self:getRTarget()
    end

    if self.myHero:has_buff("LucianR") and keyHeld and use_magnet then
        self:magnetTarget()
    end
    
    if not self.myHero:has_buff("LucianR") and self.rTarget and not keyHeld then
        self.rTarget = nil
    end
end

function Lucian:comboMotherfuckers()
    local use_q = menu:get_value(self.combo_q) == 1 
    local use_w = menu:get_value(self.combo_w) == 1 
    local use_e = menu:get_value(self.combo_e) == 1 
    local e_mouse = menu:get_value(self.e_mouse_combo) == 1 
    local e_key = game:is_key_down(menu:get_value(self.e_key))

    local target = orbwalker:get_orbwalker_target()
    if (not target or not target.is_valid or not target.is_hero) then return end 
    if self.myHero:has_buff("LucianPassiveBuff") then return end 

    local qRange = 500 + target.bounding_radius
    if use_q and self:ready(SLOT_Q) and target and target:distance_to(self.myHero.origin) <= qRange then
        spellbook:cast_spell_targetted(SLOT_Q, target, self.qDelay or 0.25)
        self.aaComplete = false
    end

    if not self.aaComplete then return end
    if self:ready(SLOT_Q) then return end
    
    if use_e and self:ready(SLOT_E) then
        if (e_mouse and e_key or not e_mouse) then
            local m = game.mouse_pos
            spellbook:cast_spell(SLOT_E, 0.25, m.x, m.y, m.z)
            self.aaComplete = false
        end
    end

    if (not use_w or not self:ready(SLOT_W)) then return end

    if (not e_mouse and (not self:ready(SLOT_E) or not use_e)) or (e_mouse and not e_key or not self:ready(SLOT_E)) then
        if target then
            local p = target.origin
            spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
            self.aaComplete = false
        end
    end
end

function Lucian:harassGayboys()
    local use_q = menu:get_value(self.harass_q) == 1 
    local use_w = menu:get_value(self.harass_w) == 1 
    local use_e = menu:get_value(self.harass_e) == 1
    local e_mouse = menu:get_value(self.e_mouse_harass) == 1 
    local e_key = game:is_key_down(menu:get_value(self.e_key))

    local mana = menu:get_value(self.harass_mana)
    if self.myHero:mana_percentage() < mana then return end

    local target = orbwalker:get_orbwalker_target()
    if (not target or not target.is_valid or not target.is_hero) then return end 
    if self.myHero:has_buff("LucianPassiveBuff") then return end 

    local qRange = 500 + target.bounding_radius
    if use_q and self:ready(SLOT_Q) and target and target:distance_to(self.myHero.origin) <= qRange then
        spellbook:cast_spell_targetted(SLOT_Q, target, self.qDelay or 0.25)
        self.aaComplete = false
    end

    if not self.aaComplete then return end
    if self:ready(SLOT_Q) then return end
    
    if use_e and self:ready(SLOT_E) then
        if (e_mouse and e_key or not e_mouse) then
            local m = game.mouse_pos
            spellbook:cast_spell(SLOT_E, 0.25, m.x, m.y, m.z)
            self.aaComplete = false
        end
    end

    if (not use_w or not self:ready(SLOT_W)) then return end

    if (not e_mouse and (not self:ready(SLOT_E) or not use_e)) or (e_mouse and not e_key or not self:ready(SLOT_E)) then
        if target then
            local p = target.origin
            spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
            self.aaComplete = false
        end
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
    
    self:letsGoBaby()
    
    if not self:ready(SLOT_Q) then
        goto fuckthis
    end

    self.qDelay = 0.4 - 0.15 / 17 * (spellbook:get_spell_slot(SLOT_Q).level - 1)
    ::fuckthis::
end

function Lucian:on_draw()
    local draw_r = menu:get_value(self.r_draw) == 1 
    if (not draw_r or not self:ready(SLOT_R) and not self.myHero:has_buff("LucianR")) then return end
    renderer:draw_circle(self.myHero.origin.x, self.myHero.origin.y, self.myHero.origin.z, 1200, 255, 255, 255, 255)
end

local lucianScript = Lucian:new()
