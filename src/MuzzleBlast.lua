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

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
MuzzleBlast = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

prototype.damage = 47

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function MuzzleBlast.new(x, y, damage, target_type)
  -- metatable
  local self = GameObject.new(x, y, true, -100) -- no id generated, foreground
  setmetatable(self, {__index = prototype })
  
  -- types
  self.type = GameObject.TYPE_SPLOSION
  self.target_type = target_type or GameObject.TYPE_ENEMY
  
  -- size
  self.w, self.h = 30, 30
  
  -- return instance
  return self
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

prototype.update = function(self, dt)
  -- super-class update
  super.update(self, dt)
  
  -- fade away
  local amount = dt*100
  self.w, self.h, self.pos.y = self.w - amount, self.h - amount, self.pos.y - amount/2
  if self.w <= 1 or self.h <= 1 then
    self.purge = true
  end
end

prototype.canCollideObject = function(self, other)
  return (other.type == self.target_type)
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype