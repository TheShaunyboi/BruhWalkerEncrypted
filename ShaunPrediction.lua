local ShaunPrediction = {}
local menu_hitchance
local menu_target
local menu_output
local myHero = game.local_player

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:new()
    local o = {}
    setmetatable(o, self)
    client:set_event_callback("on_tick_always", function() self:on_tick_always() end)
    client:set_event_callback("on_draw", function() self:on_draw() end)
    return o
end

--Returns distance between two points
function ShaunPrediction:GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return math.sqrt(dx*dx + dz*dz)
end

function ShaunPrediction:GetDistance(vec1, vec2)
    local x1, y1, z1 = vec1.x, vec1.y, vec1.z
    local x2, y2, z2 = vec2.x, vec2.y, vec2.z
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

--Subtract two vectors
function ShaunPrediction:Sub(vec1, vec2)
    local new_x = vec1.x - vec2.x
    local new_y = vec1.y - vec2.y
    local new_z = vec1.z - vec2.z
    local sub = vec3.new(new_x, new_y, new_z)
    return sub
end

--Vector Magnitude
function ShaunPrediction:Magnitude(vec)
    local mag = math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
    return mag
end

--Add two vectors
function ShaunPrediction:Add(vec1, vec2)
    local new_x = vec1.x + vec2.x
    local new_y = vec1.y + vec2.y
    local new_z = vec1.z + vec2.z
    local add = vec3.new(new_x, new_y, new_z)
    return add
end

--Normalize a vector
function ShaunPrediction:Normalize(vec)
    local x, y, z = vec.x, vec.y, vec.z
    local mag = math.sqrt(x^2 + y^2 + z^2)
    if mag == 0 then
        return {x = 0, y = 0, z = 0}
    else
        return {x = x / mag, y = y / mag, z = z / mag}
    end
end

--Multiply a vector (table) by a scalar
function ShaunPrediction:Mul(vec, scalar)
    local new_x = vec.x * scalar
    local new_y = vec.y * scalar
    local new_z = vec.z * scalar
    local mul = {x = new_x, y = new_y, z = new_z}
    return mul
end

-- Calculate the angle between vectors
function ShaunPrediction:AngleBetweenVectors(vec1, vec2)
    local dotProduct = vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
    local mag1 = self:Magnitude(vec1)
    local mag2 = self:Magnitude(vec2)
    local angle = math.acos(dotProduct / (mag1 * mag2))
    return angle
end

--Calculate the squared magnitude of a vector
function ShaunPrediction:MagnitudeSquared(vec)
    return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z
end

--Calculate the dot product of two vectors
function ShaunPrediction:DotProduct(vec1, vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

function ShaunPrediction:GetEnemyHeroes(myHeroPos, range, target)
    local enemyHeroes = {}
    heroes = game.players
    for _, unit in ipairs(heroes) do
        if unit and unit.is_enemy and unit.is_alive and unit.object_id ~= target.object_id and self:GetDistanceSqr2(myHeroPos, unit.origin) <= range then
            table.insert(enemyHeroes, unit)
        end
    end
    return enemyHeroes
end


function ShaunPrediction:GetEnemyMinions(myHeroPos, range)
    local enemyMinions = {}
    minion = game.minions
    for _, unit in ipairs(minion) do
        if unit and unit.is_enemy and unit.is_alive and self:GetDistanceSqr2(myHeroPos, unit.origin) <= range then
            table.insert(enemyMinions, unit)
        end
    end
    return enemyMinions
end

-- Cross product of two vectors
function ShaunPrediction:Cross(vec1, vec2)
    local x = vec1.y * vec2.z - vec1.z * vec2.y
    local y = vec1.z * vec2.x - vec1.x * vec2.z
    local z = vec1.x * vec2.y - vec1.y * vec2.x
    return vec3.new(x, y, z)
end

-- Distance from a point to a line segment
function ShaunPrediction:DistanceToLine(point, lineStart, lineEnd)
    local lineDirection = self:Sub(lineEnd, lineStart)
    local pointDirection = self:Sub(point, lineStart)
    local projection = self:DotProduct(pointDirection, lineDirection) / self:MagnitudeSquared(lineDirection)
    local clampedProjection = math.max(0, math.min(projection, 1))
    local nearestPoint = self:Add(lineStart, self:Mul(lineDirection, clampedProjection))
    return self:GetDistance(point, nearestPoint)
end

-- Rotate a 2D vector by an angle (in radians)
function ShaunPrediction:RotateVector2D(vec, angle)
    local cosTheta = math.cos(angle)
    local sinTheta = math.sin(angle)
    local x = vec.x * cosTheta - vec.y * sinTheta
    local y = vec.x * sinTheta + vec.y * cosTheta
    return vec2.new(x, y)
end

function ShaunPrediction:IsPointInCone(position, predictedPosition, angle, range, position2)
    local direction = self:Normalize(self:Sub(predictedPosition, position))
    local perpendicular = vec3.new(-direction.z, 0, direction.x)
    local half_angle = math.rad(angle / 2)
    local axis = self:Mul(self:Normalize(self:Cross(direction, perpendicular)), range)
    local point1 = self:Add(predictedPosition, self:RotateVector2D(self:Mul(perpendicular, range), axis, half_angle))
    local point2 = self:Add(predictedPosition, self:RotateVector2D(self:Mul(perpendicular, range), axis, -half_angle))

    local distanceToLine = self:DistanceToLine(point1, point2, position2)
    if distanceToLine <= input.radius then
        local distanceToCone = self:GetDistanceSqr2(predictedPosition, position2)
        if distanceToCone <= range * range then
            local angleBetweenVectors = self:AngleBetweenVectors(direction, self:Sub(position2, predictedPosition))
            if angleBetweenVectors <= half_angle then
                return true
            end
        end
    end
    return false
end

function ShaunPrediction:IsPointOnLineSegment(p1, p2, p3, radius)
    local lineVec = self:Sub(p1, p2)
    local pointVec = self:Sub(p3, p2)
    local dotProduct = self:DotProduct(pointVec, lineVec) / self:MagnitudeSquared(lineVec)
    if dotProduct < 0 or dotProduct > 1 then
        return false
    end
    local projVec = self:Mul(lineVec, dotProduct)
    local distVec = self:Sub(pointVec, projVec)
    local distanceSqr = self:MagnitudeSquared(distVec)
    if distanceSqr > radius * radius then
        return false
    end
    return true
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:invulBuff(obj)
    if not obj then return end

    if obj:has_buff("ChronoRevive") then
        local buff = obj:get_buff("ChronoRevive")
        if buff.is_valid then
            local end_time = buff.end_time
            local time_left = end_time - game.game_time
            return time_left
        end
    end

    if obj.is_alive then
        if obj:has_buff("UndyingRage") then
            local buff = obj:get_buff("UndyingRage")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end
    
        elseif obj:has_buff("KayleR") then
            local buff = obj:get_buff("KayleR")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end

        elseif obj:has_buff("LissandraRSelf") then
            local buff = obj:get_buff("LissandraRSelf")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end
    
        elseif obj:has_buff("KindredRNoDeathBuff") then
            local buff = obj:get_buff("KindredRNoDeathBuff")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end
    
        elseif obj:has_buff("FioraW") then
            local buff = obj:get_buff("FioraW")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end
    
        elseif obj:has_buff("VladimirSanguinePool") then
            local buff = obj:get_buff("VladimirSanguinePool")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end
    
        elseif obj:has_buff("TaricR") then
            local buff = obj:get_buff("TaricR")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end

        elseif obj:has_buff("ZhonyasRingShield") then
            local buff = obj:get_buff("ZhonyasRingShield")
            if buff.is_valid then
                local end_time = buff.end_time
                local time_left = end_time - game.game_time
                return time_left
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:GetBestAOE(input, units, star)
    if not input or not units or #units == 0 then
        return nil
    end
    
    local bestPosition = nil
    local highestHitCount = 0
    
    for i, unit in ipairs(units) do
        local position = vec3.new(unit.origin.x, unit.origin.y, unit.origin.z)
        local hitCount = 0

        if star then
            local distanceToStar = self:GetDistanceSqr2(position, vec3.new(star.origin.x, star.origin.y, star.origin.z))
            if distanceToStar <= input.range * input.range then
                hitCount = hitCount + 1
            end
        end

        if input.type == "linear" then
            local predictedPosition = self:calculatePredictedPosition(unit, input, star or unit)
            for j, unit2 in ipairs(units) do
                local position2 = vec3.new(unit2.origin.x, unit2.origin.y, unit2.origin.z)
                if self:IsPointOnLineSegment(position, predictedPosition, position2, input.radius) then
                    hitCount = hitCount + 1
                end
            end

        elseif input.type == "circular" then
            for j, unit2 in ipairs(units) do
                local position2 = vec3.new(unit2.origin.x, unit2.origin.y, unit2.origin.z)
                local distanceToUnit = self:GetDistanceSqr2(position, position2)
                if distanceToUnit <= input.radius * input.radius then
                    hitCount = hitCount + 1
                end
            end

        elseif input.type == "cone" then
            local predictedPosition = self:calculatePredictedPosition(unit, input, star or unit)
            for j, unit2 in ipairs(units) do
                local position2 = vec3.new(unit2.origin.x, unit2.origin.y, unit2.origin.z)
                if self:IsPointInCone(position, predictedPosition, input.angle, input.range, position2) then
                    hitCount = hitCount + 1
                end
            end
        end
 
        if hitCount > highestHitCount then
            bestPosition = position
            highestHitCount = hitCount
        end
    end

    return {position = bestPosition, 
        hit_count = highestHitCount
    }
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:calculateInterpolationPredictedPosition(target, ability, source)
    local targetPos = vec3.new(target.origin.x, target.origin.y, target.origin.z)
    local myHeroPos = vec3.new(source.origin.x, source.origin.y, source.origin.z)
    local distanceToTarget = self:GetDistanceSqr2(targetPos, myHeroPos)

    if distanceToTarget > ability.range then
        return nil
    end

    local targetPath = target.path
    local abilityTravelTime = ability.range / ability.speed + ability.delay

    -- Calculate predicted position based on target's waypoints
    local predictedPosition = targetPos

    local usePing = menu:get_value(menu_latency) == 1
    local delay
    if usePing then 
        delay = 0.0167 + game.latency
    else
        delay = 0.0167
    end

    local remainingTravelTime = abilityTravelTime + delay

    local targetInvul = self:invulBuff(target) 
    if targetInvul and remainingTravelTime <= targetInvul then
        predictedPosition = targetPos
    end

    if not targetPath.is_dashing and not targetPath.is_moving then
        -- Target is stationary, use the actual position as the predicted position
        predictedPosition = targetPos
    else
        for i = 1, #targetPath.waypoints - 1 do
            local currentWaypoint = vec3.new(targetPath.waypoints[i].x, targetPath.waypoints[i].y, targetPath.waypoints[i].z)
            local nextWaypoint = vec3.new(targetPath.waypoints[i + 1].x, targetPath.waypoints[i + 1].y, targetPath.waypoints[i + 1].z)
            local waypointDistance = self:GetDistanceSqr2(currentWaypoint, nextWaypoint)

            local timeToReachNextWaypoint
            if targetPath.is_dashing then
                timeToReachNextWaypoint = waypointDistance / targetPath.dash_speed
            else
                timeToReachNextWaypoint = waypointDistance / target.move_speed
            end

            if remainingTravelTime > timeToReachNextWaypoint then
                remainingTravelTime = remainingTravelTime - timeToReachNextWaypoint
                predictedPosition = nextWaypoint
            else
                if nextWaypoint and currentWaypoint then
                    local directionToNextWaypoint = self:Sub(nextWaypoint, currentWaypoint)
                    local moveSpeed = target.move_speed
                    local directionToNextWaypointNormalized = self:Normalize(directionToNextWaypoint)

                    -- Interpolate/extrapolate based on velocity
                    local velocity = targetPath.velocity
                    local timeRemaining = remainingTravelTime
                    local predictedDirection = self:Mul(directionToNextWaypointNormalized, moveSpeed)

                    -- Interpolation: Estimate position between waypoints based on velocity
                    if velocity and timeRemaining > 0 then
                        local predictedPositionDelta = self:Mul(velocity, timeRemaining)
                        predictedPosition = self:Add(predictedPosition, predictedPositionDelta)
                    end

                    -- Extrapolation: Predict future position beyond last known waypoint
                    if timeRemaining > 0 then
                        local predictedPositionDelta = self:Mul(predictedDirection, timeRemaining)
                        predictedPosition = self:Add(predictedPosition, predictedPositionDelta)
                    end
                    break
                end
            end
        end

        -- If the target has clicked far away but is still in spell range..
        -- calculate the predicted position based on the target's movement direction and remaining travel time
        if distanceToTarget <= ability.range and targetPath.waypoints[1] and targetPath.waypoints[2] then
            local currentWaypoint = vec3.new(targetPath.waypoints[1].x, targetPath.waypoints[1].y, targetPath.waypoints[1].z)
            local nextWaypoint = vec3.new(targetPath.waypoints[2].x, targetPath.waypoints[2].y, targetPath.waypoints[2].z)
            local directionToNextWaypoint = self:Sub(nextWaypoint, currentWaypoint)
            local moveSpeed = target.move_speed
            local directionToNextWaypointNormalized = self:Normalize(directionToNextWaypoint)
            local distanceToMove = self:Mul(directionToNextWaypointNormalized, remainingTravelTime * moveSpeed)
            predictedPosition = self:Add(targetPos, distanceToMove)
        end
    end

    menu_target = targetPos
    return predictedPosition
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:calculateHitChance(target, ability, source, predictedPosition)
    local targetPos = vec3.new(target.origin.x, target.origin.y, target.origin.z)
    local myHeroPos = vec3.new(source.origin.x, source.origin.y, source.origin.y)
    
    -- Calculate hit chance
    local distanceToTarget = source:distance_to(targetPos)
    local timeToHit = distanceToTarget / ability.speed
    local baseHitChance = math.max(0, 1 - timeToHit)

    -- Adjust for movement speed
    local targetMovementSpeed = target.move_speed
    local speedFactor = math.max(1 - targetMovementSpeed / 900, 0.5) -- decrease hit chance based on target's movement speed
    baseHitChance = baseHitChance * speedFactor

    -- Adjust for CC
    local isCCed = target:get_immobile_duration(false)
    if isCCed then
        local ccBonus = 0.1 -- increase hit chance if target is CCed
        baseHitChance = baseHitChance + ccBonus
    end

    -- Adjust hit chance based on whether the target is auto-attacking
    if target.is_auto_attacking then
        local autoAttackBonus = 0.1 -- adjust value as needed
        baseHitChance = baseHitChance + autoAttackBonus
    end
    

    if next(ability.collision) ~= nil then
        local collisionPredPos = _G.Prediction:get_collision(ability, predictedPosition, target)
        local collisionEnemy = _G.Prediction:get_collision(ability, targetPos, target)
        if next(collisionPredPos) ~= nil or next(collisionEnemy) ~= nil then
            return nil
        end

        local cTable = {}
        if ability.type == "linear" then
            cTable = {
                type = "linear",
                delay = ability.delay,
                speed = ability.speed,
                range = ability.range,
                width = ability.radius * 2,
                collision = {
                    ["Wall"] = true,
                    ["Hero"] = false,
                    ["Minion"] = true
                },
            }
        elseif ability.type == "circular" then
            cTable = {
                type = "circular",
                delay = ability.delay,
                speed = ability.speed,
                range = ability.range,
                radius = ability.radius,
                collision = {
                    ["Wall"] = true,
                    ["Hero"] = false,
                    ["Minion"] = true
                },
            }
        elseif ability.type == "cone" then
            cTable = {
                type = "cone",
                delay = ability.delay,
                speed = ability.speed,
                range = ability.range,
                angle = ability.angle,
                collision = {
                    ["Wall"] = true,
                    ["Hero"] = false,
                    ["Minion"] = true
                },
            }
        end

        local colPred = _G.DreamPred.GetPrediction(target, cTable, myHero)
        if not colPred or colPred.hitChance < 0.25 then
            return nil
        end
    end

    -- Adjust hit chance based on collision and bounding radius
    local totalRadius
    if ability.type == "circular" or ability.type == "linear" then
        totalRadius = target.bounding_radius + ability.radius

    elseif ability.type == "cone" then
        totalRadius = target.bounding_radius + math.tan(math.rad(ability.angle / 2)) * distanceToTarget
    end

    -- Decrease hit chance if target is near enemy minions
    local enemyMinions = self:GetEnemyMinions(targetPos, ability.range)
    for _, minion in ipairs(enemyMinions) do
        if minion then
            local distanceToMinion = minion:distance_to(predictedPosition)
            if distanceToMinion < totalRadius then
                baseHitChance = baseHitChance * 0.5
                break
            end
        end
    end


    local distanceDifference = math.abs(self:GetDistanceSqr2(myHeroPos, predictedPosition) - self:GetDistanceSqr2(myHeroPos, targetPos))
    if distanceDifference <= totalRadius * totalRadius then
        baseHitChance = baseHitChance * 1.1
    end

    return baseHitChance
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:calculatePrediction(target, ability, source)
    local useVirtual = menu:get_value(menu_virtualize) == 1
    
    local predictedPosition
    if not useVirtual then 
        predictedPosition = self:calculateInterpolationPredictedPosition(target, ability, source)
    end

    if not predictedPosition then
        return nil
    end
    menu_output = predictedPosition

    local hitChance
    if not useVirtual then 
        hitChance = self:calculateHitChance(target, ability, source, predictedPosition)
    end

    if hitChance == nil then
        return nil
    end
    menu_hitchance = hitChance

    return {
        castPos = predictedPosition,
        hitChance = hitChance,
    }
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:on_tick_always()
    local useVirtual = menu:get_value(menu_virtualize) == 1
    if useVirtual then
        local virtual_text = game:world_to_screen(myHero.origin.x, myHero.origin.y, myHero.origin.z)
        renderer:draw_text_centered(virtual_text.x, virtual_text.y + 80, "Virtual Prediction Enabled!")

        local predictedPosition
        local hitChance
        local vRange = menu:get_value(menu_range)
        local vSpeed = menu:get_value(menu_speed)
        local vRadius = menu:get_value(menu_radius)

        for _, enemy in ipairs(game.players) do
            if enemy.is_enemy and enemy.is_alive and enemy:distance_to(myHero.origin) <= vRange then

                local vTable = {
                    source = myHero, 
                    speed = math.huge, 
                    range = vRange, 
                    delay = enemy:distance_to(myHero.origin) / vSpeed, 
                    radius = vRadius, 
                    collision = {}, 
                    type = "linear", 
                    hitbox = true
                }

                predictedPosition = self:calculateInterpolationPredictedPosition(enemy, vTable, myHero)

                if predictedPosition then
                    menu_target = enemy.origin
                    menu_output = predictedPosition
                    hitChance = self:calculateHitChance(enemy, vTable, myHero, predictedPosition)
                    if hitChance then
                        menu_hitchance = hitChance
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:onDash(target, ability, source)
    local targetPos = vec3.new(target.origin.x, target.origin.y, target.origin.z)
    local myHeroPos = vec3.new(source.origin.x, source.origin.y, source.origin.z)
    
    local distanceToTarget = self:GetDistanceSqr2(targetPos, myHeroPos)
    if distanceToTarget > ability.range then
        return nil
    end

    local targetPath = target.path
    if not targetPath.is_dashing then
        return nil
    end

    local dashSpeed = targetPath.dash_speed
    local dashPos = vec3.new(targetPath.dash_pos.x, targetPath.dash_pos.y, targetPath.dash_pos.z)

    if next(ability.collision) ~= nil then
        local collisionPredPos = _G.Prediction:get_collision(ability, dashPos, target)
        local collisionEnemy = _G.Prediction:get_collision(ability, targetPos, target)
        if next(collisionPredPos) ~= nil or next(collisionEnemy) ~= nil then
            return nil
        end
    end
    
    local travelTime = self:GetDistanceSqr2(myHeroPos, dashPos) / ability.speed
    local timeToDash = self:GetDistanceSqr2(targetPos, dashPos) / dashSpeed
    local remainingTime = timeToDash - travelTime

    remainingTime = remainingTime - ability.delay
    remainingTime = remainingTime - 0.0167

    local castThreshold = 0.2
    if remainingTime >= 0 and remainingTime <= castThreshold then

        return {
            castPos = dashPos,
            remainingTime = remainingTime
        }
    end
    return nil
end

--------------------------------------------------------------------------------------------------------------------------------

function ShaunPrediction:on_draw()
    local useVirtual = menu:get_value(menu_virtualize) == 1

    if (menu:get_value(draw_hitchance) == 1 or useVirtual) and menu_target and menu_hitchance then
        local text = game:world_to_screen(menu_target.x, menu_target.y, menu_target.z)
        renderer:draw_text_centered(text.x, text.y + 50, tostring(menu_hitchance))
        menu_hitchance = nil
    end

    if (menu:get_value(draw_output) == 1 or useVirtual) and menu_output then
        renderer:draw_circle(menu_output.x, menu_output.y, menu_output.z, 30, 255, 255, 255, 255)
        menu_output = nil
    end
end

--------------------------------------------------------------------------------------------------------------------------------

local menu_version = 0.20
if not _G.ShaunPredictionInitialized then
    do
        local function Update()
            local version = menu_version
            local file_name = "ShaunPrediction.lua"
            local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua"
            
            http:get_async("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua.version.txt", function(success, web_version)
				if tonumber(web_version) == version then
                    console:log("Shaun Prediction Successfully Loaded")
				else
					http:download_file_async(url, file_name, function(success)
						if success then
                            console:log("Shaun Prediction Updated Press F5")
						end
					end)
				end
			end)
        end
        Update()
    end
end

if not _G.ShaunPredictionInitialized then
    _G.ShaunPredictionInitialized = true

    if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
        pred_category = menu:add_category_sprite("Shaun Prediction", "Shaun's Sexy Common//Logo.png")
    else
        http:download_file_async("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png", function() end)
        pred_category = menu:add_category("Shaun Prediction")
    end
    --
    ping = menu:add_subcategory("Latency", pred_category)
        menu_latency = menu:add_checkbox("Always Account For Latency", ping, 1)
    --
    virtualize_prediction = menu:add_subcategory("Virtualize Prediction", pred_category)
        menu_virtualize = menu:add_checkbox("Enable Virtualize Prediction", virtualize_prediction, 0)
        menu:add_label("Virtualize On Targets Within Range", virtualize_prediction)
        menu_speed = menu:add_slider("Speed Input", virtualize_prediction, 0, 6000, 2000)
        menu_range = menu:add_slider("Range Input", virtualize_prediction, 0, 4000, 2000)
        menu_radius = menu:add_slider("Radius Input", virtualize_prediction, 0, 1000, 60)
    --
    draw_debug = menu:add_subcategory("Prediction Output Draws", pred_category)
        draw_hitchance = menu:add_checkbox("Draw Hit Chance On Target", draw_debug, 1)
        draw_output = menu:add_checkbox("Draw Calculated Vec3 Output", draw_debug, 1)
    --
    menu:add_label("Version "..tostring(menu_version), pred_category)
end

require "Prediction"
require "DreamPred"
ShaunPrediction:new()
return ShaunPrediction
