local GameObject_mt = require("GameObject")
local Sparkle = {}
local Sparkle_mt = setmetatable({},{__index=GameObject_mt})

Sparkle.FISIX = {}


function Sparkle.new(x,y,dx,dy)
	local self = GameObject.new(x, y, true, 100) -- don't generate identifiers for sparkles!
	setmetatable(self,{__index=Sparkle_mt})
  
  -- type
  self.type = GameObject.TYPE_SPARKLE
  
 
	self.COLLIDES_WALLS = true
	self.inertia.x = (dx or 0)
	self.inertia.y = (dy or 0)
	self.age = 0
	self.dieAt = 1
	return self
end

Sparkle.FISIX.BOOSTER = 
{
  COLLIDES_WALLS = true,
  GRAVITY = 100,
  FRICTION = 100000000,
  CLIMB_SLOPES = true
}

function Sparkle.newBooster(...)
	local self = Sparkle.new(...)
	self.fisix = Sparkle.FISIX.BOOSTER
  	self.inFrontOfVignette = true
	self.view = 
	{
		draw = function(self,target)
			love.graphics.setBlendMode("additive")
			love.graphics.setColor(255,200,80,255*(1-(target.age/target.dieAt)))
			love.graphics.line(target.pos.x,target.pos.y,target.pos_prev.x,target.pos_prev.y)
			love.graphics.setBlendMode("alpha")
		end
	}
	return self
end

Sparkle.FISIX.BLOOD = 
{
  COLLIDES_WALLS = true,
  GRAVITY = 500,
  FRICTION = 1,
  CLIMB_SLOPES = true
}

function Sparkle.newBlood(x, y, speed)

	local a = math.random()*math.pi
	local dx, dy = math.cos(a)*speed, -math.sin(a)*speed
	local self = Sparkle.new(x, y, dx, dy)


	self.fisix = Sparkle.FISIX.BLOOD
	self.view = 
	{
		draw = function(self, target)
			love.graphics.setBlendMode("additive")
			love.graphics.setColor(32, 255, 64, 128 + 128*(1-(target.age/target.dieAt)))
			love.graphics.point(target.pos.x, target.pos.y)
			love.graphics.setBlendMode("alpha")
		end
	}
	return self
end

function Sparkle_mt.update( self, dt )
	GameObject_mt.update(self, dt)

	self.age = self.age + dt
	if self.age>self.dieAt then
		self:onDie()
		self.purge = true
	end
	if not self.airborne then
		self:onDie()
		self.purge = true
	end
end

function Sparkle_mt.onCollision(self)
	self:onDie()
	self.purge = true
end

function Sparkle_mt.onDie(self)
	--Splosion.new(self.pos.x, self.pos.y, 15, math.random(1,3))
end




return Sparkle