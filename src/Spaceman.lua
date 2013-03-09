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
require("DebugView")
require("KeyboardController")


--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Spaceman = {}

--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local Spaceman_mt = {}
setmetatable(Spaceman_mt, { __index = Animal_mt })

-- default attributes
Spaceman_mt.w = 10
Spaceman_mt.h = 20

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function Spaceman_mt.__tostring(self)
  return "Spaceman(" .. self.id .. ")"
end

function Spaceman_mt.update(self, direction)
  --! override me
end

function Spaceman_mt.tryMove(self, direction)
  self.pos = self.pos + direction
end

  

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Spaceman.new(x, y)
  -- metatable
  local self = Animal.new(x, y)
  setmetatable(self, {__index = Spaceman_mt })
  
  -- attributes
  self.view = DebugView --! FIXME
  self.controller = KeyboardController
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return Spaceman_mt