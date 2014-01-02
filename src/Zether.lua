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

local super = require("GameObject")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Zether = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

prototype.time_bonus = 10

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Zether.new(x, y)
  -- metatable
  local self = GameObject.new(x, y) -- no id generated, foreground
  setmetatable(self, {__index = prototype })
  
  -- fixme
  self.pos.x, self.pos.y = self.pos.x + 32, self.pos.y + 32

  -- types
  self.type = GameObject.TYPE_ZETHER
  
  -- size
  self.w, self.h = 16, 16
  
  -- return instance
  return self
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

prototype.canCollideObject = function(self, other)
  return (other.type == GameObject.TYPE_SPACEMAN)
end

prototype.draw = function(self)
  love.graphics.setColor(255, 255, 255)
  love.graphics.drawq(Tile.DECORATIONIMAGE, Tile.DECOQUADS.ZETHER, self.pos.x-32, self.pos.y-32)
  --love.graphics.line(self.pos.x, self.pos.y, Spaceman[1].pos.x, Spaceman[1].pos.y)
  --love.graphics.rectangle("line", self.pos.x-32, self.pos.y-32, self.w, self.h)
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype