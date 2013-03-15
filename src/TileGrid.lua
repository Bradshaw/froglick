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
  --[[]]
  self.spritebatch:clear()
  self.decospritebatch:clear()
  Level.get().camera:doForTiles(
    function(x, y, tilegrid)
      if tilegrid:gridToTile(x, y).decoration == Tile.DECORATION.GRASS then
        love.graphics.setBlendMode("additive")
        love.graphics.setColor(tilegrid:gridToTile(x, y).decocolour[1],
          tilegrid:gridToTile(x, y).decocolour[2],
          tilegrid:gridToTile(x, y).decocolour[3],
          80+math.sin(tilegrid:gridToTile(x, y).animation/3)*10)
        love.graphics.drawq(Tile.DECORATIONIMAGE,Tile.DECOQUADS.HIGHLIGHTS[tilegrid:gridToTile(x, y).variation%2+1],(x-0.5)*Tile.SIZE.x,(y-0.5)*Tile.SIZE.y,0,2,2,Tile.SIZE.x/2,Tile.SIZE.y/2)
          love.graphics.setColor(tilegrid:gridToTile(x, y).decocolour[1],
          tilegrid:gridToTile(x, y).decocolour[2],
          tilegrid:gridToTile(x, y).decocolour[3],
          50+math.sin(tilegrid:gridToTile(x, y).animation/3)*10)
        love.graphics.drawq(Tile.DECORATIONIMAGE,Tile.DECOQUADS.HIGHLIGHTS[(1+tilegrid:gridToTile(x, y).variation)%2+1],(x-0.5)*Tile.SIZE.x,(y-0.5)*Tile.SIZE.y,0,4,4,Tile.SIZE.x/2,Tile.SIZE.y/2)
        love.graphics.setColor(255,255,255)
        love.graphics.setBlendMode("alpha")
        tilegrid.decospritebatch:setColor(
          tilegrid:gridToTile(x, y).decocolour[1],
          tilegrid:gridToTile(x, y).decocolour[2],
          tilegrid:gridToTile(x, y).decocolour[3]
          )
        tilegrid.decospritebatch:addq(Tile.DECOQUADS.GRASS[math.floor(tilegrid:gridToTile(x, y).animation)%2+1],x*Tile.SIZE.x, y*Tile.SIZE.y)
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
  --]]
  love.graphics.setBlendMode("alpha")
  love.graphics.draw(self.decospritebatch)
  love.graphics.setBlendMode("additive")
  love.graphics.draw(self.decospritebatch)
  love.graphics.setBlendMode("alpha")
  --love.graphics.setColor(127,127,127)
  love.graphics.draw(self.spritebatch)
  --love.graphics.setColor(255,255,255)
end

function prototype.set(self, x, y, wall)
  --FIXME redundant: use tg:gridToTile(x, y).wall = value instead
  if self:validGridPos(x,y) then
    self.tiles[x][y].wall=wall
  end
end

function prototype.get(self, x, y)
  --FIXME duplicate of gridToTile
  if self:validGridPos(x,y) then
    return self.tiles[x][y].wall
  else
    return Tile.DEFAULT
  end
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

function prototype.pixelToTile(self, x, y)
  return self:gridToTile(math.floor(x / Tile.SIZE.x),
                         math.floor(y / Tile.SIZE.y))
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

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function TileGrid.new(xsize, ysize)
  -- attach metatable
  local self = {}
  setmetatable(self, {__index = prototype })


  self.spritebatch = love.graphics.newSpriteBatch( Tile.FULLIMAGE )
  self.decospritebatch = love.graphics.newSpriteBatch( Tile.DECORATIONIMAGE )
  
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