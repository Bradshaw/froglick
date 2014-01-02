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
KeyboardController = {}


--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function KeyboardController.control(self, animal) -- Animal

  local direction
  
  --! movement
  direction = vector(0, 0)
  if love.keyboard.isDown("up") then
    direction.y = direction.y - 1
  end
  if love.keyboard.isDown("down") then
    direction.y = direction.y + 1
  end
  if love.keyboard.isDown("left") then
    direction.x = direction.x - 1
  end
  if love.keyboard.isDown("right") then
    direction.x = direction.x + 1
  end
  animal:requestMove(direction:normalize_inplace())
  
  --! combat
  direction.x = 0 direction.y = 0
  
  -- attack in the current direction ?
  if love.keyboard.isDown(" ") then
    animal:requestAttack(direction)
  -- attack in the specified direction ?
  else
    if love.keyboard.isDown("z") or love.keyboard.isDown("w") then
      direction.y = direction.y - 1
    end
    if love.keyboard.isDown("s") then
      direction.y = direction.y + 1
    end
    if love.keyboard.isDown("q") or love.keyboard.isDown("a") then
      direction.x = direction.x - 1
    end
    if love.keyboard.isDown("d") then
      direction.x = direction.x + 1
    end
    -- only attack if some direction is specified
    if direction.x ~= 0 or direction.y ~= 0 then
      animal:requestAttack(direction:normalize_inplace())
    end
  end
  
  
  
end