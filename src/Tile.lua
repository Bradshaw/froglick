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
Tile.UNDECIDED = 6

-- TODO THIS; BETTER!
Tile.FULLIMAGE = love.graphics.newImage("images/Tile_Stone1_filled.PNG")
Tile.FULLQUADS = {}
Tile.CORNERQUADS = {}
Tile.CORNERQUADS[Tile.TOP_LEFT] = love.graphics.newQuad(64,32,32,32,128,128)
Tile.CORNERQUADS[Tile.TOP_RIGHT] = love.graphics.newQuad(96,32,32,32,128,128)
Tile.CORNERQUADS[Tile.BOTTOM_LEFT] = love.graphics.newQuad(64,0,32,32,128,128)
Tile.CORNERQUADS[Tile.BOTTOM_RIGHT] = love.graphics.newQuad(96,0,32,32,128,128)

Tile.EDGEQUADS = {}
Tile.EDGEQUADS.LEFT = {
  love.graphics.newQuad(64,64,32,32,128,128),
  love.graphics.newQuad(64,96,32,32,128,128)
}
Tile.EDGEQUADS.RIGHT = {
  love.graphics.newQuad(96,64,32,32,128,128),
  love.graphics.newQuad(96,96,32,32,128,128)
}
Tile.EDGEQUADS.TOP = {
  love.graphics.newQuad(0,64,32,32,128,128),
  love.graphics.newQuad(32,64,32,32,128,128)
}
Tile.EDGEQUADS.BOTTOM = {
  love.graphics.newQuad(0,96,32,32,128,128),
  love.graphics.newQuad(32,96,32,32,128,128)
}


table.insert(Tile.FULLQUADS,
  love.graphics.newQuad(0,0,32,32,128,128))
table.insert(Tile.FULLQUADS,
  love.graphics.newQuad(0,32,32,32,128,128))
table.insert(Tile.FULLQUADS,
  love.graphics.newQuad(32,0,32,32,128,128))
table.insert(Tile.FULLQUADS,
  love.graphics.newQuad(32,32,32,32,128,128))

Tile.DECORATIONIMAGE = love.graphics.newImage("images/enviroment.PNG")
Tile.DECOQUADS = {}
Tile.DECOQUADS.HIGHLIGHTS = {
  love.graphics.newQuad(0,0,64,64,256,256),
  love.graphics.newQuad(64,0,64,64,256,256)
}
Tile.DECOQUADS.GRASS = {
  love.graphics.newQuad(0,96,32,32,256,256),
  love.graphics.newQuad(32,96,32,32,256,256),
  love.graphics.newQuad(64,96,32,32,256,256),
  love.graphics.newQuad(94,96,32,32,256,256)
}


Tile.DECORATION = {}
Tile.DECORATION.NONE = 0
Tile.DECORATION.GRASS = 1



--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

-- inherits from nobody
local prototype = {}

-- methods
function prototype.draw(self, x, y)
  if self.wall and self.wall > 0 then
    -- switch over Tile wall types
    if self.wall == Tile.TOP_LEFT then
      love.graphics.draw(Tile.SLOPEIMAGE, x+Tile.SIZE.x, y, math.pi/2)
    elseif self.wall == Tile.TOP_RIGHT then
      love.graphics.draw(Tile.SLOPEIMAGE, x+Tile.SIZE.x, y+Tile.SIZE.y, math.pi)
    elseif self.wall == Tile.BOTTOM_LEFT then
      love.graphics.draw(Tile.SLOPEIMAGE, x, y)
    elseif self.wall == Tile.BOTTOM_RIGHT then
      love.graphics.draw(Tile.SLOPEIMAGE, x, y+Tile.SIZE.y, -math.pi/2)
    elseif self.wall == Tile.FULL then
      love.graphics.draw(Tile.FULLIMAGE, x, y)
    elseif self.wall == Tile.UNDECIDED then
      love.graphics.rectangle("fill", x, y, Tile.SIZE.x, Tile.SIZE.y)
    end
    -- end switch
  end
  if self.part > 0 then
    love.graphics.print(self.part, x + 5, y + 5)
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
  
  -- initialise attributes
  self.wall = wall
  self.decoration = Tile.DECORATION.NONE
  self.part = 0
  self.variation = math.random(10000)
  self.animation = math.random()*10
  self.animspeed = 2+math.random()*2
  local r, g, b = useful.hsv(math.random(160,200), math.random(70,100), math.random(60,80))
  self.decocolour = {r,g,b}
  
  -- return the instance
  return self
end

Tile.DEFAULT = Tile.new(Tile.FULL)


--[[----------------------------------------------------------------------------
EXPORT METATABLE
--]]----------------------------------------------------------------------------

return prototype