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
prototype.COLLIDES_OBJECTS = true

-- private local function
local splode = function(blt) -- blt = Bacon, lettuce and tomato ;)
  Splosion.new(blt.pos.x, blt.pos.y, 15, 10)
  blt.purge = true
end

-- default values
prototype.onWallCollision = function(self)
  splode(self)
end
prototype.onObjectCollision = function(self, other)
  self.pos:reset(other.pos)
  splode(self)
end
prototype.collidesType = function(self, t)
  return (t == GameObject.TYPE_ENEMY)
end
prototype.view = BulletView
prototype.w = 1
prototype.h = 1

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

Projectile.new = function(x, y, ndx, ndy, inertia, onCollision) -- nd_ = normalised delta_
  -- metatable
  local self = GameObject.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- type
  --! FIXME
  self.type = GameObject.TYPE_SPACEMAN_PROJECTILE
  
  -- initialise attributes
  self.inertia:reset(ndx*self.SPEED, ndy*self.SPEED)
  if inertia then
    self.inertia:plusequals(inertia)
  end
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

--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype