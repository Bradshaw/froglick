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

require("AnAL")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
SpacemanView = {}

--FIXME should be in love.load
SpacemanView.IMAGE = love.graphics.newImage("images/spaceman.png")
SpacemanView.ANIM_WALK = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 0)

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function SpacemanView.draw(self, go) -- GameObject
  
  --TODO FIXME for obvious reasons
  SpacemanView.ANIM_WALK:draw(go.pos.x - go.w/2, go.pos.y - 32)

end