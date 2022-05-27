if game.local_player.champ_name ~= "Kalista" then
	return
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
end

require "PKDamageLib"
myHero = game.local_player
Rrange = 1100
Oathsworn = nil

function Ready(spell)
  return spellbook:can_cast(spell)
end

function GetDistanceSqr(unit, p2)
	p2 = p2.origin or myHero.origin
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.origin
	p1x, p1y, p1z = p1.x, p1.y, p1.z
	local dx = p1x - p2x
	local dz = (p1z or p1y) - (p2z or p2y)
	return dx*dx + dz*dz
end

function GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

local function IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

function GetAllyHeroes()
	local _AllyHeroes = {}
	players = game.players
	for i, unit in ipairs(players) do
		if unit and not unit.is_enemy and unit.object_id ~= myHero.object_id and IsValid(unit) then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end


function GetEnemyCountCicular(range, target)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(target.origin, unit.origin) < Range and IsValid(unit) then
        count = count + 1
        end
    end
    return count
end

function FindTheOath()
	if Oathsworn then return end
    ally = game.players
	for _, ally in ipairs(GetAllyHeroes()) do
        if ally:has_buff("kalistacoopstrikeally") then
            console:log("Shaunyboi Kalista - Found [R] Save Ally")
            Oathsworn = ally
		end
	end	
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	kalista_category = menu:add_category_sprite("Shaun's Sexy Kalista", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	kalista_category = menu:add_category("Shaun's Sexy Kalista")
end

kalista_enabled = menu:add_checkbox("Auto [R] Save Enabled", kalista_category, 1)
menu:add_label("Increasing Incoming Hit-Time Will Calculate Incoming Damage Earlier", kalista_category)
ally_hittime = menu:add_slider("Increase Incoming Ally Hit-Time (milliseconds)", kalista_category, 0, 1000, 350)
kalista_range = menu:add_checkbox("[R] Range", kalista_category, 1)


local function CastR()
	spellbook:cast_spell(SLOT_R, 0.25)
end

local function Auto_Save_Logic()
	if Oathsworn and Oathsworn:distance_to(myHero.origin) <= Rrange then
        hit_time_ally = menu:get_value(ally_hittime) / 1000
		ally_incoming_dmg = getincommingdmg(Oathsworn, hit_time_ally)
        if ally_incoming_dmg >= Oathsworn.health then
			CastR()
        elseif GetEnemyCountCicular(500, Oathsworn) >= 2 and Oathsworn:health_percentage() <= 10 then 
			CastR()
		end	
	end	
end	

local function on_draw()
    if menu:get_value(kalista_enabled) == 1 and menu:get_value(kalista_range) == 1 and Ready(SLOT_R) then
	    renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, Rrange, 255, 255, 255, 255)
    end
end

local function on_tick()
    if menu:get_value(kalista_enabled) == 1 and Ready(SLOT_R) then
        Auto_Save_Logic()
        FindTheOath()
    end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)