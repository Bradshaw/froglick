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

local super = require("GameObject")
require("ProjectileView")
require("MuzzleBlast")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Projectile = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

-- constants
prototype.SPEED = 3000
prototype.COLLIDES_WALLS = true

-- private local function
local splode = function(blt) -- blt = Bacon, lettuce and tomato ;)
  Splosion.new(blt.pos.x, blt.pos.y, 15, 10)
  BulletView.new(blt.start_x, blt.start_y, blt.pos.x, blt.pos.y)
  blt.purge = true
end

-- default values
prototype.w = 1
prototype.h = 1
prototype.damage = 70

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

Projectile.new = function(x, y, ndx, ndy, firer, onCollision) -- nd_ = normalised delta_
  -- metatable
  local self = GameObject.new(x, y, true, 10)  -- no id generated, background
  setmetatable(self, {__index = prototype })
  
  -- type
  self.type = GameObject.TYPE_SPACEMAN_PROJECTILE

  -- ignore shadows
  self.inFrontOfVignette = true
  
  -- initialise attributes
  self.inertia:reset(ndx*self.SPEED, ndy*self.SPEED)
  if firer then 
    self.pos_prev:reset(firer.pos)
    --self.inertia:plusequals(firer.inertia)
  end
  
  self.start_x = self.pos.x
  self.start_y = self.pos.y
  self.isSuperfast = true
  
  if onCollision then
    self.onCollision = onCollision
  end
  
  -- return the instance
  return self
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.update(self, dt)
 
  -- super-class update
  super.update(self, dt)
end

prototype.onPurge = function(self)
  splode(self)
end

prototype.onWallCollision = function(self)
  self.purge = true
end

prototype.onObjectCollision = function(self, other)
  self.pos.x = other.pos.x
  self.pos.y = other.pos.y - other.h/2
  self.purge = true
end

prototype.canCollideObject = function(self, other)
  if self.type == GameObject.TYPE_SPACEMAN_PROJECTILE then
    return (other.type == GameObject.TYPE_ENEMY)
  else
    return (other.type == GameObject.TYPE_SPACEMAN)
  end
end

--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype