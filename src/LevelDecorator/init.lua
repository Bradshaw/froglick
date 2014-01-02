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
require("Zether")

--[[----------------------------------------------------------------------------
PRIVATE CONSTANTS -- tweak me ;)
--]]----------------------------------------------------------------------------

local CLOSEST_ENEMY2 = 100*100
local CLOSEST_GATE2 = 400*400
local DEFAULT_GRASS = 0.5
local DEFAULT_ZETHER = 0.2
local DEFAULT_ENEMIES = 100

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

local popCandidateCells = function(array, f, n_popped)
  n_popped = n_popped or 1
  for i = 1, math.min(#array, n_popped) do
    local i = math.random(1, (#array))
    local cell = array[i]
    -- ... apply the callback
    f(cell)
    -- ... remove the element
    table.remove(array, i)
  end
end

local popPercentageCandidateCells = function(array, f, percentage)
  popCandidateCells(array, f, (#array)*percentage)
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
Create enemies
--]]--

local spawn = function(cell, constructor, leftWall, rightWall)
  local x, y = (cell.x + 0.5)*Tile.SIZE.x, (cell.y + 1)*Tile.SIZE.y
  if useful.dist2(x, y, Spaceman[1].pos.x, Spaceman[1].pos.y) > CLOSEST_ENEMY2 
  then
    return constructor(x, y, leftWall, rightWall)
  else
    return nil
  end
end


--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

--[[----------------------------------------------------------------------------
Main
--]]--

function LevelDecorator.decorate(lev, grass_amount, enemies_amount, zether_amount)

  -- 0. set missing parameters to default
  grass_amount = grass_amount or DEFAULT_GRASS
  enemies_amount = enemies_amount or DEFAULT_ENEMIES
  zether_amount = zether_amount or DEFAULT_ZETHER
  
  -- 1. compile a list of all the cells with walls below, above and to the sides
  local stand_cells = pushCandidateCells(lev.tilegrid, groundBelow)
  local climb_cells = pushCandidateCells(lev.tilegrid, groundSide)
  local hang_cells = pushCandidateCells(lev.tilegrid, groundAbove)
  
  -- 2. place the player character, Spaceman Joe
  Spaceman[1] = Spaceman.new(0, 0)
  
  popCandidateCells(stand_cells, function(cell)
    Spaceman[1].pos:reset((cell.x + 0.5)*Tile.SIZE.x, 
                          (cell.y + 1)*Tile.SIZE.y) end)
  
  -- 3. place the level exit
  -- if not Gate.pos then
  --   Gate.new()
  -- end
  -- Gate.pos:reset(x, y) 
  
  -- --FIXME
  -- popCandidateCells(stand_cells, function(cell)
  --   local x, y = (cell.x + 0.5)*Tile.SIZE.x, (cell.y + 1)*Tile.SIZE.y
  --   if useful.dist2(x, y, Spaceman[1].pos.x, Spaceman[1].pos.y) < CLOSEST_GATE2 
  --   then
  --     Gate.pos:reset(x, y) 
  --   else
  --     -- reject this cell, put it back at the bottom of the stack
  --     table.insert(stand_cells, cell)
  --   end
  -- end)
    
  -- 4. place enemies
  local total = enemies_amount
  
  -- keep trying to place enemies until you run out of candidates
  while math.min(enemies_amount, #stand_cells + #climb_cells + #hang_cells) > 0
  do
    -- 4a. on the roof
    popCandidateCells(hang_cells, function(cell)
      if spawn(cell, Enemy.spawnRoof) then 
        enemies_amount = enemies_amount - 1 
      end 
    end, enemies_amount / 3)

    -- 4b. on the walls
    popCandidateCells(climb_cells, function(cell)
      local leftWall = lev.tilegrid:isWall(cell.x-1, cell.y)
      local rightWall =lev.tilegrid:isWall(cell.x+1, cell.y)
      if spawn(cell, Enemy.spawnWall, leftWall, rightWall) then 
        enemies_amount = enemies_amount - 1 
      end 
    end, enemies_amount / 2)

    -- 4c. on the ground
    popCandidateCells(stand_cells, function(cell)
      if spawn(cell, Enemy.spawnGround) then enemies_amount = enemies_amount - 1 
        end end, enemies_amount)
  end
  --print("was unable to place", enemies_amount, "enemies of", total)
  lev.starting_enemies = total - enemies_amount
  lev.current_enemies = lev.starting_enemies
  
  -- 5. place zether
  popPercentageCandidateCells(stand_cells, function(cell)
    lev.tilegrid:gridToTile(cell.x, cell.y).decoration = Tile.DECORATION.GRASS
    end, grass_amount)

  -- 6. place vegetation
  stand_cells = pushCandidateCells(lev.tilegrid, groundBelow)
  popPercentageCandidateCells(stand_cells, function(cell)
    Zether.new(cell.x*32, cell.y*32)
    end, zether_amount)
end


--[[----------------------------------------------------------------------------
EXPORTS
--]]----------------------------------------------------------------------------

return LevelDecorator