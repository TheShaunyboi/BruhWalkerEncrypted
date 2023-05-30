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
    local LuaVersion = 0.8
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

    local file_name = "VectorMath.lua"
	if not file_manager:file_exists(file_name) then
	    local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
	    http:download_file_async(url, file_name,function()
		    console:log("VectorMath Library Downloaded")
		    console:log("Please Reload with F5")
	   end)
	end

    local file_name = "ShaunPrediction.lua"
    if not file_manager:file_exists(file_name) then
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua"
		http:download_file_async(url, file_name,function()
            console:log("ShaunPrediction Downloaded")
		    console:log("Please Reload with F5")
		end)
	end

    self.myHero = game.local_player
    require "Prediction"
    self.ShaunPred = require "ShaunPrediction"
    self.ml = require "VectorMath"
    self.q_harass = {
        source = self.myHero,
        speed = math.huge, range = 1000,
        delay = 0.25, radius = 40,
        collision = {},
        type = "linear", hitbox = true
    }

    self.qDelay = nil
    self.aaComplete = false
    self.rTarget = nil
    self.screen_size = game.screen_size
    self.version = 0.8
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

    self.lucian_rotation = menu:add_subcategory("Combo Rotation Priority", self.lucian_category)
        self.combo_table = {}
        self.combo_table[1] = "[Q] First Priority"
        self.combo_table[2] = "[W] OnHit Only First Priority"
        self.combo_rotation = menu:add_dropdown("Select Rotation Priority", self.lucian_rotation, self.combo_table, 0)
    --

    self.lucian_combo = menu:add_subcategory("Combo", self.lucian_category)
        self.combo_q = menu:add_checkbox("Use [Q]", self.lucian_combo, 1)
        self.combo_w = menu:add_checkbox("Use [W]", self.lucian_combo, 1)
        self.combo_e = menu:add_checkbox("Use [E]", self.lucian_combo, 1)
        self.combo_e_short = menu:add_checkbox("Use Smart Short [E]", self.lucian_combo, 1)
        self.e_mouse_combo = menu:add_checkbox("Only Use [E] When Holding Key", self.lucian_combo, 0)
        self.e_key = menu:add_keybinder("[E] When Holding Key", self.lucian_combo, string.byte("X"))
    --

    self.lucian_harass = menu:add_subcategory("Harass", self.lucian_category)
        self.harass_mana = menu:add_slider("Mana [%]", self.lucian_harass, 1, 100, 20)
        self.harass_q = menu:add_checkbox("Use [Q]",  self.lucian_harass, 1)
        self.harass_w = menu:add_checkbox("Use [W]",  self.lucian_harass, 1)
        self.harass_e = menu:add_checkbox("Use [E]",  self.lucian_harass, 0)
        self.harass_e_short = menu:add_checkbox("Use Smart Short [E]",  self.lucian_harass, 0)
        self.e_mouse_harass = menu:add_checkbox("Only Use [E] When Holding Key", self.lucian_harass, 0)
        self.harass_q_ext = menu:add_checkbox("Use [Q] Extended",  self.lucian_harass, 1)
        self.hc = menu:add_slider("[Q] Extended Hit Chance", self.lucian_harass, 1, 100, 45)
    --

    self.lucian_jungle = menu:add_subcategory("Jungle", self.lucian_category)
        self.jungle_mana = menu:add_slider("Mana [%]", self.lucian_jungle, 1, 100, 20)
        self.jungle_q = menu:add_checkbox("Use [Q]",  self.lucian_jungle, 1)
        self.jungle_w = menu:add_checkbox("Use [W]",  self.lucian_jungle, 1)
        self.jungle_e = menu:add_checkbox("Use [E]",  self.lucian_jungle, 1)
    --

    self.lucian_r = menu:add_subcategory("[R] Features", self.lucian_category)
        self.r_key = menu:add_keybinder("Semi Manual [R] Key - Target Closest To Cursor", self.lucian_r, string.byte("A"))
        self.magnet_enabled = menu:add_checkbox("Use [R] Magnet",  self.lucian_r, 1)
        self.use_w_magnet = menu:add_checkbox("Use [W] before [R] For Speed Boost Passive",  self.lucian_r, 1)
    --

    self.lucian_draw = menu:add_subcategory("Draw Features", self.lucian_category)
        self.r_draw = menu:add_checkbox("Draw [R] Range",  self.lucian_draw, 1)
        self.q_ext_draw = menu:add_checkbox("Draw [Q] Extended Range",  self.lucian_draw, 1)
    --

    menu:add_label("version "..(tostring(self.version)), self.lucian_category)
end    

function Lucian:ready(spell)
    return spellbook:can_cast(spell)
end

function Lucian:isValid(object, distance)
    return object and object.is_valid and object.is_enemy and object.is_targetable and
    not object:has_buff("SionPassiveZombie") and
    not object:has_buff("FioraW") and
    not object:has_buff("sivire") and
    not object:has_buff("nocturneshroudofdarkness") and
    object.is_alive and not object:has_buff_type(18) and
    not object:has_buff_type(16) and
    (not distance or object:distance_to(self.myHero.origin) <= distance)
end

function Lucian:GetEnemyHeroes()
	local _EnemyHeroes = {}
	players = game.players
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

function Lucian:on_post_attack(target)
    if (combo:get_mode() == 1 or combo:get_mode() == 2) and target.is_hero then 
        self.aaComplete = true
    elseif combo:get_mode() == 3 and target.is_jungle_minion then
        self.aaComplete = true
    end
end

function Lucian:OnAfterAttack(target)    
    if (combo:get_mode() == 1 or combo:get_mode() == 2) and target.is_hero then 
        self.aaComplete = true
    elseif combo:get_mode() == 3 and target.is_jungle_minion then
        self.aaComplete = true
    end
end

function Lucian:GetDistanceSqr2(p1, p2)
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1x, p1y, p1z = p1.x, p1.y, p1.z
	local dx = p1x - p2x
	local dz = (p1z or p1y) - (p2z or p2y)
	return dx*dx + dz*dz
end

function Lucian:VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function Lucian:GetLineTargetCount(startPos, endPos, radius)
	local minion = nil
	for _, unit in ipairs(game.minions) do
		if self:isValid(unit, self.q_harass.range) then
			local pointSegment, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(startPos.origin, endPos, unit.origin)
			if pointSegment and isOnSegment and (self:GetDistanceSqr2(unit.origin, pointSegment) <= radius * radius) then
				minion = unit
			end
		end
	end
	return minion
end

function Lucian:IsUnderTurret(unit)
    for i, v in ipairs(game.turrets) do
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

function Lucian:getRTarget()
    if self.rTarget then return end
    if self.myHero:has_buff("LucianR") then return end
    if not self:ready(SLOT_R) then return end
    local use_w = menu:get_value(self.use_w_magnet) == 1 

    local rRange = 1200
    local newTarget = selector:find_target(rRange, mode_cursor)
    if newTarget then
        self.rTarget = newTarget
        local p = self.rTarget.origin

        if use_w and self:ready(SLOT_W) and self.rTarget:distance_to(self.myHero.origin) <= 800 then
            spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
            spellbook:cast_spell(SLOT_R, 0.25, p.x, p.y, p.z)
        end 

        if (use_w and not self:ready(SLOT_W)) or not use_w or self.rTarget:distance_to(self.myHero.origin) > 800 then 
            spellbook:cast_spell(SLOT_R, 0.25, p.x, p.y, p.z)
        end
    end
end

function Lucian:magnetTarget()
    if not self.rTarget then return end

    local targetPos
    local hit_speed = 2800
    local time = self.rTarget:distance_to(self.myHero.origin) / hit_speed
    local r = {
        source = self.myHero,
        speed = math.huge, range = 1200,
        delay = time, radius = 110,
        collision = {},
        type = "linear", hitbox = true
    }

    local pred = self.ShaunPred:calculatePrediction(self.rTarget, r, self.myHero)
    if pred and pred.hitChance >= 0.45 then
        targetPos = pred.castPos
    end

    if targetPos then 
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
end

function Lucian:letsGoBaby()
    local keyHeld = game:is_key_down(menu:get_value(self.r_key))
    local use_magnet = menu:get_value(self.magnet_enabled) == 1 
    local use_w = menu:get_value(self.use_w_magnet) == 1 

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
    local use_e_short = menu:get_value(self.combo_e_short) == 1 
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

            if use_e_short and (not target.is_melee or target:health_percentage() < 35) then
                local p = self.ml.Extend(game.mouse_pos, self.myHero.origin, -100)
                spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
                self.aaComplete = false
            else
                local m = game.mouse_pos
                spellbook:cast_spell(SLOT_E, 0.25, m.x, m.y, m.z)
                self.aaComplete = false
            end
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

function Lucian:comboMotherfuckers_wRotation()
    local use_q = menu:get_value(self.combo_q) == 1 
    local use_w = menu:get_value(self.combo_w) == 1 
    local use_e = menu:get_value(self.combo_e) == 1 
    local use_e_short = menu:get_value(self.combo_e_short) == 1 
    local e_mouse = menu:get_value(self.e_mouse_combo) == 1 
    local e_key = game:is_key_down(menu:get_value(self.e_key))

    local wtarget = selector:find_target(850, mode_health)
    local target = orbwalker:get_orbwalker_target()

    if self.myHero:has_buff("LucianPassiveBuff") then return end 

    if use_w and self:ready(SLOT_W) and wtarget then
        local hit_speed = 1600
        local time = wtarget:distance_to(self.myHero.origin) / hit_speed
        local w = {
            source = self.myHero,
            speed = math.huge, range = 800,
            delay = time, radius = 55,
            collision = {"minion", "wind_wall"},
            type = "linear", hitbox = true
        }

        local pred = self.ShaunPred:calculatePrediction(wtarget, w, self.myHero)
        if pred and pred.hitChance >= 0.45 then
            local p = pred.castPos
            spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
        end
    end

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

            if use_e_short and (not target.is_melee or target:health_percentage() < 35) then
                local p = self.ml.Extend(game.mouse_pos, self.myHero.origin, -100)
                spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
                self.aaComplete = false
            else
                local m = game.mouse_pos
                spellbook:cast_spell(SLOT_E, 0.25, m.x, m.y, m.z)
                self.aaComplete = false
            end
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
    local use_e_short = menu:get_value(self.harass_e_short) == 1 
    local e_mouse = menu:get_value(self.e_mouse_harass) == 1 
    local use_q_ext = menu:get_value(self.harass_q_ext) == 1 

    local q_hc = menu:get_value(self.hc) / 100
    local e_key = game:is_key_down(menu:get_value(self.e_key))

    local mana = menu:get_value(self.harass_mana)
    if self.myHero:mana_percentage() < mana then return end

    if use_q_ext and self:ready(SLOT_Q) and not self:IsUnderTurret(self.myHero) then
        for _, qHarass in ipairs(self:GetEnemyHeroes()) do
            if self:isValid(qHarass, self.q_harass.range) and qHarass:distance_to(self.myHero.origin) > self.myHero.attack_range then

                local pred = self.ShaunPred:calculatePrediction(qHarass, self.q_harass, self.myHero)
                if pred and pred.hitChance >= q_hc then
                    local qMinion = self:GetLineTargetCount(self.myHero, pred.castPos, self.q_harass.radius)
                    if qMinion then
                        spellbook:cast_spell_targetted(SLOT_Q, qMinion, self.qDelay or 0.25)
                    end
                end
            end
        end
    end

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

            if use_e_short and (not target.is_melee or target:health_percentage() < 30) then
                local p = self.ml.Extend(game.mouse_pos, self.myHero.origin, -100)
                spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
                self.aaComplete = false
            else
                local m = game.mouse_pos
                spellbook:cast_spell(SLOT_E, 0.25, m.x, m.y, m.z)
                self.aaComplete = false
            end
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

function Lucian:JtoTheJungle()
    local use_q = menu:get_value(self.jungle_q) == 1 
    local use_w = menu:get_value(self.jungle_w) == 1 
    local use_e = menu:get_value(self.jungle_e) == 1

    local mana = menu:get_value(self.jungle_mana)
    if self.myHero:mana_percentage() < mana then return end

    for _, target in ipairs(game.jungle_minions) do
        if self:isValid(target, self.myHero.attack_range) then
            if self:ready(SLOT_Q) and use_q then
                spellbook:cast_spell_targetted(SLOT_Q, target, self.qDelay or 0.25)
                self.aaComplete = false
            end

            if not self.aaComplete then return end
            if self:ready(SLOT_Q) then return end

            if use_e and self:ready(SLOT_E) then
                local p = self.ml.Extend(game.mouse_pos, self.myHero.origin, -100)
                spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
                self.aaComplete = false
            end
        
            if (not use_w or not self:ready(SLOT_W)) then return end
        
            if not self:ready(SLOT_E) or not use_e then
                local p = target.origin
                spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
                self.aaComplete = false
            end
        end
    end
end

function Lucian:on_tick_always()
    if menu:get_value(self.lucian_enabled) == 0 then return end 
    if self.myHero.is_winding_up then return end 

    if combo:get_mode() == 1 then
        if menu:get_value(self.combo_rotation) == 0 then
            self:comboMotherfuckers()
        elseif menu:get_value(self.combo_rotation) == 1 then
            self:comboMotherfuckers_wRotation()
        end

    elseif combo:get_mode() == 2 then
        self:harassGayboys()
    elseif combo:get_mode() == 3 then
        self:JtoTheJungle()
    end
    
    self:letsGoBaby()
    
    if not self:ready(SLOT_Q) then
        goto fuckthis
    end

    self.qDelay = 0.4 - 0.15 / 17 * (spellbook:get_spell_slot(SLOT_Q).level - 1)
    ::fuckthis::
end

function Lucian:on_draw()
    local use_q_ext = menu:get_value(self.harass_q_ext) == 1 
    local draw_q_ext = menu:get_value(self.q_ext_draw) == 1 

    if use_q_ext then
        renderer:draw_text_centered(self.screen_size.width / 2, 0, "[Q] Extended Harass Enabled")
    end

    if draw_q_ext and self:ready(SLOT_Q) then
        renderer:draw_circle(self.myHero.origin.x, self.myHero.origin.y, self.myHero.origin.z, 1000, 0, 255, 255, 255)
    end

    local draw_r = menu:get_value(self.r_draw) == 1 
    if (not draw_r or not self:ready(SLOT_R) and not self.myHero:has_buff("LucianR")) then return end
    renderer:draw_circle(self.myHero.origin.x, self.myHero.origin.y, self.myHero.origin.z, 1200, 255, 255, 255, 255)
end

local lucianScript = Lucian:new()
