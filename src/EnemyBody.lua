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
CONTAINER
--]]----------------------------------------------------------------------------

EnemyBody = {}

EnemyBody.draw_debug = function(body, nmi)
    love.graphics.setColor(255, 255, 255)
    -- hitbox
    love.graphics.rectangle("line", nmi.pos.x - nmi.w/2, 
                                    nmi.pos.y - nmi.h, nmi.w, nmi.h)
    
    -- hit points
    love.graphics.printf(nmi.hitpoints .. " / " .. body.getHitpoints(), 
        nmi.pos.x - 32, nmi.pos.y - nmi.h/2, 64, "center")
    
    -- body and weapon
    love.graphics.printf(nmi.weapon:__tostring(), nmi.pos.x - 16, nmi.pos.y, 16, 
        "center")
    love.graphics.printf(body:__tostring(), nmi.pos.x + 16, nmi.pos.y, 16, 
        "center")
    -- state
    love.graphics.printf(nmi:getStateName(), nmi.pos.x, nmi.pos.y + 10, 
                       nmi.w, "center")
end

--[[----------------------------------------------------------------------------
SHROOM BODY

It's a 'shroom. It shrooms.

--]]----------------------------------------------------------------------------

EnemyBody.SHROOM = 
{
  tryMove = function(owner, direction)
    -- it's a mushroom dude -_-'
  end,
      
  wander = function(owner)
    -- what part of "it's a mushroom" don't you understand?
  end,
      
  getSize = function()
    return Tile.SIZE.x / 2, Tile.SIZE.y
  end,
      
  getHitpoints = function()
    return 220
  end,
            
  draw = function(self, owner)
    EnemyBody.draw_debug(self, owner)
    --TODO
  end,
  
  __tostring = function()
    return "shroom"
  end
}

--[[----------------------------------------------------------------------------
ZOMBIE BODY

The obligatory zombie. Same platform physics as the player. Falls off cliffs.

--]]----------------------------------------------------------------------------
  
EnemyBody.ZOMBIE = 
{
  tryMove = function(who, direction)
    --TODO
  end,
      
  wander = function(who)
    --TODO
  end,
      
  getSize = function()
    return 30,30 --TODO
  end,
      
  getHitpoints = function()
    return 100 --TODO
  end,
      
  draw = function(self, owner)
    EnemyBody.draw_debug(self, owner)
    --TODO
  end,
  
  __tostring = function()
    return "zombie"
  end
}


--[[----------------------------------------------------------------------------
SCUTTLER BODY

Scuttles on walls. Can jump. Also scuttles. On walls.

--]]----------------------------------------------------------------------------

EnemyBody.SCUTTLER = 
{
  tryMove = function(owner, direction)
    --TODO
  end,
      
  wander = function(owner)
    --TODO
  end,
      
  getSize = function()
    return 30,30 --TODO
  end,
      
  getHitpoints = function()
    return 100 --TODO
  end,
      
  draw = function(self, owner)
    EnemyBody.draw_debug(self, owner)
    --TODO
  end,
  
  __tostring = function()
    return "scuttler"
  end
}
  
--[[----------------------------------------------------------------------------
FLOATER BODY

Floats around the level. Goes "gloumf, gloumf, gloumf".

--]]----------------------------------------------------------------------------
  
EnemyBody.FLOATER = 
{
  tryMove = function(owner, direction)
    --TODO
  end,
      
  wander = function(owner)
    --TODO
  end,
      
  getSize = function()
    return 30,30 --TODO
  end,
      
  getHitpoints = function()
    return 100 --TODO
  end,
      
  draw = function(who)
    --TODO
  end,
  
  __tostring = function()
    return "floater"
  end
}