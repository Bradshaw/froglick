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
  
  -- ENERGY (halo background)
  love.graphics.setColor(255, 255, 223, 32)
  love.graphics.setBlendMode("additive")
    local halo_size = (sm.energy/100)*24 + 16
      love.graphics.circle("fill", sm.pos.x + useful.signedRand(3), sm.pos.y - 16  + useful.signedRand(3), halo_size)
    local halo_size = halo_size*0.7
      love.graphics.circle("fill", sm.pos.x + useful.signedRand(3), sm.pos.y - 16  + useful.signedRand(3), halo_size)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setBlendMode("alpha")

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
    local flip_x, offset_x = -1, 0
    if sm.torso_facing.x < 0 then
      flip_x = 1 
    end
    if flip_x * sm.legs_side > 0 then
      offset_x = -4*flip_x
    end
    local flash_angle = 0
    if sm.torso_facing.x == 0 then
      if sm.torso_facing.y > 0 then
        flash_angle = useful.RAD90
      elseif sm.torso_facing.y < 0 then
        flash_angle = -useful.RAD90
      end
    else
      if sm.torso_facing.y > 0 then
        flash_angle = -useful.RAD45*flip_x
      elseif sm.torso_facing.y < 0 then
        flash_angle = useful.RAD45*flip_x
      end
    end
    
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
    
    -- weapon raised and attacking
  	if sm:isAttacking() then
	  	shootAnim:draw(sm.pos.x + offset_x, sm.pos.y - 32, 0, 
          flip_x, 1, 16+math.random(-1,1), math.random(-1,1))
      SpacemanView.ANIM_MUZZLE:draw(sm.pos.x, sm.pos.y-19, 
          flash_angle, flip_x, 
          useful.tri(self.muzflip,1,-1), 96+13+math.random(-1,1), 12)
    
    -- weapon raised but not attacking
    else
      shootAnim:draw(sm.pos.x + offset_x, sm.pos.y - 32, 0, 
                flip_x, 1, 16, 0)
    end
  else
  	SpacemanView.ANIM_UPPER_BODY:draw(sm.pos.x, sm.pos.y - 32, 
                              0, -sm.legs_side, 1, 16, 0)
  end
end


function SpacemanView.update(self, dt, sm)
	SpacemanView.ANIM_WALK:update(dt)
end