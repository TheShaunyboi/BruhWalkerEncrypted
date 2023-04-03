local pred_loaded = package.loaded["ShaunPrediction"]
if not pred_loaded then return end

MenuInitialized = MenuInitialized or false
local ShaunPrediction = {}
local menu_version = 0.2
local menu_hitchance
local menu_target
local menu_output

function ShaunPrediction:new(target, ability, source)
    local o = {}
    setmetatable(o, self)
    self.reactionAdjustment = nil
    self.__index = self
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

function ShaunPrediction:GetEnemyHeroes(myHeroPos, range, target)
    local enemyHeroes = {}
    players = game.players
    for _, unit in ipairs(players) do
        if unit and unit.is_enemy and unit ~= target and unit.is_alive and self:GetDistanceSqr2(myHeroPos, unit.origin) <= range then
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

function ShaunPrediction:checkCollision(myHeroPos, predictedPosition, ability, target)
    local collision = ability.collision
    local abilityType = ability.type

    if collision then
        if abilityType == "linear" then
            local targetDirection = self:Normalize(self:Sub(predictedPosition, myHeroPos))
            local stepSize = 25
            local steps = math.floor(ability.range / stepSize)

            for i = 1, steps do
                local currentPosition = self:Add(myHeroPos, self:Mul(targetDirection, i * stepSize))

                if collision["Hero"] then
                    local enemyHeroes = self:GetEnemyHeroes(myHeroPos, stepSize, target)
                    for _, enemyHero in ipairs(enemyHeroes) do
                        if enemyHero and self:GetDistanceSqr2(currentPosition, enemyHero.origin) <= enemyHero.bounding_radius + ability.width / 2 then
                            return true
                        end
                    end
                end

                if collision["Minion"] then
                    local enemyMinions = self:GetEnemyMinions(myHeroPos, stepSize)
                    for _, enemyMinion in ipairs(enemyMinions) do
                        if enemyMinion and self:GetDistanceSqr2(currentPosition, enemyMinion.origin) <= enemyMinion.bounding_radius + ability.width / 2 then
                            return true
                        end
                    end
                end
            end
        elseif abilityType == "cone" then
            local angle = math.rad(ability.angle)
            local coneDirection = self:Normalize(self:Sub(predictedPosition, myHeroPos))
            local coneStart = self:Add(myHeroPos, self:Mul(coneDirection, ability.radius))

            local checkUnits = function(units)
                for _, unit in ipairs(units) do
                    local unitPos = unit.origin
                    local directionToUnit = self:Normalize(self:Sub(unitPos, coneStart))
                    local angleBetweenDirections = self:AngleBetweenVectors(coneDirection, directionToUnit)

                    if angleBetweenDirections <= angle / 2 then
                        local distanceToUnit = self:GetDistanceSqr2(coneStart, unitPos)

                        if distanceToUnit <= ability.range * ability.range then
                            return true
                        end
                    end
                end
                return false
            end

            if collision["Hero"] then
                local enemyHeroes = self:GetEnemyHeroes(myHeroPos, ability.range)
                if checkUnits(enemyHeroes) then
                    return true
                end
            end

            if collision["Minion"] then
                local enemyMinions = self:GetEnemyMinions(myHeroPos, ability.range)
                if checkUnits(enemyMinions) then
                    return true
                end
            end
        end
    end
    return false
end

function ShaunPrediction:calculatePrediction(target, ability, source)
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
    local remainingTravelTime = abilityTravelTime

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
                    local moveSpeed = targetPath.is_dashing and targetPath.dash_speed or target.move_speed
                    local directionToNextWaypointNormalized = self:Normalize(directionToNextWaypoint)
                    predictedPosition = self:Add(currentWaypoint, self:Mul(directionToNextWaypointNormalized, remainingTravelTime * moveSpeed))
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
            local moveSpeed = targetPath.is_dashing and targetPath.dash_speed or target.move_speed
            local directionToNextWaypointNormalized = self:Normalize(directionToNextWaypoint)
            local distanceToMove = self:Mul(directionToNextWaypointNormalized, remainingTravelTime * moveSpeed)
            predictedPosition = self:Add(targetPos, distanceToMove)
        end
    end

    -- Calculate hit chance
    local directionToPredictedPosition = self:Sub(predictedPosition, myHeroPos)
    local directionToActualPosition = self:Sub(targetPos, myHeroPos)

    local angleBetweenPositions = self:AngleBetweenVectors(directionToPredictedPosition, directionToActualPosition)
    local angularHitChance = 1 - math.min(angleBetweenPositions / math.pi, 1)

    local hitChance
    if targetPath.is_dashing or targetPath.is_moving then
        hitChance = 0.5 * angularHitChance
    else
        -- Use a different calculation for stationary targets (e.g a higher base hit chance)
        hitChance = 0.9 - 0.4 * math.min(self:GetDistanceSqr2(myHeroPos, predictedPosition) / ability.range, 1)
    end

    -- Add a reaction time to hitChance calculation
    self.reactionAdjustment = menu:get_value(menu_reactionTime) / 100
    if self.reactionAdjustment > 0 then
        local distanceCoveredByReactionTime = target.move_speed * self.reactionAdjustment
        hitChance = hitChance * (1 - math.min(distanceCoveredByReactionTime / ability.range, 1))
    end

    -- Adjust hit chance based on target's bounding radius, ability's width, radius, or angle
    local distanceDifference = math.abs(self:GetDistanceSqr2(myHeroPos, predictedPosition) - self:GetDistanceSqr2(myHeroPos, targetPos))
    local totalRadius
    if ability.type == "linear" then
        if self:checkCollision(myHeroPos, predictedPosition, ability, target) then
            return nil
        end
        totalRadius = target.bounding_radius + ability.width / 2

    elseif ability.type == "circular" then
        totalRadius = target.bounding_radius + ability.radius

    elseif ability.type == "cone" then
        if self:checkCollision(myHeroPos, predictedPosition, ability, target) then
            return nil
        end
        totalRadius = target.bounding_radius + math.tan(math.rad(ability.angle / 2)) * distanceToTarget
    end
    if distanceDifference <= totalRadius then
        hitChance = hitChance * 1.25
    end

    menu_hitchance = hitChance
    menu_target = targetPos
    menu_output = predictedPosition

    return {
        castPos = predictedPosition,
        hitChance = hitChance,
    }
end

if not MenuInitialized then
    do
        local function Update()
            local version = 0.2
            local file_name = "ShaunPrediction.lua"
            local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua"
            local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua.version.txt")
            if tonumber(web_version) == version then
                console:log("Shaun Prediction Successfully Loaded")
            else
                http:download_file(url, file_name)
                console:log("Shaun Prediction Updated Press F5")
            end
        end
        Update()
    end
end

if not MenuInitialized then
    MenuInitialized = true

    if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
        pred_category = menu:add_category_sprite("Shaun Prediction", "Shaun's Sexy Common//Logo.png")
    else
        http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
        pred_category = menu:add_category("Shaun Prediction")
    end

    menu:add_label("Increasing Reaction Time Will Lower Overall Hitchance", pred_category)
    menu_reactionTime = menu:add_slider("Reaction Time Adjustment / 100", pred_category, 0, 500, 0)
    draw_debug = menu:add_subcategory("Debug Draws", pred_category)
    draw_hitchance = menu:add_checkbox("Draw Hit Chance On Target", draw_debug, 1)
    draw_output = menu:add_checkbox("Draw Calculated Vec3 Output", draw_debug, 1)
    menu:add_label("Version "..tostring(menu_version), pred_category)
end

function on_draw()
    if menu:get_value(draw_hitchance) == 1 and menu_target and menu_hitchance then
        local text = game:world_to_screen(menu_target.x, menu_target.y, menu_target.z)
        renderer:draw_text_centered(text.x, text.y + 50, tostring(menu_hitchance))
    end

    if menu:get_value(draw_output) == 1 and menu_output then
        renderer:draw_circle(menu_output.x, menu_output.y, menu_output.z, 30, 255, 255, 255, 255)
    end
end

client:set_event_callback("on_draw", on_draw)
return ShaunPrediction
