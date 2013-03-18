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
require("EnemyBody")

 
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
  self.body:tryMove(direction)
end

function prototype.requestAttack(self, direction)
  local target_pos = self.pos + 10*direction
  if self.weapon:canAttack(target_pos) then
    self.weapon:tryAttack(target_pos)
  end
end

function prototype.update(self, dt)
  -- super-class update
  super.update(self, dt)
  
  -- run current state method
  self:state()
end

--[[----------------------------------------------------------------------------
States
--]]--

function prototype:IDLING()
  -- do nothing if not in the camera's field of view
  if (not self.in_view) then
    return
  end
  
  -- check if player is in sight
  if self:canSee(Spaceman[1]) then
    self.state = prototype.HUNTING
  end
  
  -- wander around
  self.body:wander()
end

function prototype:HUNTING()
end

function prototype:FIGHTING()
  -- check if attack is possible
  if self.weapon:canAttack(Spaceman[1]) then
    -- attack the player
    self.weapon:attackTarget()
  else
    self.state = protoype.HUNTING
  end
end

--[[----------------------------------------------------------------------------
AI
--]]--

function prototype:canSee(who)
  return (not Level.get().tilegrid:lineCollision(self.pos.x, self.pos.y, 
                                                  who.pos.x, who.pos.y))
end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function prototype.isAttachedWall(self)
  return ((self.attach == Enemy.WALL_LEFT) or (self.attach == Enemy.WALL_RIGHT))
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

function Enemy.__new(x, y, hitpoints)
  -- metatable
  local self = Animal.new(x, y, hitpoints)
  setmetatable(self, {__index = prototype })
  
  -- all enemies are enemies, obviously
  self.type = GameObject.TYPE_ENEMY
  
  -- body
  --FIXME should be determined randomly depending on spawn position
  self.body = EnemyBody.SHROOM
  self.view = self.body
  self.hitpoints = self.body.getHitpoints()
  self.w, self.h = self.body.getSize()
  
  
  -- artificial intelligence
  self.state = prototype.IDLING
  
  return self
end

function Enemy.spawnGround(x, y)
  local spawn = Enemy.__new(x, y)
  spawn.attach = Enemy.FLOOR
  -- TODO different enemies like different positions
  return spawn
end

function Enemy.spawnWall(x, y)
  local spawn = Enemy.__new(x, y)
  spawn.attach = Enemy.WALL_LEFT -- FIXME
  -- TODO different enemies like different positions
  return spawn
end

function Enemy.spawnRoof(x, y)
  local spawn = Enemy.__new(x, y)
  spawn.attach = Enemy.ROOF
  -- TODO different enemies like different positions
  return spawn
end


--[[----------------------------------------------------------------------------
EXPORT THE METATABLE
--]]----------------------------------------------------------------------------

return prototype