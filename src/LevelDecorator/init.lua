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

require("Gate")
require("Enemy")

--[[----------------------------------------------------------------------------
SINGLETON CLASS
--]]----------------------------------------------------------------------------

local LevelDecorator = {}


--[[----------------------------------------------------------------------------
SUBROUTINES
--]]----------------------------------------------------------------------------

--[[----------------------------------------------------------------------------
Map functions
--]]--

local pushCandidateCells = function(grid, predicate, dest)
  dest = dest or {}
  grid:map(function(t, xx, yy) 
      if predicate(grid, xx, yy) then 
        table.insert(dest, { x = xx, y = yy}) 
      end 
    end)
  return dest
end

local popCandidateCells = function(array, f, percentage)
  -- pop a single cell if no percentage is specified
  local n_popped
  if percentage then n_popped = (#array)*percentage
                else n_popped = 1 end
  
  for i = 1, n_popped do
    local i = math.random(1, (#array))
    local cell = array[i]
    -- ... apply the callback
    f(cell)
    -- ... remove the element
    table.remove(array, i)
  end
end


--[[----------------------------------------------------------------------------
Obstacle checks
--]]--

local groundBelow = function(grid, x, y)
  return (grid:isWall(x, y, Tile.EMPTY) and grid:isWall(x, y+1))
end

local groundSide = function(grid, x, y)
  return (grid:isWall(x, y, Tile.EMPTY) and (not groundBelow(grid, x, y))
    and (grid:isWall(x-1, y) or grid:isWall(x+1, y)))
end

local groundAbove = function(grid, x, y)
  return (grid:isWall(x, y, Tile.EMPTY) and (not groundBelow(grid, x, y))
    and (not groundSide(grid, x, y)) and grid:isWall(x, y-1))
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

--[[----------------------------------------------------------------------------
Main
--]]--

local DEFAULT_GRASS = 0.5

local DEFAULT_ENEMIES = 0.3

function LevelDecorator.decorate(lev, grass_amount)

  -- 0. set missing parameters to default
  grass_amount = grass_amount or DEFAULT_GRASS
  enemies_amount = grass_amount or DEFAULT_ENEMIES
  
  -- 1. compile a list of all the cells with walls below, above and to the sides
  local stand_cells = pushCandidateCells(lev.tilegrid, groundBelow)
  local climb_cells = pushCandidateCells(lev.tilegrid, groundSide)
  local hang_cells = pushCandidateCells(lev.tilegrid, groundAbove)
  
  -- 2. place the player character, Spaceman Joe
  if not Spaceman[1] then
    Spaceman.new(0, 0)
  end
  popCandidateCells(stand_cells, function(cell)
    Spaceman[1].pos:reset((cell.x + 0.5)*Tile.SIZE.x, 
                          (cell.y + 1)*Tile.SIZE.y) end)
  
  -- 3. place the level exit
  if not Gate.pos then
    Gate.new()
  end
  popCandidateCells(stand_cells, function(cell)
    Gate.pos:reset((cell.x + 0.5)*Tile.SIZE.x, 
                    (cell.y + 1)*Tile.SIZE.y) end)
    
  -- 4. place enemies
  popCandidateCells(stand_cells, function(cell)
    Enemy.spawnGround((cell.x + 0.5)*Tile.SIZE.x, (cell.y + 1)*Tile.SIZE.y)
    end, grass_amount)
  popCandidateCells(climb_cells, function(cell)
    Enemy.spawnWall((cell.x + 0.5)*Tile.SIZE.x, (cell.y + 1)*Tile.SIZE.y)
    end, grass_amount)
  popCandidateCells(hang_cells, function(cell)
    Enemy.spawnRoof((cell.x + 0.5)*Tile.SIZE.x, (cell.y + 1)*Tile.SIZE.y)
    end, grass_amount)

  
    
  -- 5. place vegetation
  stand_cells = pushCandidateCells(lev.tilegrid, groundBelow)
  popCandidateCells(stand_cells, function(cell)
    lev.tilegrid:gridToTile(cell.x, cell.y).decoration = Tile.DECORATION.GRASS
    end, grass_amount)
end


--[[----------------------------------------------------------------------------
EXPORTS
--]]----------------------------------------------------------------------------

return LevelDecorator