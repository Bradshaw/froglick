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
  animal:tryMove(direction:normalize_inplace())
  
  --! combat
  --direction.x = 0 direction.y = 0
  if love.keyboard.isDown(" ") then -- QWERTY and AZERTY compatible
    --local attack = vector(direction.x, direction.y)
    if love.keyboard.isDown("down") then
      direction = vector(0,1)
      animal:tryAttack(direction:normalize_inplace())
    else
      direction = vector(useful.tri(animal.moveIntent>0,1,-1),0)
      animal:tryAttack(direction:normalize_inplace())
    end
  else
    direction.x = 0 direction.y = 0
    animal:tryAttack(direction:normalize_inplace())
  end
  
  
end