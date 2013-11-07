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
RESOURCES
--]]----------------------------------------------------------------------------

local VIGNETTE = love.graphics.newImage("images/vignette.png")
local BLOOD = love.graphics.newImage("images/blood_overlay.png")

--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = { }


--[[----------------------------------------------------------------------------
CLASS METHODS
--]]----------------------------------------------------------------------------

local check_collisions, check_collisions_period = 0, 10
function prototype.update(self, dt)
  
  -- animate tiles
  --! FIXME only animate those in the view
  for i,v in ipairs(self.tilegrid.tiles) do
    for j,u in ipairs(v) do
      u.animation = u.animation+dt*u.animspeed
    end   
  end 

  -- 'previous', for sorting layer
  local previous = nil
  -- update game objects
  useful.map(self.game_objects, 
      
      -- generate inter-object collisions
      function(a, a_index)
        if a.canCollideObject then
          for b_index = 1, #self.game_objects do
            local b = self.game_objects[b_index]
            if GameObject.can_collide(a, b) and GameObject.collision(a, b) then
                a:onObjectCollision(b)
                b:onObjectCollision(a)
            end
          end
        end
      end,
      
      -- update and control game objects
      function(object)
        --! control FIRST always
        object:control()
        object:update(dt)
      end,
          
      -- sort objects by layer
      function(object, object_index)
        if previous and previous.layer > object.layer then
          self.game_objects[object_index] = previous
          self.game_objects[object_index - 1] = object
        end 
        previous = object
      end
  ) -- end useful.map
  
  
  -- add new objects at the end of the update
  for k, v in pairs(self.__deferred_add) do
    table.insert(self.game_objects, 1, v)
  end
  self.__deferred_add = {}
  
  -- camera follows player 1      
  self.camera:pointAt(Spaceman[1].pos.x, Spaceman[1].pos.y-16)
end

function prototype.addObject(self, object)
  -- inserting at the beginning of the table during an update is a BAD idea
  table.insert(self.__deferred_add, object)
end
  
function prototype.draw(self)
  
  local camx, camy = self.camera:getBounds()

  -- Indent to show graphics stack level
  love.graphics.push()
    -- take camera into account
    love.graphics.translate(-camx, -camy)
    
    -- draw the terrain
    self.tilegrid:draw()
    
    -- draw game objects (characters, particles, etc) that should be drawn behind vignette
    useful.map(self.game_objects, 
        function(object) 
          if not object.inFrontOfVignette then 
            object:draw() 
          end
        end)

  -- unindent to show graphics stack level
  love.graphics.pop()


  -- draw vignette
  love.graphics.setColor(0, 0, 0, ((1 - Spaceman[1].energy/100)*0.8 + 0.2)*255)
    local scalex, scaley = love.graphics.getWidth()/VIGNETTE:getWidth(), love.graphics.getHeight()/VIGNETTE:getHeight()
    love.graphics.draw(VIGNETTE, 0, 0, 0, scalex, scaley)
  love.graphics.setColor(255, 255, 255)

  -- Indent to show graphics stack level
  love.graphics.push()
    -- take camera into account
      love.graphics.translate(-camx, -camy)

    -- draw game objects (characters, particles, etc) that should be drawn behind vignette
    useful.map(self.game_objects, 
        function(object) 
          if object.inFrontOfVignette or (object.type == GameObject.TYPE_SPACEMAN_PROJECTILE) then 
            object:draw() 
          end
        end)
  -- unindent to show graphics stack level
  love.graphics.pop()


  -- draw blood overlay
  love.graphics.setColor(255, 0, 0, (100-Spaceman[1].hitpoints)/100*255)
    scalex, scaley = love.graphics.getWidth()/BLOOD:getWidth(), love.graphics.getHeight()/BLOOD:getHeight()
    love.graphics.draw(BLOOD, 0, 0, 0, scalex, scaley)
  love.graphics.setColor(255, 255, 255)
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
  self.__deferred_add = {}
  
  -- create tile holder
  self.tilegrid = LevelGen.new()

  -- create a camera to point at interest
  self.camera = Camera.new(0, 0)
  
  -- export new __instance
  return self
end

function Level.get()
  -- create new Level if one does not already exist
  if not Level.__instance then
    -- create FIRST...
    Level.__instance = Level.__new()
    -- ...decorate AFTER creation
    LevelDecorator.decorate(Level.__instance)
  end
  return Level.__instance
end

function Level.reset()
  Level.__instance = nil
  --table.insert(Level.get().game_objects, Spaceman[1])
end

    
--[[----------------------------------------------------------------------------
EXPORT THE CLASS
--]]----------------------------------------------------------------------------

return prototype