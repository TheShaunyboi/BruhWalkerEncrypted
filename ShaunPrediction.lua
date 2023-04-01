local ShaunPrediction = {}
function ShaunPrediction:new(target, ability, myHero)
    local o = {}
    setmetatable(o, self)
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

--Normalize a vec3
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

-- Calculate the angle between the caster, the target's current position, and the predicted position
function ShaunPrediction:AngleBetweenVectors(vec1, vec2)
    local dotProduct = vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
    local mag1 = self:Magnitude(vec1)
    local mag2 = self:Magnitude(vec2)
    local angle = math.acos(dotProduct / (mag1 * mag2))
    return angle
end

function ShaunPrediction:calculateLinearPrediction(target, ability, myHero)
    local targetPos = vec3.new(target.origin.x, target.origin.y, target.origin.z)
    local myHeroPos = vec3.new(myHero.origin.x, myHero.origin.y, myHero.origin.z)
    local distanceToTarget = self:GetDistanceSqr2(targetPos, myHeroPos)

    if distanceToTarget > ability.range then
        return nil  -- Return nil if the target is not within range
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

    -- Draw predictedPosition vec3
    renderer:draw_circle(predictedPosition.x, predictedPosition.y, predictedPosition.z, 30, 255, 255, 255, 255)

    -- Calculate hit chance based on distance and target's pathing
    local directionToPredictedPosition = self:Sub(predictedPosition, myHeroPos)
    local directionToActualPosition = self:Sub(targetPos, myHeroPos)

    local angleBetweenPositions = self:AngleBetweenVectors(directionToPredictedPosition, directionToActualPosition)
    local angularHitChance = 1 - math.min(angleBetweenPositions / math.pi, 1)

    local hitChance
    if targetPath.is_dashing or targetPath.is_moving then
        hitChance = 0.5 * angularHitChance
    else
        -- Use a different calculation for stationary targets (e.g., a higher base hit chance)
        hitChance = 0.9 - 0.4 * math.min(self:GetDistanceSqr2(myHeroPos, predictedPosition) / ability.range, 1)
    end

    -- Adjust hit chance based on target's bounding radius and ability width
    local distanceDifference = math.abs(self:GetDistanceSqr2(myHeroPos, predictedPosition) - self:GetDistanceSqr2(myHeroPos, targetPos))
    local totalRadius = target.bounding_radius + ability.width / 2
    if distanceDifference <= totalRadius then
        hitChance = hitChance * 1.25
    end

    return {
        castPos = predictedPosition,
        hitChance = hitChance,
    }
end

return ShaunPrediction
