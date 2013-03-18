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

local super = require("Animal")

require("SpacemanView")
require("KeyboardController")
Sparkle = require("Sparkle")
require("Projectile")
require("Splosion")

gunsound = love.audio.newSource("audio/gunshot_Seq01.ogg")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Spaceman = { }

Spaceman.GROUND_FISIX = 
{
  COLLIDES_OBJECTS = true,
  COLLIDES_WALLS = true,
  GRAVITY = 0,
  FRICTION = 150,
  MAX_DX = 100,
  BOOST_MAX_DY = 300,
  MOVE = 1200,
  BOOST = 4200,
  BOOST_LOW_ENERGY = 1800,
  CLIMB_SLOPES = true
}

Spaceman.AIR_FISIX = 
{
  COLLIDES_OBJECTS = true,
  COLLIDES_WALLS = true,
  GRAVITY = 500,
  FRICTION = 2,
  MAX_DX = 150,
  MAX_DY = 350,
  MOVE = 300,
  BOOST = 1620,
  BOOST_MAX_DY = 150,
  BOOST_LOW_ENERGY = 0,
  CLIMB_SLOPES = true
}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

-- default attributes
prototype.w = 10
prototype.h = 20
prototype.attackTimeout = 0.1
prototype.attackCost = 20
prototype.attackRecoil = 10
prototype.boostCost = 200

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
  self.requested_move = (direction.x ~= 0)
  self.requested_boost = (direction.y < 0)
  
  -- turn in direction of movement
  if self.requested_move then
    self.legs_side = useful.sign(direction.x)
    if not self:weaponRaised() then
      self.torso_facing.x = direction.x
    end
  end
  
end

function prototype.tryBoost(self, dt)

  if self.energy> 10 then
    Sparkle.newBooster(self.pos.x-self.legs_side*8+math.random(-3,3) , self.pos.y-18+math.random(-3,3),-self.inertia.x+math.random(-50,50),math.max(self.inertia.y,0) + 500 + math.random(0,250))
  end

  -- boost consumes energy
  self.energy = math.max(self.energy - dt*self.boostCost, 0)

  -- boost thrust depends on remaining energy
  local thrust = useful.tri(self.energy > 10, 
      self.fisix.BOOST, self.fisix.BOOST_LOW_ENERGY)
  
  -- cap maximum upward speed of boost (math.max 'coz up is negative) 
  self.inertia.y = math.max(-self.fisix.BOOST_MAX_DY, self.inertia.y - thrust*dt)
end

function prototype.tryMove(self, dt)
  if self.airborne then
    Sparkle.newBooster(self.pos.x-self.legs_side*8 , self.pos.y-18,self.inertia.x-self.legs_side*500 + math.random(0,250),-self.inertia.y+math.random(-50,50))
  end
  --! TODO check if capable of moving (ie. not dead)
  self.inertia.x = self.inertia.x + self.legs_side*self.fisix.MOVE*dt
end

function prototype.tryStop(self, dt)
  --! TODO slow down movement
end


--[[----------------------------------------------------------------------------
Attacking
--]]


function prototype.requestAttack(self, direction)
  -- save the attack request, execute it in the update
  self.requested_attack = true
  
  -- default to current legs_side if no direction is specified
  if (direction.x ~= 0) or (direction.y ~= 0) then
    -- if a direction is specified use it!
    self.torso_facing:reset(direction)
  end
 
  -- reset legs side only if a move is not requested and not already firing
  if (direction.x ~= 0) and (not self.requested_move) then
    self.legs_side = useful.sign(direction.x)
  end
end

function prototype.tryAttack(self, dt)
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
    local prj = Projectile.new(self.pos.x + self.torso_facing.x*10,
                    self.pos.y -20 + self.torso_facing.y*10,
                    self.torso_facing.x, self.torso_facing.y, self.inertia)
    for i=1,3 do
      Sparkle.newBooster(prj.pos.x+prj.inertia.x/200, prj.pos.y+prj.inertia.y/200, prj.inertia.x/8+math.random(-250,250), prj.inertia.y/8+math.random(-250,250))
    end
  end
end

function prototype:isAttacking()
  return (self.attackTime < self.attackTimeout/2)
end

function prototype:isReloaded()
  return (self.attackTime > self.attackTimeout)
end

function prototype:weaponRaised()
  return (self.attackTime < self.attackTimeout*5)
end


--[[----------------------------------------------------------------------------
Update
--]]

function prototype.update(self, dt)
  -- super-class update
  super.update(self, dt)
  
  -- change fisix
  self.fisix 
    = useful.tri(self.airborne, Spaceman.AIR_FISIX, Spaceman.GROUND_FISIX);
  
  -- finish attack
  self.attackTime = self.attackTime + dt
  -- turn torso to legs after lowering weapon
  if not self.requested_attack then
    self.torso_facing:reset(self.legs_side, 0)
  end
  
  -- recharge energy
  self.energy = math.min(self.energy + dt*100, 100)
  
  -- boost vertically if boost is requested
  if self.requested_boost then
    self:tryBoost(dt)
  end
  
  -- accelerate horizontally if move is requested
  if self.requested_move then
    self:tryMove(dt)
  else
    self:tryStop(dt)
  end
  
  -- attack if attack is requested
  if self.requested_attack then
    self:tryAttack(dt)
  end
  
  -- clear input requests
  self.requested_move = false
  self.requested_attack = false
  self.requested_boost = false
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Spaceman.new(x, y)
  -- metatable
  local self = Animal.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- type
  self.type = GameObject.TYPE_SPACEMAN
  
  -- MVC
  self.view = SpacemanView
  self.controller = KeyboardController
  
  -- combat
  self.attackTime = math.huge -- "infinite time has passed since last attack"
  self.energy = 100
  
  -- movement
  self.fisix = Spaceman.GROUND_FISIX
  self.legs_side = -1
  self.torso_facing = vector(-1, 0)
  
  -- input state
  self.requested_move = false
  self.requested_attack = false
  self.requested_boost = false
  
  -- add this new Spaceman to the Spaceman list
  table.insert(Spaceman, self) 
   
  -- return the instance
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype