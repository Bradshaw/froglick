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

local Animal, Animal_mt = require("Animal")


--[[----------------------------------------------------------------------------
SPACEMAN METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local Spaceman_mt = setmetatable({},{ __index = Animal_mt })

--[[----------------------------------------------------------------------------
ANIMAL CLASS METHODS
--]]----------------------------------------------------------------------------

function Spaceman_mt.update(self, dt)
  --! override me
end
  
--[[----------------------------------------------------------------------------
ANIMAL CLASS
--]]----------------------------------------------------------------------------

local Spaceman = {}


--[[----------------------------------------------------------------------------
ANIMAL CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Spaceman.new()
  local self = {}
  setmetatable(self, {__index = Spaceman_mt })
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE CLASS
--]]----------------------------------------------------------------------------

return Spaceman, Spaceman_mt