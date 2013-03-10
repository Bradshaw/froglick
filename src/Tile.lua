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

local vector = require("vector")


--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Tile = {}

-- size of the tiles
Tile.SIZE = vector(32, 32)

-- enum values
Tile.EMPTY = 0
Tile.TOP_LEFT = 1
Tile.TOP_RIGHT = 2
Tile.BOTTOM_LEFT = 3
Tile.BOTTOM_RIGHT = 4
Tile.FULL = 5


--[[----------------------------------------------------------------------------
PRIVATE SUBROUTINES
--]]----------------------------------------------------------------------------

local draw_wall = {}
draw_wall[Tile.TOP_LEFT] = function(t,x,y)
  love.graphics.triangle("fill", x, y, 
                                x + Tile.SIZE.x, y, 
                                x, y + Tile.SIZE.y )
end

draw_wall[Tile.TOP_RIGHT] = function(t,x,y)
  love.graphics.triangle("fill", x, y, 
                              x + Tile.SIZE.x, y, 
                              x + Tile.SIZE.x, y + Tile.SIZE.y)
end

draw_wall[Tile.BOTTOM_LEFT] = function(t,x,y)
  love.graphics.triangle("fill", x, y, 
                              x, y + Tile.SIZE.y, 
                              x + Tile.SIZE.x, y + Tile.SIZE.y)
end

draw_wall[Tile.BOTTOM_RIGHT] = function(t,x,y)
  love.graphics.triangle("fill", x + Tile.SIZE.x, y, 
                              x, y + Tile.SIZE.y, 
                              x + Tile.SIZE.x, y + Tile.SIZE.y)
end

draw_wall[Tile.FULL] = function(t,x,y)
  love.graphics.rectangle("fill", x, y, 
                                  Tile.SIZE.x, Tile.SIZE.y)
end

--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

-- inherits from nobody
local prototype = {}

-- methods
function prototype.draw(self,x,y)
  if self.wall and self.wall > 0 then
    draw_wall[self.wall](self,x,y)
  end
end

function prototype.set(self, wall)
  self.wall = wall
end


--[[----------------------------------------------------------------------------
CLASS (NAMESPACE) FUNCTIONS
--]]----------------------------------------------------------------------------

-- constructor
function Tile.new(wall)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })
  
  -- create attributes
  --self.__grid_pos = vector(row, col)
  --self.__pos = self.__grid_pos:permul(Tile.SIZE) 
  --                            - Tile.SIZE -- arrays start at 1!
  self.wall = wall
  
  -- return the instance
  return self
end

Tile.DEFAULT = Tile.new(Tile.FULL)


--[[----------------------------------------------------------------------------
EXPORT METATABLE
--]]----------------------------------------------------------------------------

return prototype