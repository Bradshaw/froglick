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
require("Tile")


--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
TileGrid = {}


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}

-- default object width and height
prototype.w = 0
prototype.h = 0

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.map(self, ...)
  args = useful.packArgs(...)
  for row = 1, self.size.y do
    for col = 1, self.size.x do
      for fi, func in ipairs(args) do
        if type(func)=="function" then -- self is an argument, but not a function
          func(self.tiles[row][col], row, col)
        end
      end
    end
  end
end

function prototype.draw(self)
  Level.get().camera:doForTiles(
    function(row, col, TG)
      TG:gridToTile(row, col) : draw(row*Tile.SIZE.x, col*Tile.SIZE.y) -- FIXME rows are y
    end,
    self
    )
end

function prototype.validGridPos(self, row, col)
  return row >= 1 
      and col >= 1
      and row <= self.size.y 
      and col <= self.size.x
      
end

function prototype.gridToTile(self, row, col)
  if self:validGridPos(row, col) then
    return self.tiles[row][col]
  else
    return Tile.DEFAULT
  end
end

function prototype.pixelToTile(self, pos)
  return self:gridToTile(math.floor(pos.y / Tile.SIZE.y) + 1,
                         math.floor(pos.x / Tile.SIZE.x) + 1)
end
  

local pixel_collision = {}
pixel_collision[Tile.EMPTY] = function(off_x, off_y) return false end
pixel_collision[Tile.TOP_LEFT] = function(off_x, off_y)
  return (off_x + off_y > 1)
end
pixel_collision[Tile.TOP_RIGHT] = function(off_x, off_y)
  return (off_x - off_y > 1)
end
pixel_collision[Tile.BOTTOM_LEFT] = function(off_x, off_y)
  return (off_x - off_y < 1)
end
pixel_collision[Tile.BOTTOM_RIGHT] = function(off_x, off_y)
  return (off_x + off_y < 1)
end
pixel_collision[Tile.FULL] = function(off_x, off_y) return true end

function prototype.pixelCollision(self, pixel_pos)
  local tile = self:pixelToTile(pixel_pos)
  if not tile then
    return true
  else
    local off_x = pixel_pos.x - useful.floor(pixel_pos.x, Tile.SIZE.x)
    local off_y = pixel_pos.y - useful.floor(pixel_pos.y, Tile.SIZE.y)
    return pixel_collision[tile.wall](off_x, off_y)
  end
end

--[[
function prototype.collision(go, x, y)
  x = x or go.pos.x
  y = y or go.pos.y
  
  local left = self:pixelCollision, 
        right = , 
        top = ,
        bottom =
  
end
--]]

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function TileGrid.new(n_cols, n_rows)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })
  
  -- create attributes
  self.size = vector(n_cols, n_rows)
  self.tiles = {}
  for row = 1, self.size.y do
    self.tiles[row] = {}
    for col = 1, self.size.x do
      self.tiles[row][col] = Tile.new(Tile.EMPTY)
    end
  end
  
  -- return the instance
  return self
end