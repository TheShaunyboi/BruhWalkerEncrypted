
```lua
**required inputs**
SelectTarget(spell_data, checkCollision, pred)

**Spell data table**
Spell type support = "circular", "linear" & "cone"
"radius" used for "circular" & "linear" - "angle" required for spell type "cone"

**All collision inputs, enter which match the spell**
{"minion", "ally_hero", "enemy_hero", "wind_wall", "terrain_wall"}

**checkCollision**
enter 'true' if spell has collision, enter 'false' if the spell has no collision. 
The spell date needs to be populated with the correct collision inputs for the spell.

**pred**
enter 'true' if you require ShaunPrediction usage with target selction filtering, enter 'false' if not.
This will use the menu "Shaun Prediction Hit Chance Filtering" value and sort best targets that have a hit chance >= filtering %. 
This will lead to a better overall target selection and a higher/faster cast rate.
```

```lua
local ts = require("Shaunyboi-TS")

spell_data = {
    source = myHero, speed = 2000, range = 1180, delay = 0.25, radius = 60, 
    collision = {"minion", "wind_wall", "enemy_hero"}, type = "linear", hitbox = true
}

local function on_tick()
    local target, pred = ts:SelectTarget(spell_data, true, true)
    if target and pred and pred.hitChance >= 0.45 then
        local p = pred.castPos
        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
    end
end
```

```lua 
Shaunyboi-TS menu will populate if require() has been requested. 
locally the player can now change;

- Targeting selection method
- Enable & disable force targetting
- Enable & disable draw selected target
- Shaun Prediction Hit Chance Filtering
    Minimum Target Selected Hit Chance

```
Menu as of v0.2

![image](https://user-images.githubusercontent.com/82087018/211559535-7b7f665a-4eeb-4101-824c-3dfcfb2b85d5.png)
![image](https://user-images.githubusercontent.com/82087018/230791844-8cdf4877-f361-401b-9b56-b5aa4565f504.png)


