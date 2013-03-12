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

require("useful")
require("Spaceman")
require("TileGrid")
LevelGen = require("LevelGen")
Camera = require("Camera")
Projectile = require("Projectile")


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}


--[[----------------------------------------------------------------------------
CLASS METHODS
--]]----------------------------------------------------------------------------

function prototype.update(self, dt)
  Projectile.update(dt)
  local previous = nil
  useful.map(self.game_objects, 
      
      -- update and control game objects
      function(object)
        --! control FIRST always
        object:control()
        object:update(dt)
      end,
          
      -- sort objects by layer
      function(object, object_index)
        if previous and previous.layer < object.layer then
          self.game_objects[object_index] = previous
          self.game_objects[object_index - 1] = object
        end 
        previous = object
      end
          )
  
  -- camera follows player 1      
  self.camera:pointAt(Spaceman[1])
end
  
function prototype.draw(self)
  
  love.graphics.push()
    --Indent to show graphics stack level
    local camx, camy = self.camera:getBounds()
    love.graphics.translate(-camx, -camy)

    -- draw the background
    -- TODO
    
    -- draw the terrain
    self.tilegrid:draw()
    
    -- draw game objects (characters, particles, etc)
    useful.map(self.game_objects, 
        function(object) 
          object:draw() 
        end)

    Projectile.draw()

    --unindent to show graphics stack level
  love.graphics.pop()
end

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Level = {}


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

--! this is a 'singleton': we should only have one in memory at a time
function Level.__new()
  -- set up metatable
  local self = {}
  setmetatable(self, {__index = prototype })
  
  -- create game object holder
  self.game_objects = {}
  
  -- create the player character if one doesn't exist
  if not Spaceman[1] then
    --Spaceman.new(100, 100)
    Spaceman.new(50*Tile.SIZE.x+10, 50*Tile.SIZE.y+10)
  end
  table.insert(self.game_objects, Spaceman[1])
  
  -- create tile holder
  self.tilegrid = LevelGen.new()
  --self.tilegrid = TileGrid.new(20, 20) -- 20 by 20 tiles

  -- create a camera to point at interest
  self.camera = Camera.new(Spaceman[1].pos.x, Spaceman[1].pos.y)
  
  -- export new instance
  return self
end

function Level.get()
  -- create new Level if one does not already exist
  if not Level.instance then
    Level.instance = Level.__new()
  end
  return Level.instance
end


--[[----------------------------------------------------------------------------
EXPORT THE CLASS
--]]----------------------------------------------------------------------------

return prototype