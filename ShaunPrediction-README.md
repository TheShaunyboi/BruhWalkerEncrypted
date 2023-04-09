```lua
**Spell data table**
Spell type support = "circular", "linear" & "cone"
"radius" used for "circular" & "linear" - "angle" required for spell type "cone"

**All collision inputs, enter which match the spell**
{"minion", "ally_hero", "enemy_hero", "wind_wall", "terrain_wall"}
```
```lua
ShaunPred = require "ShaunPrediction"

spell_data = {
source = myHero, speed = 2000, range = 1180, delay = 0.25, radius = 60, 
collision = {"minion", "wind_wall", "enemy_hero"}, type = "linear", hitbox = true

local function on_tick()
    local myHero = game.local_player
    local source = myHero
    local pred = ShaunPred:calculatePrediction(target, spell_data, source)

    if pred and qpred.hitChance >= 0.45 then
        local p = pred.castPos
        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
    end
end
```
```lua
ShaunPrediction menu will populate if require() has been requested. 
locally the player can now change;

- Enable & disable "Dodge Factor" - This will adjust hitchance if the target is changing waypoints/clicking like T1-Faker [APM]
- Enable & disable "Hit Chance Stability" check - Select your calculation threshold between fast/medium/slow [BETA]
- Enable & disable "Debug Draws" - Show Hit chance on target & prediction position output circle draw
```
Menu as of v0.4 [BETA]

![image](https://user-images.githubusercontent.com/82087018/230792601-635c34a4-9ab8-4fd5-a3a6-8166977a7a67.png)
![image](https://user-images.githubusercontent.com/82087018/230792621-0bfbbb93-cfff-4cf7-b113-021323a7dd5a.png)
![image](https://user-images.githubusercontent.com/82087018/230792632-a7e1dc8f-f906-4208-b658-3d5ab57299bd.png)




