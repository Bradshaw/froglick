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
require("Projectile")
require("Splosion")


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = { }


--[[----------------------------------------------------------------------------
CLASS METHODS
--]]----------------------------------------------------------------------------

function prototype.update(self, dt)
  local previous = nil
  for i,v in ipairs(self.tilegrid.tiles) do
    for j,u in ipairs(v) do
      u.animation = u.animation+dt*u.animspeed
    end   
  end 

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
  ) -- end useful.map
      
  --! FIXME LAYERS ARE FORCED
  table.sort(self.game_objects, function(a, b) return a.layer > b.layer end)
  
  -- camera follows player 1      
  self.camera:pointAt(Spaceman[1].pos.x, Spaceman[1].pos.y-16)
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
    --Projectile.draw()
    
    -- draw game objects (characters, particles, etc)
    useful.map(self.game_objects, 
        function(object) 
          object:draw() 
        end)

    --Splosion.draw()
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
  
  -- create tile holder
  self.tilegrid = LevelGen.new()

  -- create a camera to point at interest
  self.camera = Camera.new(0, 0)
  
  -- export new instance
  return self
end

function Level.get()
  -- create new Level if one does not already exist
  if not Level.instance then
    -- create FIRST...
    Level.instance = Level.__new()
    -- ...decorate AFTER creation
    LevelDecorator.decorate(Level.instance)
  end
  return Level.instance
end


--[[----------------------------------------------------------------------------
EXPORT THE CLASS
--]]----------------------------------------------------------------------------

return prototype