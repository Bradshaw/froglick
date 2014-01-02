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
INCLUDE
--]]----------------------------------------------------------------------------

local Animation = require("Animation")
local AnimationView = require("AnimationView")

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
    -- timer
    love.graphics.printf(math.floor(nmi.timer), nmi.pos.x, nmi.pos.y + 20, 
                       nmi.w, "center")
end

--[[----------------------------------------------------------------------------
SHROOM BODY

It's a 'shroom. It 'shrooms.

--]]----------------------------------------------------------------------------


local SHROOM_SHEET = 
  love.graphics.newImage("images/enemy_mushroom.png")
     
local SHROOM_IDLE = 
  Animation(SHROOM_SHEET, 32, 32, 1)
      
local SHROOM_AGRESSIVE = 
  Animation(SHROOM_SHEET, 32, 32, 1, 32)

local SHROOM_ATTACK = 
  Animation(SHROOM_SHEET, 32, 32, 3, 32, 0)
  
EnemyBody.SHROOM = 
{
  tryMove = function(owner, direction)
  
  
    -- face the player
    if owner:isAttachedWall() 
    and (math.abs(direction.y) > owner.h) then
      if owner.attach == Enemy.WALL_LEFT then 
        owner.view.flip_x = (direction.y > 0)
      elseif owner.attach == Enemy.WALL_RIGHT then
        owner.view.flip_x = (direction.y < 0)
      end
    elseif (math.abs(direction.x) > owner.w) then
      owner.view.flip_x = (direction.x > 0)
    end
  end,
      
  wander = function(owner)
    -- it's a mushroom dude -_-'
  end,
      
  getSize = function()
    return Tile.SIZE.x / 2, Tile.SIZE.y
  end,
      
  getHitpoints = function()
    return 220
  end,
    
  createView = function()
    return AnimationView(SHROOM_IDLE)
  end,
      
  idleAnimation = function(owner)
    owner.view:setAnimation(SHROOM_IDLE)
    owner.view.speed = 0
  end,    
      
  agressiveAnimation = function(owner)
    owner.view:setAnimation(SHROOM_AGRESSIVE)
    owner.view.speed = 0
  end,   
      
  attackAnimation = function(owner)
    owner.view:setAnimation(SHROOM_ATTACK)
    owner.view.speed = 3
  end,
  
  __tostring = function()
    return "shroom"
  end
}

--[[----------------------------------------------------------------------------
ZOMBIE BODY

The obligatory zombie. Same platform physics as the player. Falls off cliffs for 
comic relief. Also makes scary noises. Has alien ray-gun, or not. Perhaps we
can save that for the non-zombie version you meet at the end (spoilers)

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
    --TODO TEH ZOMBIE BODY
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

Floats around the level. Goes "gloumf, gloumf, gloumf". Does not go 
"lardy-dardy-da". Unless nobody is watching.

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