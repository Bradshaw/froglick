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

require("AnAL")

--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
SpacemanView = {}

--FIXME should be in love.load
SpacemanView.IMAGE = love.graphics.newImage("images/charactersheet1.PNG")
SpacemanView.ANIM_UPPER_BODY = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 0, 0)
SpacemanView.ANIM_MUZZLE = newAnimation(SpacemanView.IMAGE, 96, 32, 0.1, 1, 0, 4)
SpacemanView.ANIM_UPPER_BODY_SHOOTY = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 2, 0)
SpacemanView.ANIM_WALK = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 8, 0, 1)
SpacemanView.ANIM_STOP = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 8, 4, 0)

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function SpacemanView.draw(self, go) -- GameObject
  --TODO FIXME for obvious reasons
  if math.abs(go.inertia.x)>50 and not go.airborne  then
  	SpacemanView.ANIM_WALK:draw(go.pos.x, go.pos.y - 32, 0, -go.legs_side, 1, 16, 0)
  else
  	SpacemanView.ANIM_STOP:draw(go.pos.x, go.pos.y - 32, 0, -go.legs_side, 1, 16, 0)
  end
  if go:weaponRaised() then
    
    -- attacking
  	if go:isAttacking() then
	  	SpacemanView.ANIM_UPPER_BODY_SHOOTY:draw(go.pos.x, go.pos.y - 32, 0, 
          -go.legs_side, 1, 16+math.random(-1,1), math.random(-1,1))
      SpacemanView.ANIM_MUZZLE:draw(go.pos.x, go.pos.y-19, 0, -go.legs_side, 
          useful.tri(self.muzflip,1,-1), 96+13+math.random(-1,1), 12)
    
    -- not attacking
    else
      SpacemanView.ANIM_UPPER_BODY_SHOOTY:draw(go.pos.x, go.pos.y - 32, 0, -go.legs_side, 1, 16, 0)
    end
  else
  	SpacemanView.ANIM_UPPER_BODY:draw(go.pos.x, go.pos.y - 32, 0, -go.legs_side, 1, 16, 0)
  end
  love.graphics.setColor(64,127,255)
  love.graphics.rectangle("fill",go.pos.x-8,go.pos.y-34,go.energy/100*16,2)
end

function SpacemanView.update(self, dt, go)
	SpacemanView.ANIM_WALK:update(dt)
end