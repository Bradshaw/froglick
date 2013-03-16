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
require("SplosionView")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Splosion = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Splosion.new(x, y, diam, pow)
  -- metatable
  local self = GameObject.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- initialise attributes
  self.diam = diam
  self.pow = pow
  
  -- recursive creation of smaller sub-explosions
  if pow > 1 then
    local div = math.random(1, pow-1)
    local nextup = {}
    for i=1, div-1 do
      local a = math.random()*math.pi*2
      local d = math.random()*diam

      nextup[i]={pow = math.floor(pow/div),
      x = math.cos(a)*d,
      y = math.sin(a)*d}
    end
    local a = math.random()*math.pi*2
    local d = math.random()*diam
    nextup[div] = { pow = pow%div, x = math.cos(a)*d, y = math.sin(a)*d }
    for i,v in ipairs(nextup) do
      Splosion.new(self.x+v.x, self.y+v.y, diam*0.8, v.pow)
    end
  end
  
  -- return instance
  return self
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

prototype.update = function(self, dt)
  -- super-class update
  super.update(self, dt)
  
  -- shrink and disappear
  self.diam = self.diam - dt*250
  if self.diam < 2 then
    self.purge = true
  end
end
  
--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype