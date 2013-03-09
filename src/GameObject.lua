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
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local GameObject_mt = {}

GameObject_mt.w = 0;
GameObject_mt.h = 0;

--[[----------------------------------------------------------------------------
CLASS METHODS
--]]----------------------------------------------------------------------------

function GameObject_mt.update(self, dt)
  --! override me
end

function GameObject_mt.draw(self)
  --! override me
end
  
--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

local GameObject = {}


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function GameObject.new(x, y)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = GameObject_mt })
  
  -- create attributes
  self.pos = vector(x, y)
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE CLASS
--]]----------------------------------------------------------------------------

return GameObject, GameObject_mt