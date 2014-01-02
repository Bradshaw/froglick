--[[
"Unrequited", a Löve 2D extension library
(C) Copyright 2013 William Dyce


All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
COLLISIONGRID CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local CollisionGrid = Class
{
  init = function(self, tilew, tileh, w, h)
  
    -- grab the size of the tiles
    self.tilew, self.tileh = tilew, tileh

    -- totals
    self.total_energy = 1
  
    -- grab the size of the map
    if w and h then
      self.w, self.h = w, h
    else
      self.w = love.graphics.getWidth() / tilew
      self.h = love.graphics.getHeight() / tileh
    end

    -- create the collision map
    self.tiles = {}
    for x = 1, self.w do
      self.tiles[x] = {}
      for y = 1, self.h do
        self.tiles[x][y] = Tile(x, y, self.tilew, self.tileh)
      end
    end
  end
}

--[[----------------------------------------------------------------------------
Map functions to all or part of the grid
--]]--

function CollisionGrid:mapRectangle(startx, starty, w, h, f)
  for x = startx, startx + w - 1 do
    for y = starty, starty + h - 1 do
      if self:validGridPos(x, y) then
        f(self.tiles[x][y])
      end
    end
  end
end

--[[----------------------------------------------------------------------------
Tile neighbours
--]]--

function CollisionGrid:getNeighbours8(t, centre)
  local result = {}
  function insertIfNotNil(t, x) if x then table.insert(t, x) end end
  insertIfNotNil(result, self:gridToTile(t.i-1, t.j-1, true))  -- NW
  insertIfNotNil(result, self:gridToTile(t.i-1, t.j, true))    -- W
  insertIfNotNil(result, self:gridToTile(t.i, t.j-1, true))    -- N
  insertIfNotNil(result, self:gridToTile(t.i+1, t.j-1, true))  -- NE
  insertIfNotNil(result, self:gridToTile(t.i-1, t.j+1, true))  -- SW
  insertIfNotNil(result, self:gridToTile(t.i, t.j+1, true))    -- S
  insertIfNotNil(result, self:gridToTile(t.i+1, t.j, true))    -- E
  insertIfNotNil(result, self:gridToTile(t.i+1, t.j+1, true))  -- SE
  if centre then
    insertIfNotNil(result, self:gridToTile(t.i, t.j, true))
  end
  return result
end

function CollisionGrid:getNeighbours4(t, centre)
  local result = {}
  function insertIfNotNil(t, x) if x then table.insert(t, x) end end
  insertIfNotNil(result, self:gridToTile(t.i-1, t.j, true))    -- W
  insertIfNotNil(result, self:gridToTile(t.i, t.j-1, true))    -- N
  insertIfNotNil(result, self:gridToTile(t.i, t.j+1, true))    -- S
  insertIfNotNil(result, self:gridToTile(t.i+1, t.j, true))    -- E
  if centre then
    insertIfNotNil(result, self:gridToTile(t.i, t.j, true))
  end
  return result
end

--[[------------------------------------------------------------
Game loop
--]]--

function CollisionGrid:update(dt) 
  -- previous total energy defines growth this turn
  local new_total_energy = 0

  -- reset total conversion counter
  for i = 1, MAX_PLAYERS do 
    player[i].total_conversion = 0
  end

  -- update tiles
  for x = 1, self.w do
    for y = 1, self.h do
      local t = self.tiles[x][y]

      function allied(t1, t2)
        return ((t1.owner == t2.owner) and (t1.conversion > 0.1) and (t2.conversion > 0.1))
      end

      -- wrap around
      local left = useful.tri(x > 1, x-1, self.w)
      local right = useful.tri(x < self.w, x+1, 1)
      local above = useful.tri(y > 1, y-1, self.h)
      local below = useful.tri(y < self.h, y+1, 1)

      -- check tile neighbours for territory contour drawing
      t.leftContiguous = allied(self.tiles[left][y], t)
      t.nwContiguous = allied(self.tiles[left][above], t)
      t.swContiguous = allied(self.tiles[left][below], t)
      t.rightContiguous = allied(self.tiles[right][y], t)
      t.neContiguous = allied(self.tiles[right][above], t)
      t.seContiguous = allied(self.tiles[right][below], t)
      t.aboveContiguous = allied(self.tiles[x][above], t)
      t.belowContiguous = allied(self.tiles[x][below], t)
    
      -- update the tile
      t:update(dt, self.total_energy)

      -- add energy to total (to determine growth next turn)
      new_total_energy = new_total_energy + t.energy

      -- award the "point" to the owner if control is over 0.5
      if t.conversion > 0.5 then
        player[t.owner].total_conversion = player[t.owner].total_conversion + 1
      end
    end
  end

  -- normalise total conversion
  local total_tiles = self.w*self.h
  for i = 1, MAX_PLAYERS do 
    player[i].total_conversion = player[i].total_conversion / total_tiles
  end

  -- reset total energy
  self.total_energy = new_total_energy
end

function CollisionGrid:draw(view) 

  local start_x, end_x, start_y, end_y
  if view then
    start_x = math.max(1, math.floor(view.x / self.tilew))
    end_x = math.min(self.w, 
                start_x + math.ceil(view.w / self.tilew))
    
    start_y = math.max(1, math.floor(view.y / self.tileh))
    end_y = math.min(self.h, 
                start_y + math.ceil(view.h / self.tileh))
  else
    start_x, start_y = 1, 1
    end_x, end_y = self.w, self.h
  end


  -- draw tile backgrond images
  -- ... for each column ...
  for x = start_x, end_x do
    -- ... for each row ...
    for y = start_y, end_y do
      -- draw the 'normal' versions of the tiles (ie. not 'lapping')
      self.tiles[x][y]:draw()
    end
    -- ... copy the bottom tile at the top and vice-versa
    self.tiles[x][end_y]:draw(_, (start_y-2)*self.tileh, true)
    self.tiles[x][start_y]:draw(_, (end_y)*self.tileh, true)
  end
  -- ... for each row ...
  for y = start_y, end_y do
    -- ... copy the left tile at the right and vice-versa
    self.tiles[end_x][y]:draw((start_x-2)*self.tilew, _, true)
    self.tiles[start_x][y]:draw((end_x)*self.tilew, _, true)
  end
  -- ... draw the 4 corner tiles
  self.tiles[start_x][start_y]:draw((start_x-2)*self.tilew, (start_y-2)*self.tileh, true)
  self.tiles[start_x][end_y]:draw((start_x-2)*self.tilew, (end_y)*self.tileh, true)
  self.tiles[end_x][start_y]:draw((end_x)*self.tilew, (start_y-2)*self.tileh, true)
  self.tiles[end_x][end_y]:draw((end_x)*self.tilew, (end_y)*self.tileh, true)

  -- draw team-colour contours
  for x = start_x, end_x do
    for y = start_y, end_y do
      self.tiles[x][y]:drawContours()
    end
    self.tiles[x][end_y]:drawContours(_, (start_y-2)*self.tileh)
    self.tiles[x][start_y]:drawContours(_, (end_y)*self.tileh)
  end
  for y = start_y, end_y do
      self.tiles[end_x][y]:drawContours((start_x-2)*self.tilew, _)
      self.tiles[start_x][y]:drawContours((end_x)*self.tilew, _)
  end

end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function CollisionGrid:gridToTile(x, y, lap_around)

  if lap_around then
    while x < 1 do x = x + self.w end
    while y < 1 do y = y + self.h end
    while x > self.w do x = x - self.w end
    while y > self.h do y = y - self.h end
    return self.tiles[x][y]
  else
    if self:validGridPos(x, y) then
      return self.tiles[x][y]
    else
      return nil --FIXME return default tile
    end
  end
end

function CollisionGrid:pixelToTile(x, y)
  return self:gridToTile(math.floor(x / self.tilew) + 1,
                         math.floor(y / self.tileh) + 1)
end

function CollisionGrid:centrePixel()
  return self.w*self.tilew/2, self.h*self.tileh/2
end

--[[----------------------------------------------------------------------------
Conversion
--]]--

function CollisionGrid:pixelToGrid(x, y)
  return math.floor(x / self.tilew) + 1, math.floor(y / self.tileh) +1
end

function CollisionGrid:gridToPixel(x, y)
  return (x-1) * self.tilew, (y-1) * self.tileh
end


--[[----------------------------------------------------------------------------
Avoid array out-of-bounds exceptions
--]]--

function CollisionGrid:validGridPos(x, y)
  return (x >= 1 
      and y >= 1
      and x <= self.w 
      and y <= self.h) 
end

function CollisionGrid:validPixelPos(x, y)
  return (x >= 0
      and y >= 0
      and x <= self.size.x*self.tilew
      and y <= self.size.y*self.tileh)
end


--[[----------------------------------------------------------------------------
Basic collision tests
--]]--

function CollisionGrid:gridCollision(x, y, type)
  type = (type or Tile.TYPE.WALL)
  return (self:gridToTile(x, y).type == type)
end

function CollisionGrid:pixelCollision(x, y, object)
  local tile = self:pixelToTile(x, y)

  --[[if object:isType("Overlord") then
    return ((not tile) or (tile.overlord and (tile.overlord ~= object)))
  else--]]
    return (not tile)
  --end
end

--[[----------------------------------------------------------------------------
GameObject collision tests
--]]--

function CollisionGrid:collision(go, x, y)
  -- x & y are optional: leave them out to test the object where it actually is
  x = (x or go.x)
  y = (y or go.y)
  
  -- rectangle collision mask, origin is at the top-left
  return (self:pixelCollision(x - go.w/2,         y - go.h/2,         go) 
      or  self:pixelCollision(x + go.w/2,         y,                  go) 
      or  self:pixelCollision(x,                  y + go.h/2,         go)
      or  self:pixelCollision(x + go.w/2,         y + go.h/2,         go))
end

function CollisionGrid:collision_next(go, dt)
  return self:collision(go, go.x + go.dx*dt, go.y + go.dy*dt)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return CollisionGrid