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
require("DebugView")


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

-- default layer of the object (for Z-ordering)
prototype.layer = 0

prototype.onWallCollision = function()
  -- override me!
end

prototype.onObjectCollision = function()
  -- override me!
end

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "GameObject(" .. self.id .. ")"
end

function prototype.snap_from_collision(self, dx, dy, max)
  local i, walls = 0, Level.get().tilegrid
  while walls:collision(self) and (not max or i < max)  do
    self.pos:plusequals(dx, dy)
    i = i + 1
  end
end

function prototype.snap_to_collision(self, dx, dy, max)
  local i, walls = 0, Level.get().tilegrid
  while not walls:collision(self, self.pos.x + dx, self.pos.y + dy) 
        and (not max or i < max)  do
    self.pos:plusequals(dx, dy)
    i = i + 1
  end
end

function prototype.wall_collisions_fastobject(self, dt)    
  -- short-hand alias
  local walls = Level.get().tilegrid
  local fisix = self.fisix or self
  
  -- desired new position
  local new_x, new_y 
      = self.pos.x + self.inertia.x*dt, self.pos.y + self.inertia.y*dt
  
  -- broad-phase raycast
  local broad_collision, broad_x, broad_y 
      = walls:lineCollision(self.pos.x, self.pos.y, new_x, new_y) 
  -- broad-phase collision ?
  if broad_collision then
    -- snap to collision
    self.pos:reset(broad_x, broad_y)
    local snap_dir = self.inertia:normalized()
    self:snap_from_collision(-snap_dir.x, -snap_dir.y, 
                              Tile.SIZE.x + Tile.SIZE.y)
    -- stop moving
    self.inertia:reset(0, 0)
    -- execute callback
    self:onWallCollision()
  else
    self.pos:reset(new_x, new_y)
  end
end

function prototype.wall_collisions(self, dt)
  -- short-hand alias
  local walls = Level.get().tilegrid
  local fisix = self.fisix or self
  
  -- set this to true if there was a collision
  local was_collision = false
  
  -- check if we're on the ground
  self.airborne = 
    (not walls:pixelCollision(self.pos.x, self.pos.y+1))
  if not self.airborne and self.inertia.y > 0 then
    self.inertia.y = 0
  end 
  -- move the object HORIZONTALLY FIRST
  if self.inertia.x ~= 0 then
    local move_x = self.inertia.x*dt
    local new_x = self.pos.x + move_x
    self.pos_prev.x = self.pos.x
    -- is new x in collision ?
    if walls:collision(self, new_x, self.pos.y) then
      was_collision = true
      -- is collision with an UPWARD slope ?
      if fisix.CLIMB_SLOPES and 
      (not walls:collision(self, new_x, self.pos.y - math.abs(move_x))) then
        -- teleport up slope
        self.pos.y = self.pos.y - math.abs(move_x)
      else
        self.inertia.x = 0 
      end
      -- move as far as possible towards new position
      self:snap_to_collision(useful.sign(self.inertia.x), 0, math.abs(move_x))
    else
      -- if so move to new position
      self.pos.x = new_x
      -- coming off a DOWNWARD slope ?
      if fisix.CLIMB_SLOPES and (not airborne) and (self.inertia.y == 0)
      and (not walls:collision(self, new_x, self.pos.y + 1)) then
        -- snap to slope
        self:snap_to_collision(0, 1, math.abs(move_x))
      end
    end
  end
  -- move the object VERTICALLY SECOND
  if self.inertia.y ~= 0 then
    local move_y = self.inertia.y*dt
    local new_y = self.pos.y + move_y
    self.pos_prev.y = self.pos.y
    -- is new y position free ?
    if walls:collision(self, self.pos.x, new_y) then
      was_collision = true
      -- if not move as far as possible
      self:snap_to_collision(0, useful.sign(self.inertia.y), math.abs(move_y))
      self.inertia.y = 0
    else
      -- if so move to new position
      self.pos.y = new_y
    end
  end
  -- generate collision with walls event
  if was_collision and self.onWallCollision then
    self:onWallCollision()
  end
end
  


function prototype.update(self, dt)
  -- short-hand alias
  local walls = Level.get().tilegrid
  local fisix = self.fisix or self
  
  -- update view if applicable
  if self.view and self.view.update then
    self.view:update(dt)
  end
  
  -- apply gravity
  if fisix.GRAVITY and (self.airborne or not self.COLLIDES_WALLS) then
    self.inertia.y = self.inertia.y + fisix.GRAVITY*dt
  end
  
  -- apply friction
  if fisix.FRICTION and (fisix.FRICTION ~= 0) then
    self.inertia:divequals(math.pow(fisix.FRICTION, dt))
  end
  
  -- clamp inertia to terminal velocity...
  -- ... absolute speed
  if fisix.TERMINAL_VELOCITY then
    local norm_inertia = self.inertia:len()
    if norm_inertia > fisix.TERMINAL_VELOCITY then
      -- reset norm of inertia vector
      self.inertia:normalize_inplace()
      self.inertia:mulequals(fisix.TERMINAL_VELOCITY)
    end
  end
  local abs_dx, abs_dy = math.abs(self.inertia.x), math.abs(self.inertia.y)
  if fisix.MAX_DX and (abs_dx > fisix.MAX_DX) then
    self.inertia.x = fisix.MAX_DX*useful.sign(self.inertia.x)
  end
  if fisix.MAX_DY and (abs_dy > fisix.MAX_DY) then
    self.inertia.y = fisix.MAX_DY*useful.sign(self.inertia.y)
  end
  
  -- clamp less than epsilon inertia to 0
  if math.abs(self.inertia.x) < 0.01 then self.inertia.x = 0 end
  if math.abs(self.inertia.y) < 0.01 then self.inertia.y = 0 end
  
  -- treat "hard" collisions with walls last of all
  self.pos_prev:reset(self.pos)
  if self.COLLIDES_WALLS then
    -- very fast objects need to raycast or they'll move thorough walls
    local fastobject = (math.abs(self.inertia.x)*dt > Tile.SIZE.x + self.w) 
                    or (math.abs(self.inertia.y)*dt > Tile.SIZE.y + self.h)             
          
    if fastobject then
      -- fast objects
      self:wall_collisions_fastobject(dt)
    else
      -- slow objects
      self:wall_collisions(dt)
    end
    
  -- for objects that don't collide, simply move to their new position
  elseif self.inertia.x ~= 0 or self.inertia.y ~= 0 then
    self.pos:plusequals(self.inertia.x*dt, self.inertia.y*dt)
  end
end

function prototype.control(self)
  if self.controller then
    self.controller:control(self)
  end
end


function prototype.draw(self)
  -- check if in camera view
  if not Level.get().camera:check(self.pos.x, self.pos.y) then
    return 
  end
  
  -- draw shiz
  if self.view then
    self.view:draw(self)
  else
    DebugView:draw(self)
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

function GameObject.new(x, y, no_id, layer)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })
  
  -- create attributes
  self.id = useful.tri(no_id, -1, generate_id())
  self.pos = vector(x, y)
  self.pos_prev = vector(x, y)
  self.inertia = vector(0, 0)
  if layer then
    self.layer = layer
  end
  
  -- add to list of game objects in the current level 
  if self.layer <= 0 then
    -- insert at END of table (foreground)
    Level.get():addForeground(self)
  else
    -- insert at the START of the table (background) *DEFER TILL END OF UPDATE*
    Level.get():addBackground(self)
  end
  
  return self
end


GameObject.collision = function(a, b)

  -- horizontally seperate ?
  local v1x, v2x = (b.pos.x + b.w) - a.pos.x, (a.pos.x + a.w) - b.pos.x
  if (v1x < 0 and v2x >= 0) or (v1x > 0 or v2x <= 0) then
    return false
  end
  -- vertically seperate ?
  local v1y, v2y = (b.pos.y + b.h) - a.pos.y, (a.pos.y + a.h) - b.pos.y
  if (v1y < 0 and v2y >= 0) or (v1y > 0 or v2y <= 0) then
    return false
  end
  -- in every other case there is a collision
  print("COLLISION")
  return true
end

--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype