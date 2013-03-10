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
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
DebugView = {}


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function DebugView.draw(self, go) -- GameObject
  if go.bink then
    love.graphics.setColor(255, 0, 0)
  else
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.rectangle("line", go.pos.x - go.w/2, go.pos.y, go.w, go.h)
  love.graphics.printf(go:__tostring(), go.pos.x, go.pos.y + go.h, 
                        go.w, "center")
end