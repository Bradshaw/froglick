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

local GameObject_mt = require("GameObject")

 
--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Animal = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local Animal_mt = {}
setmetatable(Animal_mt, { __index = GameObject_mt })

-- default attributes
Animal_mt.hp = 100
Animal_mt.speed = 1

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function Animal_mt.__tostring(self)
  return "Animal(" .. self.id .. ")"
end

function Animal_mt.tryMove(self, direction)
  --! override me!
end

function Animal_mt.tryAttack(self, direction)
  --! override me!
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Animal.new(x, y)
  local self = GameObject.new(x, y)
  setmetatable(self, {__index = Animal_mt })
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return Animal_mt