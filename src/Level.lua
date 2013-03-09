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

require("useful")



--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local Level_mt = {}


--[[----------------------------------------------------------------------------
CLASS METHODS
--]]----------------------------------------------------------------------------

function Level_mt.update(self, dt)
  useful.cleanFor(self.game_objects, function(object) object:update(dt) end)
end
  
function Level_mt.draw(self)
  for i, object in self.game_objects do object:draw() end
end

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

local Level = {}


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

--! this is a 'singleton': we can only have one in memory at a time
function Level.get()
  
  local self
  
  if Level.instance then
    self = Level.instance
  else
    self = {}
    setmetatable(self, {__index = Level_mt })
    
    self.game_objects = {}
  end
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE CLASS
--]]----------------------------------------------------------------------------

return Level, Level_mt