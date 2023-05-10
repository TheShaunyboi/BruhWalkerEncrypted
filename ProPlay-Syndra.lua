if game.local_player.champ_name ~= "Syndra" then
    return
end

local Syndra = {}
Syndra.__index = Syndra

function Syndra:new()
    local obj = {}
    setmetatable(obj, Syndra)
    obj:init()
    return obj
end

function Syndra:init()
    local LuaVersion = 0.2
	local LuaName = "ProPlay-Syndra"
	local lua_file_name = "ProPlay-Syndra.lua"
	local lua_url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ProPlay-Syndra.lua"
	local version_url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ProPlay-Syndra.lua.version.txt"
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

    self.Q = { range = 800 }
    self.W = { range = 925 }
    self.E = { range = 1100 }
    self.R = { range = 675 }

    self.Q_input = {
        source = myHero,
        speed = math.huge, range = 1100,
        delay = 0.70, radius = 160,
        collision = {},
        type = "circular", hitbox = false
    }

    self.QOnly_input = {
        source = myHero,
        speed = math.huge, range = 800,
        delay = 0.70, radius = 160,
        collision = {},
        type = "circular", hitbox = false
    }

    self.W_input = {
        source = myHero,
        speed = math.huge, range = 950,
        delay = 0.90, radius = 160,
        collision = {},
        type = "circular", hitbox = false
    }

    self.ShaunPred = require "ShaunPrediction"
    self.myHero = game.local_player
    self.ball_moving = false
    self.ballHolder = {}
    self.ballTimer = {}
    self.bounding_radiuses = {}
    self.version = 0.1
    self:create_menu()

    client:set_event_callback("on_tick_always", function() self:on_tick_always() end)
    client:set_event_callback("on_draw", function() self:on_draw() end)
    client:set_event_callback("on_object_created", function(obj, obj_name) self:on_object_created(obj, obj_name) end)
end

function Syndra:create_menu()
    if not file_manager:directory_exists("Shaun's Sexy Common") then
        file_manager:create_directory("Shaun's Sexy Common")
    end

    if file_manager:directory_exists("Shaun's Sexy Common") then
        if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
            self.Syndra_category = menu:add_category_sprite("Shaun's ProPlay-Syndra", "Shaun's Sexy Common//Logo.png")
        else
            http:download_file_async("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png", function() 
            end)
            self.Syndra_category = menu:add_category("ProPlay-Syndra")
        end
    end

    self.Syndra_enabled = menu:add_checkbox("Enabled", self.Syndra_category, 1)
    menu:add_label("ProPlay-Syndra", self.Syndra_category)

    self.stun_key = menu:add_keybinder("[Stun] Key - Closest To Cursor", self.Syndra_category, string.byte("T"))
    self.r_key = menu:add_keybinder("[R] Key - Closest To Cursor", self.Syndra_category, string.byte("A"))
    self.block_r = menu:add_keybinder("Block [R] KS Usage Key", self.Syndra_category, 0x01)

    self.Syndra_pred = menu:add_subcategory("Prediction", self.Syndra_category)
        menu:add_label("Shaun Prediction", self.Syndra_pred)
        self.q_hitchance = menu:add_slider("[Q] Hit Chance", self.Syndra_pred, 1, 100, 45)
        self.w_hitchance = menu:add_slider("[W] Hit Chance", self.Syndra_pred, 1, 100, 45)


    self.Syndra_combo = menu:add_subcategory("Combo", self.Syndra_category)
        self.combo_q = menu:add_checkbox("Use [Q]", self.Syndra_combo, 1)
        self.combo_w = menu:add_checkbox("Use [W]", self.Syndra_combo, 1)
        self.combo_e = menu:add_checkbox("Use [E]", self.Syndra_combo, 1)
    --

    self.Syndra_harass = menu:add_subcategory("Harass", self.Syndra_category)
        self.harass_mana = menu:add_slider("Mana [%]", self.Syndra_harass, 1, 100, 20)
        self.harass_q = menu:add_checkbox("Use [Q]",  self.Syndra_harass, 1)
        self.harass_w = menu:add_checkbox("Use [W]",  self.Syndra_harass, 0)
        self.harass_e = menu:add_checkbox("Use [E]",  self.Syndra_harass, 0)
    --

    self.Syndra_r = menu:add_subcategory("[R] Kill Steal", self.Syndra_category)
        self.kill_r = menu:add_checkbox("Use [R]",  self.Syndra_r, 1)
    --

    self.Syndra_stun = menu:add_subcategory("Auto Stun Features", self.Syndra_category)
        self.auto_stun = menu:add_checkbox("Use Auto Stun", self.Syndra_stun, 1)
        self.auto_stun_number = menu:add_slider("Auto Stun >= Number Of Targets", self.Syndra_stun, 1, 5, 3)
    --

    self.Syndra_draw = menu:add_subcategory("Draw Features", self.Syndra_category)
        self.q_draw = menu:add_checkbox("Draw [Q] Range",  self.Syndra_draw, 1)
        self.w_draw = menu:add_checkbox("Draw [W] Range",  self.Syndra_draw, 0)
        self.stun_draw = menu:add_checkbox("Draw Max [Stun] Range",  self.Syndra_draw, 1)
        self.grab_draw = menu:add_checkbox("Draw Circles On Grabbable Units", self.Syndra_draw, 1)
        self.ball_line_draw = menu:add_checkbox("Draw Line Between [Ball] & [Syndra]", self.Syndra_draw, 1)
        self.ball_draw = menu:add_checkbox("Draw Circles On Balls", self.Syndra_draw, 1)
    --

    menu:add_label("version "..(tostring(self.version)), self.Syndra_category)
end    

function Syndra:ready(spell)
    return spellbook:can_cast(spell)
end

function Syndra:enemyHeroes()
	local _EnemyHeroes = {}
	for i, unit in ipairs(game.players) do
		if unit and unit.is_valid and unit.is_enemy and unit.is_targetable then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

function Syndra:GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

function Syndra:VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

function Syndra:GetLineTargetCount(source, pos, radius)
    local count = 0
    for _, target in ipairs(self:enemyHeroes()) do
        local range = 1000 * 1000
        if target:distance_to(self.myHero.origin) <= range then
            local pointSegment, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source.origin, pos, target.origin)
            if pointSegment and isOnSegment and (self:GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + radius) * (target.bounding_radius + radius)) then
                count = count + 1
            end
        end
    end
    return count
end

function Syndra:validTarget(object, distance)
    return object and object.is_valid and object.is_enemy and
    not object:has_buff("SionPassiveZombie") and
    not object:has_buff("FioraW") and
    not object:has_buff("sivire") and
    not object:has_buff("MorganaE") and
    not object:has_buff("nocturneshroudofdarkness") and
    object.is_alive and not object:has_buff_type(18) and
    (not distance or object:distance_to(self.myHero.origin) <= distance)
end

function Syndra:qReady()
    local spell = self.myHero:get_spell_slot(SLOT_Q)
    if spell.spell_data.spell_name == "SyndraQUpgrade" then
        return spellbook:can_cast(SLOT_Q) and spell.count ~= 0
    end
    
    return spellbook:can_cast(SLOT_Q)
end

function Syndra:inList(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function Syndra:on_object_created(obj, obj_name)
	if obj.champ_name == "SyndraSphere" then
		if not self:inList(self.ballHolder, obj) then
			table.insert(self.ballHolder, obj)
		end
	end
end

function Syndra:size()
	local count = 0
	for _, ball in pairs(self.ballHolder) do
		count = count + 1
	end
	return count
end

function Syndra:holdingObject()
    return self.myHero:has_buff("syndrawtooltip")
end

function Syndra:mergeAllTables(ballHolder, minions, jungle_minions, pets)
    local mergedTable = {}

    for _, ball in pairs(self.ballHolder) do
        if not ball.path.is_moving then
            table.insert(mergedTable, ball)
        end
    end

    for _, minion in ipairs(minions) do
        if minion.is_valid and minion.is_enemy and minion.is_alive then
            local grabRange = self.W.range + minion.bounding_radius
            if minion:distance_to(self.myHero.origin) <= grabRange then
                table.insert(mergedTable, minion)
            end
        end
    end

    for _, jungle in ipairs(jungle_minions) do
        if jungle.is_valid and jungle.is_alive then
            local grabRange = self.W.range + jungle.bounding_radius
            if jungle:distance_to(self.myHero.origin) <= grabRange then
                table.insert(mergedTable, jungle)
            end
        end
    end

    for _, pet in ipairs(pets) do
        if pet.is_valid and pet.is_alive and pet.champ_name ~= "SyndraOrbs" then
            local grabRange = self.W.range + pet.bounding_radius
            if pet:distance_to(self.myHero.origin) <= grabRange then
                table.insert(mergedTable, pet)
            end
        end
    end

    return mergedTable
end

function Syndra:passiveCount()
    if self.myHero:has_buff("syndrapassivestacks") then
        buff = self.myHero:get_buff("syndrapassivestacks")
        if buff.stacks > 0 then
            return buff.stacks
        end
    end
    return 0
end

function Syndra:RDmg(unit)
    local level = spellbook:get_spell_slot(SLOT_R).level
    local ballCount = self:size() + 3
    -- Adds 3 balls, grabs up to 4
    ballCount = ballCount <= 7 and ballCount or 7

    local base = ({90, 130, 170})[level] + (0.17 * self.myHero.ability_power)
    local dmg = unit:calculate_magic_damage(base * ballCount)

    local stacks = self:passiveCount()
    local healthRemaining = ((unit.health - dmg) / unit.max_health) * 100
    if healthRemaining < 0 then
        return 99999
    end

    if healthRemaining < 15 and stacks >= 100 then
        return 99999
    end

    return dmg
end

function Syndra:comboMotherfuckers()
    local use_q = menu:get_value(self.combo_q) == 1
    local use_w = menu:get_value(self.combo_w) == 1
    local use_e = menu:get_value(self.combo_e) == 1
    local draw_grab = menu:get_value(self.grab_draw) == 1
    local q_hc = menu:get_value(self.q_hitchance) / 100
    local w_hc = menu:get_value(self.w_hitchance) / 100

    local pred 
    if self:qReady() and self:ready(SLOT_E) then
        target = selector:find_target(self.Q_input.range, mode_health)
        pred = self.ShaunPred:calculatePrediction(target, self.Q_input, self.myHero)

    elseif self:qReady() and not self:ready(SLOT_E) then
        target = selector:find_target(self.Q.range, mode_health)
        pred = self.ShaunPred:calculatePrediction(target, self.QOnly_input, self.myHero)

    elseif not self:qReady() and not self:ready(SLOT_E) then
        target = selector:find_target(self.W.range, mode_health)
        pred = self.ShaunPred:calculatePrediction(target, self.W_input, self.myHero)
    end

    if use_q and self:qReady() and (not self:ready(SLOT_E) or not use_e) and target:distance_to(self.myHero.origin) <= self.Q.range then
        if pred and pred.hitChance >= q_hc then
            local p = pred.castPos
            spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
            return
        end
    end

    if use_q and use_e and self:qReady() and self:ready(SLOT_E) and target:distance_to(self.myHero.origin) <= self.Q_input.range then
        if pred and pred.hitChance >= q_hc then
            local p = pred.castPos
            spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
            spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
            return
        end
    end

    if use_w and self:ready(SLOT_W) and not self:holdingObject() then
        local allEntities = self:mergeAllTables(self.ballHolder, game.minions, game.jungle_minions, game.pets)
    
        for _, grabObject in ipairs(allEntities) do
            if grabObject then
                if draw_grab then
                    local d = grabObject.origin
                    renderer:draw_circle(d.x, d.y, d.z, 50, 0, 0, 255, 255)
                end

                if not self:qReady() and not self:ready(SLOT_E) and grabObject:distance_to(self.myHero.origin) <= self.W.range then
                    local p = grabObject.origin
                    spellbook:cast_spell(SLOT_W, 0.5, p.x, p.y, p.z)
                    return
                end
            end
        end
    end

    if use_w and self:holdingObject() and target:distance_to(self.myHero.origin) <= self.W.range and pred and pred.hitChance >= w_hc and not self.ball_moving then
        local p = pred.castPos
        spellbook:cast_spell(SLOT_W, 0.5, p.x, p.y, p.z)
        return
    end  
end

function Syndra:harassGayboys()
    local mana = menu:get_value(self.harass_mana)
    if self.myHero:mana_percentage() < mana then return end

    local use_q = menu:get_value(self.harass_q) == 1
    local use_w = menu:get_value(self.harass_w) == 1
    local use_e = menu:get_value(self.harass_e) == 1
    local draw_grab = menu:get_value(self.grab_draw) == 1
    local q_hc = menu:get_value(self.q_hitchance) / 100
    local w_hc = menu:get_value(self.w_hitchance) / 100

    local pred 
    if self:qReady() and self:ready(SLOT_E) then
        target = selector:find_target(self.Q_input.range, mode_health)
        pred = self.ShaunPred:calculatePrediction(target, self.Q_input, self.myHero)

    elseif self:qReady() and not self:ready(SLOT_E) then
        target = selector:find_target(self.Q.range, mode_health)
        pred = self.ShaunPred:calculatePrediction(target, self.QOnly_input, self.myHero)

    elseif not self:qReady() and not self:ready(SLOT_E) then
        target = selector:find_target(self.W.range, mode_health)
        pred = self.ShaunPred:calculatePrediction(target, self.W_input, self.myHero)
    end

    if use_q and self:qReady() and (not self:ready(SLOT_E) or not use_e) and target:distance_to(self.myHero.origin) <= self.Q.range then
        if pred and pred.hitChance >= q_hc then
            local p = pred.castPos
            spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
            return
        end
    end

    if use_q and use_e and self:qReady() and self:ready(SLOT_E) and target:distance_to(self.myHero.origin) <= self.Q_input.range then
        if pred and pred.hitChance >= q_hc then
            local p = pred.castPos
            spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
            spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
            return
        end
    end

    if use_w and self:ready(SLOT_W) and not self:holdingObject() then
        local allEntities = self:mergeAllTables(self.ballHolder, game.minions, game.jungle_minions, game.pets)
    
        for _, grabObject in ipairs(allEntities) do
            if grabObject then
                if draw_grab then
                    local d = grabObject.origin
                    renderer:draw_circle(d.x, d.y, d.z, 50, 0, 0, 255, 255)
                end

                if not self:qReady() and not self:ready(SLOT_E) and grabObject:distance_to(self.myHero.origin) <= self.W.range then
                    local p = grabObject.origin
                    spellbook:cast_spell(SLOT_W, 0.5, p.x, p.y, p.z)
                    return
                end
            end
        end
    end

    if use_w and self:holdingObject() and target:distance_to(self.myHero.origin) <= self.W.range and pred and pred.hitChance >= w_hc and not self.ball_moving then
        local p = pred.castPos
        spellbook:cast_spell(SLOT_W, 0.5, p.x, p.y, p.z)
        return
    end  
end

function Syndra:bigBalls()
    if menu:get_value(self.kill_r) == 0 then return end 
    if not self:ready(SLOT_R) then return end 
    if game:is_key_down(menu:get_value(self.block_r)) then return end 

    for _, target in ipairs(self:enemyHeroes()) do
        local range = self.R.range + target.bounding_radius
        if self:validTarget(target, range) and self:RDmg(target) >= target.health then
            spellbook:cast_spell_targetted(SLOT_R, target, 0.25)
            return
        end
    end
end

function Syndra:stunMotherfuckers()
    if (not self:ready(SLOT_Q) or not self:ready(SLOT_E)) then return end 
    if not game:is_key_down(menu:get_value(self.stun_key)) then return end 

    local target = selector:find_target(self.Q_input.range, mode_health)
    local pred = self.ShaunPred:calculatePrediction(target, self.Q_input, self.myHero)

    if target and pred and pred.hitChance >= 0.45 then
        local p = pred.castPos
        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
        spellbook:cast_spell(SLOT_E, 0.25, p.x, p.y, p.z)
        return
    end
end

function Syndra:autoStun()
    if menu:get_value(self.auto_stun) == 0 then return end 
    if (not self:ready(SLOT_Q) or not self:ready(SLOT_E)) then return end 
    local countReq = menu:get_value(self.auto_stun_number)

    for _, e_target in ipairs(self:enemyHeroes()) do
        local pred = self.ShaunPred:calculatePrediction(e_target, self.Q_input, self.myHero)
        if pred then
            local pos = pred.castPos
            local count = self:GetLineTargetCount(self.myHero, e_target.origin, 55)
            if count and count >= countReq then
                spellbook:cast_spell(SLOT_Q, 0.25, pos.x, pos.y, pos.z)
                spellbook:cast_spell(SLOT_E, 0.25, pos.x, pos.y, pos.z)
                return
            end
        end
    end
end
    

function Syndra:on_tick_always()
    if menu:get_value(self.Syndra_enabled) == 0 then return end 

    if combo:get_mode() == 1 then
        self:comboMotherfuckers()
    elseif combo:get_mode() == 2 then
        self:harassGayboys()
    end

    self:bigBalls()
    self:stunMotherfuckers()
    self:autoStun()

    for index, ball in pairs(self.ballHolder) do
		if not ball.is_alive then
			table.remove(self.ballHolder, index)
		end
	end
end

function Syndra:on_draw()
    local draw_ball = menu:get_value(self.ball_draw) == 1
    local draw_line_ball = menu:get_value(self.ball_line_draw) == 1

    local draw_q = menu:get_value(self.q_draw) == 1
    local draw_w = menu:get_value(self.w_draw) == 1
    local draw_stun = menu:get_value(self.stun_draw) == 1

    local heroPos = self.myHero.origin
    for _, ball in pairs(self.ballHolder) do
        if ball and ball.champ_name == "SyndraSphere" then

            if ball.path.is_moving then
                self.ball_moving = true
            else
                self.ball_moving = false
            end

            local ballPos = ball.origin
            if draw_ball then
                renderer:draw_circle(ballPos.x, ballPos.y, ballPos.z, 50, 255, 255, 255, 255)
            end

            if draw_line_ball then
                local heroWorld = game:world_to_screen_2(heroPos.x, heroPos.y, heroPos.z)
                local ballWorld = game:world_to_screen_2(ballPos.x, ballPos.y, ballPos.z) 
                renderer:draw_line(heroWorld.x, heroWorld.y, ballWorld.x, ballWorld.y, 1.5, 255, 255, 255, 255)
            end
        end
    end

    if draw_q and self:ready(SLOT_Q) then
        renderer:draw_circle(heroPos.x, heroPos.y, heroPos.z, self.Q.range, 255, 255, 0, 255)
    end

    if draw_w and self:ready(SLOT_W) then
        renderer:draw_circle(heroPos.x, heroPos.y, heroPos.z, self.W_input.range, 0, 255, 255, 255)
    end

    if draw_stun and self:ready(SLOT_E) then
        renderer:draw_circle(heroPos.x, heroPos.y, heroPos.z, self.Q_input.range, 0, 255, 0, 255)
    end

    if self:ready(SLOT_R) then
        for _, target in ipairs(self:enemyHeroes()) do
            local range = 2000
            local dmg = self:RDmg(target)
            if dmg and target:distance_to(self.myHero.origin) <= range then
                target:draw_damage_health_bar(dmg)
            end
        end
    end
end

local SyndraScript = Syndra:new()
