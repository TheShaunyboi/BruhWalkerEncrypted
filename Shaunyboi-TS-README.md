
```lua
required inputs 
SelectTarget(spell_data, checkCollision)

spell_data
This is a table filled with spell data.

Example Ezreal 'Q' spell data
local myHero = game.local_player
spell_data = {
    source = myHero, speed = 2000, range = 1180, delay = 0.25, radius = 60, 
    collision = {"minion", "wind_wall", "enemy_hero"}, type = "linear", hitbox = true
}

checkCollision
enter 'true' if spell has collision, enter 'false' if the spell has no collision. 

if checkCollision is true for the spell
The spell date needs to be populated with the correct collision inputs for the spell.
  
Example.. Ezreal 'Q'
collision = {"minion", "wind_wall", "enemy_hero"}

All collision inputs, enter which match the spell
{"minion", "ally_hero", "enemy_hero", "wind_wall", "terrain_wall"}
```

```lua
local ts = require("Shaunyboi-TS")

local function on_tick_always()
    local target = ts:SelectTarget(spell_data, true)
    if target then
        console:log(tostring(target.champ_name))
    end
end
```

```lua 
Shaunyboi-TS menu will populate if require() has been requested. 
locally the player can now change;

- Targeting selection method
- Enable & disable force targetting
- Enable & disable draw selected target

```
![image](https://user-images.githubusercontent.com/82087018/211559535-7b7f665a-4eeb-4101-824c-3dfcfb2b85d5.png)

