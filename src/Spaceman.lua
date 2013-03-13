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

local Animal_mt = require("Animal")
--require("DebugView")

require("SpacemanView")
require("KeyboardController")
Splosion = require("Splosion")

gunsound = love.audio.newSource("audio/gunshot_Seq01.ogg")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Spaceman = { }

Spaceman.GROUND_FISIX = 
{
  COLLIDES_WALLS = true,
  GRAVITY = 0,
  FRICTION = 50
}

Spaceman.AIR_FISIX = 
{
  COLLIDES_WALLS = true,
  GRAVITY = 300,
  FRICTION = 2
}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = Animal_mt })

-- default attributes
prototype.w = 10
prototype.h = 20
prototype.attackTimeout = 0.12
prototype.attackCost = 30

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Spaceman(" .. self.id .. ")"
end

function prototype.tryMove(self, direction)
  
  if direction.x ~= 0 and not self:isAttacking() then
    self.facing = useful.sign(direction.x)
  end
  
  if direction.y < 0 and math.floor(self.energy) > 10 then
    if not self.airborne then
      self.inertia.y = -100
      --self.energy = 0
    else
      self.boosting = true
      -- FIXME hacky tweak values
      self.inertia:plusequals(direction.x * 30, math.min(0,direction.y * 30))
    end
  else
    if direction.y < 0 then
      self.energy = 0
    end
    self.boosting = false
    self.inertia:plusequals(direction.x * 30, math.min(0,direction.y * 6))
  end
end

function prototype.tryAttack(self, direction)
 
  -- able to fire?
  if self.energy > self.attackCost and self:isReloaded() then
    -- default to current facing if no direction is specified
    if direction.x == 0 and direction.y == 0 then
      direction.x = self.facing
    end
    
    -- turn in direction of attack
    --! FIXME we need a facing for legs (X-axis) and for body (X and Y)
    if direction.x ~= 0 then
      self.facing = direction.x
    end
    
    -- play gun sound and wobble camera
    gunsound:rewind()
    gunsound:play()
    toggleDrunk = 1
    
    -- reset time since last attack
    self.attackTime = 0
    self.energy = math.max(0, self.energy - self.attackCost)
    
    -- randomise shoot animation
    if math.random() > 0.5 then
      self.view.muzflip = not self.view.muzflip
    end
    
    -- apply recoil
    self.inertia:plusequals(-direction.x * 10, -math.max(0, direction.y * 30)) 
    
    -- create projectile
    Projectile.new(self.pos.x, self.pos.y -20 + math.random(0,1), direction.x, direction.y)
  end
end

function prototype.update(self, dt)
  -- super-class update
  local super = getmetatable(prototype)
  super.__index.update(self, dt)
  
  -- change fisix
  self.fisix 
    = useful.tri(self.airborne, Spaceman.AIR_FISIX, Spaceman.GROUND_FISIX);
  
  -- finish attack
  self.attackTime = self.attackTime + dt
  
  -- recharge energy
  self.energy = math.min(self.energy + dt*100, 100)
  
  -- boost consumes energy
  if self.boosting then
    self.energy = math.min(self.energy - dt*400, 100)
  end  
end

function prototype:isReloaded()
  return (self.attackTime > self.attackTimeout)
end

function prototype:isAttacking()
  return (self.attackTime < self.attackTimeout/2)
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Spaceman.new(x, y)
  -- metatable
  local self = Animal.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- attributes
  self.view = SpacemanView --! FIXME
  self.controller = KeyboardController
  self.attackTime = math.huge -- infinite time has passed since last attack
  self.facing = -1
  self.energy = 100
  self.fisix = Spaceman.GROUND_FISIX;

  -- store player
  table.insert(Spaceman, self) -- there can only be one
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype