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

local vector = require("vector")


--[[----------------------------------------------------------------------------
PRIVATE SUBROUTINES
--]]----------------------------------------------------------------------------

local next_id = 0
local generate_id = function()
  local result = next_id
  next_id = next_id + 1
  return result
end


--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
GameObject = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}

-- default object width and height
prototype.w = 0
prototype.h = 0

-- default physical properties
prototype.collides_walls = false
prototype.airborne = false
prototype.gravity = 0
prototype.friction = 0

-- default layer of the object (for Z-ordering)
prototype.layer = 0

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "GameObject(" .. self.id .. ")"
end

function prototype.update(self, dt)
  
  -- check if we're on the ground
  if self.collides_walls then
    self.airborne = (not Level.get().tilegrid:pixelCollision(self.pos))
    if not self.airborne and self.inertia.y > 0 then
      self.inertia.y = 0
    end 
  end
  
  -- apply gravity
  if self.airborne or not self.collides_walls then
    self.inertia.y = self.inertia.y + self.gravity*dt
  end
  
  -- apply friction
  if self.friction then
    self.inertia.x = useful.absminus(self.inertia.x, self.friction*dt)
    self.inertia.y = useful.absminus(self.inertia.y, self.friction*dt)
  end
  
  --print(self, self.inertia, self.pos)
  
  -- move the object
  if self.inertia.x ~= 0 or self.inertia.y ~= 0 then
    self.pos:plusequals(self.inertia)
  end
  
  --! extend me
end

function prototype.control(self)
  if self.controller then
    self.controller:control(self)
  end
end


function prototype.draw(self)
  if self.view then
    self.view:draw(self)
  end
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

-- private subroutine
local next_id = 0
local generate_id = function()
  local result = next_id
  next_id = next_id + 1
  return result
end

function GameObject.new(x, y)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })
  
  -- create attributes
  self.id = generate_id()
  self.pos = vector(x, y)
  self.inertia = vector(0, 0)
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype