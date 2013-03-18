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

--[[----------------------------------------------------------------------------
SHROOM BODY
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
    return 10, 28
  end,
      
  getHitpoints = function()
    return 220
  end,
            
  draw = function(self, go)
    love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("line", go.pos.x - go.w/2, go.pos.y - go.h, go.w, go.h)
  love.graphics.printf("SHROOM", go.pos.x, go.pos.y, 
                       go.w, "center")
  end
}

--[[----------------------------------------------------------------------------
ZOMBIE BODY
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
      
  draw = function(who)
    --TODO
  end
}


--[[----------------------------------------------------------------------------
SCUTTLER BODY
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
      
  draw = function(who)
    --TODO
  end
}
  
--[[----------------------------------------------------------------------------
FLOATER BODY
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
  end
}