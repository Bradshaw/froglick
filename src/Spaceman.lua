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


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = Animal_mt })

-- default attributes
prototype.w = 10
prototype.h = 20
prototype.COLLIDES_WALLS = true
prototype.GRAVITY = 300
prototype.FRICTION = 50 -- 2
prototype.attackTimeout = 0.12

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Spaceman(" .. self.id .. ")"
end

function prototype.tryMove(self, direction)
  
  if direction.x~=0 and not self:isAttacking() then
    self.moveIntent = direction.x
  end
  if direction.y<0 and math.floor(self.energy)>10 then
    if not self.airborne then
      self.inertia.y = -100
      --self.energy = 0
    else
      self.boosting = true
      -- FIXME hacky tweak values
      self.inertia:plusequals(direction.x * 30, math.min(0,direction.y * 30))
    end
  else
    if direction.y<0 then
      self.energy=0
    end
    self.boosting = false
    self.inertia:plusequals(direction.x * 30, math.min(0,direction.y * 6))
  end
end

function prototype.tryAttack(self, direction)
  if self.energy>30 and self:isReloaded() and (direction.x~=0 or direction.y~=0) then
    gunsound:rewind()
    gunsound:play()
    self.attackTime = 0
    toggleDrunk = 1
    self.energy = math.max(0,self.energy-30)
    if math.random()>0.5 then
      self.view.muzflip = not self.view.muzflip
    end
    --self.inertia:plusequals(-direction.x * 10, -math.max(0,direction.y * 30)) 
    Projectile.new(self.pos.x,self.pos.y-20+math.random(0,1),direction.x, direction.y)
  end
end

function prototype.update(self, dt)
  local super = getmetatable(prototype)
  super.__index.update(self, dt)
  self.attackTime = self.attackTime+dt
  self.energy = math.min(self.energy + dt*100, 100)
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
  self.moveIntent = -1
  self.energy = 100

  -- store player
  table.insert(Spaceman, self) -- there can only be one
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype