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

--[[----------------------------------------------------------------------------
Utility
--]]--

function prototype.map(self, ...)
  args = useful.packArgs(...)
  for x = 1, self.size.x do
    for y = 1, self.size.y do
      for fi, func in ipairs(args) do
        if type(func)=="function" then -- self is an argument, but not a function
          func(self.tiles[x][y], x, y, self)
        end
      end
    end
  end
end

--[[----------------------------------------------------------------------------
Rendering
--]]--

function prototype.batchTiles(self)
  self.spritebatch:bind()
  --self.spritebatch:clear()
  local i = 0
  for i,v in ipairs(self.tiles) do
    for j,u in ipairs(v) do
      if u.wall==Tile.FULL then
        --print(i*Tile.SIZE.x,j*Tile.SIZE.y)
        i = i+1
        self.spritebatch:add(i*Tile.SIZE.x,j*Tile.SIZE.y)
      end
    end
  end
  print(i)
  self.spritebatch:unbind()
end

function prototype.draw(self)
  --[[]]
  self.spritebatch:clear()
  self.decospritebatch:clear()
  Level.get().camera:doForTiles(
    function(x, y, tilegrid)
    
      ---FIXME DEBUG
      --love.graphics.print(tostring(x)..","..tostring(y), x*Tile.SIZE.x, (y+0.5)*Tile.SIZE.y)
      --love.graphics.print(tilegrid:gridToTile(x, y).part, (x+0.5)*Tile.SIZE.x, (y+0.5)*Tile.SIZE.y)
      --love.graphics.setColor(255, 255, 255, 255)
      --love.graphics.rectangle("line", x*Tile.SIZE.x, y*Tile.SIZE.y, 32, 32)
      --------------------------------

      if tilegrid:gridToTile(x, y).decoration == Tile.DECORATION.GRASS then
        love.graphics.setBlendMode("additive")
        love.graphics.setColor(tilegrid:gridToTile(x, y).decocolour[1],
          tilegrid:gridToTile(x, y).decocolour[2],
          tilegrid:gridToTile(x, y).decocolour[3],
          80+math.sin(tilegrid:gridToTile(x, y).animation/3)*10)
        love.graphics.draw(Tile.DECOQUADS.HIGHLIGHTS[tilegrid:gridToTile(x, y).variation%2+1],
                                         (x+0.5)*Tile.SIZE.x,(y+0.5)*Tile.SIZE.y,0,0.2,0.2,192,192)
          love.graphics.setColor(tilegrid:gridToTile(x, y).decocolour[1],
          tilegrid:gridToTile(x, y).decocolour[2],
          tilegrid:gridToTile(x, y).decocolour[3],
          50+math.sin(tilegrid:gridToTile(x, y).animation/3)*10)
        love.graphics.draw(Tile.DECOQUADS.HIGHLIGHTS[(1+tilegrid:gridToTile(x, y).variation)%2+1],
                                         (x+0.5)*Tile.SIZE.x,(y+0.5)*Tile.SIZE.y,0,0.6,0.6,192,192)
        love.graphics.setColor(255,255,255)
        love.graphics.setBlendMode("alpha")
        tilegrid.decospritebatch:setColor(
          tilegrid:gridToTile(x, y).decocolour[1],
          tilegrid:gridToTile(x, y).decocolour[2],
          tilegrid:gridToTile(x, y).decocolour[3]
          )
        tilegrid.decospritebatch:addq(Tile.DECOQUADS.GRASS[math.floor(tilegrid:gridToTile(x, y).animation)%2+1],
            x*Tile.SIZE.x, y*Tile.SIZE.y)
      end
      if tilegrid:gridToTile(x, y).wall == Tile.FULL then
        --tilegrid.spritebatch:add(x*Tile.SIZE.x, y*Tile.SIZE.y)
        tilegrid.spritebatch:addq(Tile.FULLQUADS[tilegrid:gridToTile(x, y).variation%4+1],x*Tile.SIZE.x, y*Tile.SIZE.y)
      elseif tilegrid:gridToTile(x, y).wall>=1 and tilegrid:gridToTile(x, y).wall<=4 then
        tilegrid.spritebatch:addq(
          Tile.CORNERQUADS[tilegrid:gridToTile(x, y).wall],
          x*Tile.SIZE.x,
          y*Tile.SIZE.y)
      elseif tilegrid:gridToTile(x, y).wall == Tile.EMPTY then
        if tilegrid:gridToTile(x+1, y).wall == Tile.FULL then
          tilegrid.spritebatch:addq(Tile.EDGEQUADS.RIGHT[tilegrid:gridToTile(x, y).variation%2+1],x*Tile.SIZE.x, y*Tile.SIZE.y)
        end
        if tilegrid:gridToTile(x-1, y).wall == Tile.FULL then
          tilegrid.spritebatch:addq(Tile.EDGEQUADS.LEFT[tilegrid:gridToTile(x, y).variation%2+1],x*Tile.SIZE.x, y*Tile.SIZE.y)
        end
        if tilegrid:gridToTile(x, y+1).wall == Tile.FULL then
          tilegrid.spritebatch:addq(Tile.EDGEQUADS.BOTTOM[tilegrid:gridToTile(x, y).variation%2+1],x*Tile.SIZE.x, y*Tile.SIZE.y)
        end
        if tilegrid:gridToTile(x, y-1).wall == Tile.FULL then
          tilegrid.spritebatch:addq(Tile.EDGEQUADS.TOP[tilegrid:gridToTile(x, y).variation%2+1],x*Tile.SIZE.x, y*Tile.SIZE.y)
        end

      else
        tilegrid : gridToTile(x, y) : draw(x*Tile.SIZE.x, y*Tile.SIZE.y)
      end
    end,
    self
    )
  love.graphics.setBlendMode("alpha")
  love.graphics.draw(self.decospritebatch)
  love.graphics.setBlendMode("additive")
  love.graphics.draw(self.decospritebatch)
  love.graphics.setBlendMode("alpha")
  
  --FIXME DEBUG
  --love.graphics.setColor(255, 255, 255, 200)
  ------------------------------------------------
  
  --love.graphics.setColor(127,127,127)
  love.graphics.draw(self.spritebatch)
  love.graphics.setColor(255,255,255)
end


--[[----------------------------------------------------------------------------
Avoid array out-of-bounds exceptions
--]]--


function prototype.validGridPos(self, x, y)
  return (x >= 1 
      and y >= 1
      and x <= self.size.x 
      and y <= self.size.y) 
end

function prototype.validPixelPos(self, x, y)
  return (x >= 0
      and y >= 0
      and x <= self.size.x*Tile.SIZE.x
      and y <= self.size.y*Tile.SIZE.y)
end


--[[----------------------------------------------------------------------------
Basic collision tests
--]]--

function prototype.gridCollision(self, x, y)
  local type = self:gridToTile(x, y).wall
  return ((type == Tile.FULL) 
        or (type == Tile.TOP_LEFT)
        or (type == Tile.TOP_RIGHT)
        or (type == Tile.BOTTOM_LEFT)
        or (type == Tile.BOTTOM_RIGHT))
end

function prototype.lineCollision(self, x1, y1, x2, y2, pixel_perfect)
  -- convert from pixel -> tile
  local x = math.floor(x1 / Tile.SIZE.x)
  local y = math.floor(y1 / Tile.SIZE.y)
  local endx = math.floor(x2 / Tile.SIZE.x)
  local endy = math.floor(y2 / Tile.SIZE.y)
  
  -- check that both tiles are valid
  if (not self:validGridPos(x, y)) then
    return true, TileGrid.gridToPixel(x + 0.5, y + 0.5)
  elseif (not self:validGridPos(endx + 0.5, endy + 0.5)) then
    return true, TileGrid.gridToPixel(endx + 0.5, endy + 0.5)
  end
  
  -- http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
  local dx = math.abs(endx - x)
  local dy = math.abs(endy - y)
  local sx = useful.tri(x < endx, 1, -1)
  local sy = useful.tri(y < endy, 1, -1)
  local err = dx - dy

  -- move from start (x1, y1) towards (x2, y2)
  while (x ~= endx) or (y ~= endy) do

    if self:gridCollision(x, y) then
      -- the way is shut (it was made by those who are dead)
      return true, TileGrid.gridToPixel(x + 0.5, y + 0.5)
    end
    
    -- move ...
    local err2 = 2*err;
    -- ... horizontally
    if err2 > -dy then
      err = err - dy;
      x = x + sx;
    end
    -- ... vertically
    if err2 < dx then
      err = err + dx;
      y = y + sy;
    end
    
  end -- while (x ~= endx) or (y ~= endy)

  -- made it - the way is clear, no collision!
  return false, TileGrid.gridToPixel(x + 0.5, y + 0.5)
end

function prototype.pixelCollision(self, x, y)
  local tile = self:pixelToTile(x, y)
  if not tile then
    return true
  else
    -- calculate relative (normalised) offset within Tile
    local off_x = (x - useful.floor(x, Tile.SIZE.x)) / Tile.SIZE.x 
    local off_y = (y - useful.floor(y, Tile.SIZE.y)) / Tile.SIZE.y 
    -- switch over Tile wall types
    if tile.wall == Tile.EMPTY then
      return false
    elseif tile.wall == Tile.TOP_LEFT then
      return (off_x + off_y < 1)
    elseif tile.wall == Tile.TOP_RIGHT then
      return (off_x - off_y > 0)
    elseif tile.wall == Tile.BOTTOM_LEFT then
      return (off_x - off_y < 0)
    elseif tile.wall == Tile.BOTTOM_RIGHT then
      return (off_x + off_y > 1)
    elseif tile.wall == Tile.FULL then
      return true
    end
    -- end switch
  end
end

--[[----------------------------------------------------------------------------
GameObject collision tests
--]]--

function prototype.collision(self, go, x, y)
  -- x & y are optional: leave them out to test the object where it actually is
  x = x or go.pos.x
  y = y or go.pos.y
  
  -- here we're using a diamond-shaped collision-mask
  local left = self:pixelCollision(x - go.w/2, y - go.h/2) 
  local right = self:pixelCollision(x + go.w/2, y - go.h/2) 
  local top = self:pixelCollision(x, y - go.h)
  local bottom = self:pixelCollision(x, y)
  return left or right or top or bottom
end

function prototype.collision_next(self, go, dt)
  return self:collision(go, go.pos.x + go.inertia.x*dt, go.pos.y + go.inertia.y*dt)
end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function prototype:getWall(x, y)
  return (self:gridToTile(x, y).wall)
end

function prototype:isWall(x, y, walltype)
  walltype = walltype or Tile.FULL
  return (self:gridToTile(x, y).wall == walltype)
end
    
function prototype:setWall(x, y, wall)
  self:gridToTile(x, y).wall = wall
end

function prototype.gridToTile(self, x, y)
  if self:validGridPos(x, y) then
    return self.tiles[x][y]
  else
    return Tile.DEFAULT
  end
end

function prototype.pixelToTile(self, x, y)
  return self:gridToTile(math.floor(x / Tile.SIZE.x),
                         math.floor(y / Tile.SIZE.y))
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

--[[----------------------------------------------------------------------------
Constructor
--]]--


function TileGrid.new(xsize, ysize)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })


  self.spritebatch = love.graphics.newSpriteBatch( Tile.FULLIMAGE, 2000 )
  self.decospritebatch = love.graphics.newSpriteBatch( Tile.DECORATIONIMAGE, 2000 )
  
  -- create attributes
  self.size = vector(xsize, ysize)
  self.tiles = {}
  local flal = 0
  for x = 1, self.size.x do
    self.tiles[x] = {}
    flal=flal+1
    if flal>5 then flal = 0 end
    for y = 1, self.size.y do
      self.tiles[x][y] = Tile.new(Tile.FULL)
    end
  end
  
  -- return the instance
  return self
end

--[[----------------------------------------------------------------------------
Conversion
--]]--

TileGrid.pixelToGrid = function(x, y)
  return math.floor(x / Tile.SIZE.x), math.floor(y / Tile.SIZE.y)
end

TileGrid.gridToPixel = function(x, y)
  return x * Tile.SIZE.x, y * Tile.SIZE.y
end
