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
  self.inertia:plusequals(direction.x * 10, direction.y * 20)
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

  -- store player
  table.insert(Spaceman, self) -- there can only be one
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype