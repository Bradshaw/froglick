--[[
Copyright (C) 2013 William Dyce, Kevin Bradshaw and Hannes Delbeke

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.
--]]

--[[----------------------------------------------------------------------------
IMPORTS
--]]----------------------------------------------------------------------------

require("MuzzleBlast")

--[[----------------------------------------------------------------------------
CONTAINER
--]]----------------------------------------------------------------------------

EnemyWeapon = {}

--[[----------------------------------------------------------------------------
BITE WEAPON

Bite, scratch, claw: a close-range attack.

--]]----------------------------------------------------------------------------

EnemyWeapon.BITE = 
{
  RANGE = 20,
  RANGE2 = 20*20,
  DAMAGE = 17,
  RELOAD_TIME = 1.5,
  
  attack = function(wielder, target_pos)
    MuzzleBlast.new(wielder.pos.x, wielder.pos.y, EnemyWeapon.BITE.DAMAGE, 
                    GameObject.TYPE_SPACEMAN)
  end,
  
  canAttack = function(wielder, t)
    return ((wielder.timer <= 0) and
      useful.dist2(wielder.pos.x, wielder.pos.y, t.pos.x, t.pos.y) < 
            EnemyWeapon.BITE.RANGE2)
  end,
  
  __tostring = function()
    return "bite"
  end
  
  
}


--[[----------------------------------------------------------------------------
SPIT WEAPON

Spit some sort of nasty alien fungal-goo at the player. May explode on impact
to release spores.

--]]----------------------------------------------------------------------------

EnemyWeapon.SPIT =
{
  RELOAD_TIME = 1,
  
  attack = function(wielder, direction)
    --TODO
  end,
  
  canAttack = function(wielder, direction)
    return false --TODO
  end,
  
  __tostring = function()
    return "spit"
  end
}

--[[----------------------------------------------------------------------------
SPORE CLOUD WEAPON

Spray spores out in all directs to contaminate the player. Heals allies (?)

--]]----------------------------------------------------------------------------

EnemyWeapon.SPORES =
{
  RELOAD_TIME = 1,
  
  attack = function(wielder, direction)
    --TODO
  end,
  
  canAttack = function(wielder, direction)
    return false --TODO
  end,
  
  __tostring = function()
    return "spore"
  end
}

