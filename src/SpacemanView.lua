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
SpacemanView.ANIM_SHOOT = 
{
  HORIZONTAL = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 2, 0),
  DOWN = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 5, 0),
  UP = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 6, 0),
  DIAGONAL_DOWN = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 3, 0),
  DIAGONAL_UP = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 1, 0) 
}
SpacemanView.ANIM_WALK = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 8, 0, 1)
SpacemanView.ANIM_STOP = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 8, 4, 0)
SpacemanView.ANIM_AIRBORNE = newAnimation(SpacemanView.IMAGE, 32, 32, 0.1, 1, 7, 0)

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

function SpacemanView.draw(self, sm) -- sm = Spaceman
  
  love.graphics.setColor(255, 255, 255, 255)
  
  -- LEGS
  if sm.airborne then
    SpacemanView.ANIM_AIRBORNE:draw(sm.pos.x, sm.pos.y - 32, 0, -sm.legs_side, 1, 16, 0)
  else
    if math.abs(sm.inertia.x)>50 then
      SpacemanView.ANIM_WALK:draw(sm.pos.x, sm.pos.y - 32, 0, -sm.legs_side, 1, 16, 0)
    else
      SpacemanView.ANIM_STOP:draw(sm.pos.x, sm.pos.y - 32, 0, -sm.legs_side, 1, 16, 0)
    end
  end
    
  -- ARMS
  if sm:weaponRaised() then
    
    -- check firing direction
    
    local shootAnim
    if math.abs(sm.torso_facing.x) > 0 then
      if sm.torso_facing.y > 0 then
        shootAnim = SpacemanView.ANIM_SHOOT.DIAGONAL_DOWN
      elseif sm.torso_facing.y < 0 then
        shootAnim = SpacemanView.ANIM_SHOOT.DIAGONAL_UP
      else
        shootAnim = SpacemanView.ANIM_SHOOT.HORIZONTAL
      end
    else
      if sm.torso_facing.y > 0 then
        shootAnim = SpacemanView.ANIM_SHOOT.DOWN
      else
        shootAnim = SpacemanView.ANIM_SHOOT.UP
      end
    end
    
    -- attacking
  	if sm:isAttacking() then
	  	shootAnim:draw(sm.pos.x, sm.pos.y - 32, 0, 
          -sm.legs_side, 1, 16+math.random(-1,1), math.random(-1,1))
      SpacemanView.ANIM_MUZZLE:draw(sm.pos.x, sm.pos.y-19, 0, -sm.legs_side, 
          useful.tri(self.muzflip,1,-1), 96+13+math.random(-1,1), 12)
    
    -- not attacking
    else
      shootAnim:draw(sm.pos.x, sm.pos.y - 32, 0, -sm.legs_side, 1, 16, 0)
    end
  else
  	SpacemanView.ANIM_UPPER_BODY:draw(sm.pos.x, sm.pos.y - 32, 0, -sm.legs_side, 1, 16, 0)
  end
  love.graphics.setColor(64,127,255)
  love.graphics.rectangle("fill",sm.pos.x-8,sm.pos.y-34,sm.energy/100*16,2)
  
end


function SpacemanView.update(self, dt, sm)
	SpacemanView.ANIM_WALK:update(dt)
end