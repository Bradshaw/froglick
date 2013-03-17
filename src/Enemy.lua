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

local super = require("Enemy")

 
--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Enemy = {}

-- enemies attach to wall
Enemy.WALL_LEFT = 0
Enemy.WALL_RIGHT = 1
Enemy.FLOOR = 2
Enemy.ROOF = 4

-- enemy bodies / movement types
Enemy.SHROOM = 0
Enemy.ZOMBIE = 1
Enemy.SCUTTLER = 2
Enemy.FLOATER = 3

-- enemy attack types
Enemy.BITE = 0
Enemy.SPIT = 1
Enemy.SPORES = 2


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Enemy(" .. self.id .. ")"
end

function prototype.requestMove(self, direction)
  --! override me!
end

function prototype.requestAttack(self, direction)
  --! override me!
end

function prototype.attachWall(self)
  return ((self.attach == Enemy.WALL_LEFT) or (self.attach == Enemy.WALL_RIGHT))
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

--[[----------------------------------------------------------------------------
Constructors
--]]

function Enemy.__new(x, y, hitpoints)
  -- metatable
  local self = Animal.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- all enemies are enemies
  self.type = GameObject.ENEMY
  
  -- clinging to a wall / floor / ceiling ?
  --! TODO
  self.attach = Enemy.FLOOR
  
  -- number of hitpoints
  self.hitpoints = useful.tri(hitpoints, hitpoints, 100)
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype