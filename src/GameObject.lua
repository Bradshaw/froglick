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

function prototype.snap_to_collision(self, dx, dy, max)
  local i = 0
  while Level.get().tilegrid:collision(self, self.pos.x + dx, self.pos.y + dy) 
        and (not max or i < max)  do
    self.pos:plusequals(dx, dy)
    i = i + 1
  end
end

function prototype.update(self, dt)
  
  -- short-hand alias
  local walls = Level.get().tilegrid
  
  -- check for collision with walls
  if self.collides_walls then
    --! VERTICAL COLLISIONS check if we're ALREADY in a wall
    if walls:collision(self) then
      -- FIXME this code is repeated almost exactly...
      self.pos:reset(self.pos_prev)
      local dir = self.inertia:normalized()
      self:snap_to_collision(dir.x, dir.y, self.inertia.x + self.inertia.y)
      self.inertia.y = 0
    end
    
    --! HORIZONTAL COLLISIONS pre-emptive check
    if walls:collision(self, self.pos.x + self.inertia.x*dt, 
                        self.pos.y + self.inertia.y*dt) then
       -- FIXME ... here! Should be factorised
       self.pos:reset(self.pos_prev)
       local dir = self.inertia:normalized()
       self:snap_to_collision(dir.x, dir.y, self.inertia.x + self.inertia.y)
       self.inertia.x = -useful.sign(self.inertia.x) * 3
    end
    
    -- check if we're on the ground
    self.airborne = 
      (not walls:pixelCollision(self.pos.x, self.pos.y+1))
    if not self.airborne and self.inertia.y > 0 then
      self.inertia.y = 0
    end 
  end
  
  -- apply gravity
  if self.airborne or not self.collides_walls then
    self.inertia.y = self.inertia.y + self.gravity*dt
  end
  
  -- apply friction
  if self.friction_airborne and self.airborne then
    self.inertia:divequals(math.pow(self.friction_airborne, dt))
  elseif self.friction then
    self.inertia:divequals(math.pow(self.friction, dt))
  end
  
  -- clamp inertia to terminal velocity
  if self.terminal_velocity then
    if math.abs(self.inertia.x) > self.terminal_velocity then
      self.inertia.x = self.terminal_velocity * useful.sign(self.inertia.x)
    end
    if math.abs(self.inertia.y) > self.terminal_velocity then 
      self.inertia.y = self.terminal_velocity * useful.sign(self.inertia.y)
    end
  end
  
  -- clamp less than epsilon inertia to 0
  if math.abs(self.inertia.x) < 0.01 then self.inertia.x = 0 end
  if math.abs(self.inertia.y) < 0.01 then self.inertia.y = 0 end
  
  -- move the object
  if self.inertia.x ~= 0 or self.inertia.y ~= 0 then
    self.pos_prev:reset(self.pos)
    self.pos:plusequals(self.inertia)
  end
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
  self.pos_prev = vector(x, y)
  self.inertia = vector(0, 0)
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype