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
Animal = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

prototype.hitpoints = 100

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Animal(" .. self.id .. ")"
end

function prototype.requestMove(self, direction)
  --! override me!
end

function prototype.requestAttack(self, direction)
  --! override me!
end

function prototype.die()
  --! override me!
end

function prototype.takeDamage(self, amount)
  if amount > self.hitpoints then
    self:die()
    self.purge = true
    self.hitpoints = 0
  else
    self.hitpoints = self.hitpoints - amount
  end
end


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Animal.new(x, y, hitpoints)
  -- metatables
  local self = GameObject.new(x, y)
  setmetatable(self, {__index = prototype })
  
  -- attributes
  if hitpoints then 
    self.hitpoints = hitpoints 
  end
  
  return self
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype