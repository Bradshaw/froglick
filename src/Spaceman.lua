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
prototype.attackRecoil = 10

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Spaceman(" .. self.id .. ")"
end


--[[----------------------------------------------------------------------------
Moving
--]]

function prototype.requestMove(self, direction)
  
  -- is the character attempting to move or to stop?
  self.requested_move = (direction.x ~= 0 or direction.y ~= 0)
  
  -- request movement
  if self.requested_move then
    if direction.x ~= 0 and not self.requested_attack then
      self.legs_side = useful.sign(direction.x)
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
  
  -- request stop
  else
    --! TODO slow down movement
  end
  
end



--[[----------------------------------------------------------------------------
Attacking
--]]


function prototype.requestAttack(self, direction)
  -- save the attack request, execute it in the update
  self.requested_attack = true
  
  -- default to current legs_side if no direction is specified
  if (direction.x == 0) and (direction.y == 0) then
    direction.x = self.legs_side
  end
 
  -- reset legs side only if a move is not requested
  if (direction.x ~= 0) and (not self.requested_move) then
    self.legs_side = useful.sign(direction.x)
  end
  
  -- reset torso facing to attack direction
  self.torso_facing:reset(direction)
end

function prototype.tryAttack(self)
  -- able to fire?
  if (self.energy > self.attackCost) and self:isReloaded() then
    
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
    self.inertia:plusequals(-self.torso_facing.x * self.attackRecoil, 0) 
    
    -- create projectile
    Projectile.new(self.pos.x, self.pos.y -20 + math.random(0, 1), 
                    self.torso_facing.x, self.torso_facing.y)
  end
end

function prototype:isReloaded()
  return (self.attackTime > self.attackTimeout)
end

function prototype:isAttacking()
  return (self.attackTime < self.attackTimeout/2)
end


--[[----------------------------------------------------------------------------
Update
--]]

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
  
  -- attack if attack is requested
  if self.requested_attack then
    self:tryAttack()
    self.requested_attack = false
  end
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Spaceman.new(x, y)
  -- metatable
  local self = Animal.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- MVC
  self.view = SpacemanView --! FIXME
  self.controller = KeyboardController
  
  -- combat
  self.attackTime = math.huge -- infinite time has passed since last attack
  self.energy = 100
  
  -- movement
  self.fisix = Spaceman.GROUND_FISIX
  self.legs_side = -1
  self.torso_facing = vector(-1, 0)
  
  -- input state
  self.requested_move = false
  self.requested_attack = false
  
  -- store player
  table.insert(Spaceman, self) -- there can only be one
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype