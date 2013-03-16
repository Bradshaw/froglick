local GameObject_mt = require("GameObject")
local Sparkle = {}
local Sparkle_mt = setmetatable({},{__index=GameObject_mt})

Sparkle.FISIX = {}

Sparkle.FISIX.BOOSTER = 
{
  COLLIDES_WALLS = true,
  GRAVITY = 100,
  FRICTION = 100000000,
  CLIMB_SLOPES = false
}


function Sparkle.new(x,y,dx,dy)
	local self = GameObject.new(x,y, true) -- don't generate identifiers for sparkles!
	setmetatable(self,{__index=Sparkle_mt})
	self.view = {
		draw = function(self,target)
			love.graphics.setColor(255,255,255,255*(1-(target.age/target.dieAt)))
			love.graphics.line(target.pos.x,target.pos.y,target.pos_prev.x,target.pos_prev.y)
		end
	}
	self.layer = -1
	self.inertia.x = dx or 0
	self.inertia.y = dy or 0
	self.age = 0
	self.dieAt=1
	return self
end

function Sparkle.newBooster(...)
	local self = Sparkle.new(...)
	self.fisix = Sparkle.FISIX.BOOSTER

	return self
end

function Sparkle_mt.update( self, dt )
	GameObject_mt.update(self, dt)
	self.age = self.age + dt
	if self.age>self.dieAt then
		self.purge = true
	end
	if not self.airborne then
		self.purge = true
	end
end

function Sparkle_mt.onCollision(self)
	self.purge = true
end






return Sparkle