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
    function(i,j,TG)
      TG:get(i,j):draw()
    end,
    self
    )
  --[[]
  self:map(function(tile) 
    tile:draw() 
  end)
  --]]
end

function prototype.get(self, row, col)
  -- If row, col is inside
  if col>0 and col<self.size.x+1 and row>0 and row<self.size.y+1 then
    return self.tiles[row][col]  -- Return the tile
  else
    return Tile.new(row, col, Tile.FULL) -- Return a new FULL tile (outside map is rock)
  end
end

function prototype.set(self, col, row, wall)
  if col>0 and col<self.size.x+1 and row>0 and row<self.size.y+1 then
    self.tiles[row][col]:set(wall)
  end
end

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
      self.tiles[row][col] = Tile.new(row, col, Tile.EMPTY)
    end
  end
  
  -- return the instance
  return self
end