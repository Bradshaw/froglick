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
BulletView = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function BulletView.new(x1, y1, x2, y2)
  
  -- metatable
  local self = GameObject.new(x2, y2, true, -10)  -- no id generated
  setmetatable(self, {__index = prototype })
  self.pos_prev:reset(x1, y1)
  
  -- type
  --! FIXME
  self.type = GameObject.TYPE_SPACEMAN_PROJECTILE
  
  -- return instance
  return self
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

prototype.update = function(self, dt)
  self.purge = true
end

prototype.draw = function(self)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.line(self.pos_prev.x, self.pos_prev.y, 
        self.pos.x, self.pos.y)
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype