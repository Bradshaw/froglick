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

local super = require("Animal")
require("EnemyBody")
require("EnemyWeapon")
local AnimationView = require("AnimationView")

 
--[[----------------------------------------------------------------------------
CLASS
--]]----------------------------------------------------------------------------

-- global-scoped
Enemy = {}

-- enemies attach to wall
Enemy.WALL_LEFT = 0
Enemy.WALL_RIGHT = 1
Enemy.FLOOR = 2
Enemy.ROOF = 4

-- enemy bodies / movement types
Enemy.SHROOM = 0
Enemy.ZOMBIE = 1
Enemy.SCUTTLER = 2
Enemy.FLOATER = 3

-- enemy attack types
Enemy.BITE = 0
Enemy.SPIT = 1
Enemy.SPORES = 2

Enemy.HUNTING_TIMEOUT = 6


--[[----------------------------------------------------------------------------
METATABLE (PROTOTYPE)
--]]----------------------------------------------------------------------------

local prototype = {}
setmetatable(prototype, { __index = super })

--[[----------------------------------------------------------------------------
METHODS
--]]----------------------------------------------------------------------------

function prototype.__tostring(self)
  return "Enemy(" .. self.id .. ") " .. self.hitpoints
end

--[[----------------------------------------------------------------------------
Overrides Animals
--]]--

function prototype.requestMove(self, direction)
  self.body:tryMove(direction.x)
end

function prototype.requestAttack(self, direction)
  local target_pos = self.pos + 10*direction
  if self.weapon.canAttack(self, target_pos) then
    self:__attack(target_pos)
  end
end

function prototype.__attack(self, target_pos)
  self.weapon.attack(self, target_pos)
  self.timer = self.weapon.RELOAD_TIME
end

function prototype.update(self, dt)
  -- super-class update
  super.update(self, dt)
  
  
  if self.attach == Enemy.WALL_LEFT then
    self.view.rotation = useful.RAD90
  elseif self.attach == Enemy.WALL_RIGHT then
    self.view.rotation = -useful.RAD90
  elseif self.attach == Enemy.FLOOR then
    self.view.flip_y = false
  elseif self.attach == Enemy.ROOF then
    self.view.flip_y = true
  end
  
  -- countdown timer
  if self.timer > 0 then
    self.timer = self.timer - dt
  else
    self.timer = 0
  end
  
  -- run current state method
  self:state(dt)
end

--[[----------------------------------------------------------------------------
States
--]]--

function prototype:setState(new_state)
  if new_state == prototype.IDLING then
    -- do stuff
  elseif new_state == prototype.HUNTING then
    self.timer = Enemy.HUNTING_TIMEOUT -- act as boredom timer
  elseif new_state == prototype.FIGHTING then
    self.timer = 0 -- act as reload timer
  end
  self.state = new_state
end

function prototype:IDLING(dt)
  -- do nothing if not in the camera's field of view
  if (not self.in_view) then
    return
  end
  
  -- check if player is in sight
  if self:canSee(Spaceman[1]) then
    return self:setState(prototype.HUNTING)
  end
  
  -- wander around
  self.body:wander()
end

function prototype:HUNTING(dt)
  -- bored yet?
  if self.timer < 0 then
    return self:setState(prototype.IDLING)
  end
  
  -- look for player, get bored
  if self:canSee(Spaceman[1]) then
    return self:setState(prototype.FIGHTING)
  end
end

function prototype:FIGHTING(dt)
  
  if self:canSee(Spaceman[1]) then
    -- check if attack is possible
    if self.weapon.canAttack(self, Spaceman[1].pos) then
      -- attack the player
      self:__attack(Spaceman[1].pos)
    end
  else
    return self:setState(prototype.HUNTING)
  end
end

--[[----------------------------------------------------------------------------
AI
--]]--

function prototype:canSee(who)
  return (not Level.get().tilegrid:lineCollision(self.pos.x, self.pos.y - self.h/2, 
                                                  who.pos.x, who.pos.y - who.h/2))
end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function prototype.isAttachedWall(self)
  return ((self.attach == Enemy.WALL_LEFT) or (self.attach == Enemy.WALL_RIGHT))
end

function prototype.getStateName(self)
  if self.state == prototype.IDLING then
    return "idling"
  elseif self.state == prototype.HUNTING then
    return "hunting"
  elseif self.state == prototype.FIGHTING then
    return "fighting"
  else
    return "unknown"
  end
end

--[[----------------------------------------------------------------------------
Collisions
--]]--

prototype.onObjectCollision = function(self, other)
  if ((other.type == GameObject.TYPE_SPLOSION)
      or (other.type == GameObject.TYPE_SPACEMAN_PROJECTILE))
  and (not other.has_dealt_damage) then
    self:takeDamage(other.damage)
    other.has_dealt_damage = true
  end
end

prototype.canCollideObject = function(self, other)
  return ((other.type == GameObject.TYPE_SPACEMAN_PROJECTILE) 
          or (other.type == GameObject.TYPE_SPLOSION))
end

--[[----------------------------------------------------------------------------
CLASS (STATIC) FUNCTIONS
--]]----------------------------------------------------------------------------

--[[----------------------------------------------------------------------------
Constructors
--]]

function Enemy.__new(x, y, attach)
  -- metatable
  local self = Animal.new(x, y, hitpoints)
  setmetatable(self, {__index = prototype })
  
  -- all enemies are enemies, obviously
  self.type = GameObject.TYPE_ENEMY
  
  -- attached to wall, roof or floor ?
  self.attach = attach
  
  -- BODY
  --FIXME should be determined randomly depending on spawn position
  self.body = EnemyBody.SHROOM
  self.view = AnimationView(self.body.anim_idle)
  self.hitpoints = self.body.getHitpoints()
  if self:isAttachedWall() then
    self.h, self.w = self.body.getSize()
  else
    self.w, self.h = self.body.getSize()
  end
  
  -- WEAPON
  self.weapon = EnemyWeapon.BITE
  
  -- artificial intelligence
  self.state = prototype.IDLING
  self.timer = 0
  
  return self
end

function Enemy.spawnGround(x, y)
  local spawn = Enemy.__new(x, y, Enemy.FLOOR)
  -- TODO different enemies like different positions
  return spawn
end

function Enemy.spawnWall(x, y, leftWall, rightWall)
  
  local wall = Enemy.WALL_LEFT
  if (not leftWall) 
  or (rightWall and (math.random() > 0.5)) then
    wall = Enemy.WALL_RIGHT
  end
  
  local spawn = Enemy.__new(x, y, wall)
  -- TODO different enemies like different positions
  return spawn
end

function Enemy.spawnRoof(x, y)
  local spawn = Enemy.__new(x, y, Enemy.ROOF)
  -- TODO different enemies like different positions
  return spawn
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype