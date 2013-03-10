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
  self:map(function(tile) 
    tile:draw() 
  end)
end

function prototype.validGridPos(self, grid_pos)
  return grid_pos.x >= 1 
      and grid_pos.y >= 1
      and grid_pos.x <= self.size.x
      and grid_pos.y <= self.size.y 
end

function prototype.gridToTile(self, grid_pos)
  if self:validGridPos(grid_pos) then
    return self.tiles[grid_pos.y][grid_pos.x]
  else
    return nil
  end
end

function prototype.pixelToTile(self, pixel_pos)
  local grid_pos = (pixel_pos:perdiv(Tile.SIZE)):map(math.floor) 
                      + vector(1, 1) -- lua start at 1
  return self:gridToTile(grid_pos)
end
  

local pixel_collision = {}
pixel_collision[Tile.EMPTY] = function(offset) return false end
pixel_collision[Tile.TOP_LEFT] = function(offset)
  return (offset.x + offset.y > 1)
end
pixel_collision[Tile.TOP_RIGHT] = function(offset)
  return (offset.x - offset.y > 1)
end
pixel_collision[Tile.BOTTOM_LEFT] = function(offset)
  return (offset.x - offset.y < 1)
end
pixel_collision[Tile.BOTTOM_RIGHT] = function(offset)
  return (offset.x + offset.y < 1)
end
pixel_collision[Tile.FULL] = function(offset) return true end

function prototype.pixelCollision(self, pixel_pos)
  local tile = self:pixelToTile(pixel_pos)
  if not tile then
    return true
  else
    local grid_pos = (pixel_pos:perdiv(Tile.SIZE)):map(math.floor)
    local offset = pixel_pos - grid_pos:permul(Tile.SIZE) 
    return pixel_collision[tile.wall](offset)
  end
end

--[[function prototype.collision(go, x, y)
  x = x or go.pos.x
  y = y or go.pos.y
  
  local left = , 
        right = , 
        top = ,
        bottom =
  
end]]--

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
      self.tiles[row][col] = Tile.new(row, col, useful.tri(row+col<20 and row ~= 1 and col ~= 1, 0, 5))
    end
  end
  
  -- return the instance
  return self
end