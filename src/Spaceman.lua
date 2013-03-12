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
prototype.collides_walls = true
prototype.gravity = 300
prototype.friction = 50
prototype.friction_airborne = 2
prototype.terminal_velocity = 300

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Spaceman(" .. self.id .. ")"
end

function prototype.tryMove(self, direction)
  -- FIXME hacky tweak values
  if direction.x~=0 and not love.keyboard.isDown(" ") then
    self.moveIntent = direction.x
  end
  self.inertia:plusequals(direction.x * 10, math.min(0,direction.y * 20))
end

function prototype.tryAttack(self, direction)
  if self.attackTime>self.attackTimeout and (direction.x~=0 or direction.y~=0) then
    gunsound:rewind()
    gunsound:play()
    self.attackTime = 0
    toggleDrunk = 1
    if math.random()>0.5 then
      self.view.muzflip = not self.view.muzflip
    end
    self.inertia:plusequals(-direction.x * 10, -math.min(0,direction.y * 20)) 
    Projectile.new(self.pos.x,self.pos.y-20+math.random(-3,1),direction.x, direction.y)
  end
end

function prototype.update(self, dt)
  local super = getmetatable(prototype)
  super.__index.update(self, dt)
  self.attackTime = self.attackTime+dt
  
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
  self.attackTimeout = 0.15
  self.attackTime = 0
  self.moveIntent = -1

  -- store player
  table.insert(Spaceman, self) -- there can only be one
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype