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
  for x = 1, self.size.x do
    for y = 1, self.size.y do
      for fi, func in ipairs(args) do
        if type(func)=="function" then -- self is an argument, but not a function
          func(self.tiles[x][y], x, y)
        end
      end
    end
  end
end

function prototype.draw(self)
  Level.get().camera:doForTiles(
    function(x, y, tilegrid)
      tilegrid : gridToTile(x, y) : draw(x*Tile.SIZE.x, y*Tile.SIZE.y)
    end,
    self
    )
end

function prototype.validGridPos(self, x, y)
  return x >= 1 
      and y >= 1
      and x <= self.size.x 
      and y <= self.size.y
      
end

function prototype.gridToTile(self, x, y)
  if self:validGridPos(x, y) then
    return self.tiles[x][y]
  else
    return Tile.DEFAULT
  end
end

function prototype.pixelToTile(self, pos)
  return self:gridToTile(math.floor(pos.x / Tile.SIZE.x),
                         math.floor(pos.y / Tile.SIZE.y))
end
  

local pixel_collision = {}
pixel_collision[Tile.EMPTY] = function(off_x, off_y) return false end
pixel_collision[Tile.TOP_LEFT] = function(off_x, off_y)
  return (off_x + off_y < 1)
end
pixel_collision[Tile.TOP_RIGHT] = function(off_x, off_y)
  return (off_x - off_y > 0)
end
pixel_collision[Tile.BOTTOM_LEFT] = function(off_x, off_y)
  return (off_x - off_y < 0)
end
pixel_collision[Tile.BOTTOM_RIGHT] = function(off_x, off_y)
  return (off_x + off_y > 1)
end
pixel_collision[Tile.FULL] = function(off_x, off_y) return true end

function prototype.pixelCollision(self, pixel_pos)
  local tile = self:pixelToTile(pixel_pos)
  if not tile then
    return true
  else
    local off_x = pixel_pos.x - useful.floor(pixel_pos.x, Tile.SIZE.x)
    local off_y = pixel_pos.y - useful.floor(pixel_pos.y, Tile.SIZE.y)
    return pixel_collision[tile.wall](off_x / Tile.SIZE.x, off_y / Tile.SIZE.y)
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

function TileGrid.new(xsize, ysize)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })
  
  -- create attributes
  self.size = vector(xsize, ysize)
  self.tiles = {}
  for x = 1, self.size.x do
    self.tiles[x] = {}
    for y = 1, self.size.y do
      self.tiles[x][y] = Tile.new(Tile.EMPTY)
    end
  end
  
  -- return the instance
  return self
end