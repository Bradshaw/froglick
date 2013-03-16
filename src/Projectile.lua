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
Projectile = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

-- constants
prototype.SPEED = 3000

-- default values
prototype.onimpact = function(self, sx, sy)
  Splosion.new(sx, sy, 15, 10)
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function Projectile.new(x, y, ndx, ndy, onimpact)
  -- metatable
  local self = GameObject.new(x, y)
  setmetatable(self, {__index = prototype })
  
  self.inertia:reset(ndx*self.SPEED, ndx*self.SPEED)
  if onimpact then
    self.onimpact = onimpact
  end
  
  -- return the instance
  return self
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.update(self, dt)
  -- super-class update
  super.update(self, dt)

	if Level.get().tilegrid:pixelCollision(self.x,self.y) then
		self:onimpact((self.oldx+self.x)/2,(self.oldy+self.y)/2)
		self.purge = true
	end

end

function prototype.draw(self)
	love.graphics.line(self.x,self.y,self.oldx,self.oldy)
end

--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype