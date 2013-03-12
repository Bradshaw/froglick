local Projectile_mt = {}

local Projectile = {}

function Projectile.new( x, y, ndx, ndy, onimpact)
	local self = setmetatable({},{__index=Projectile_mt})
	self.x = x
	self.y = y
	self.oldx = x
	self.oldy = y
	self.dx = ndx*3000
	self.dy = ndy*3000
	self.onimpact = onimpact or function(self,sx,sy)
		Splosion.new(sx,sy,15,10)
	end

	table.insert(Projectile.all,self)

	return self
end

Projectile.all = {}

function Projectile.update(dt)
	useful.map(Projectile.all,function(prj)
			prj:update(dt)
		end)
end

function Projectile.draw()
	useful.map(Projectile.all,function(prj)
			prj:draw()
		end)
end


function Projectile_mt.update(self, dt)
	self.oldx = self.x
	self.oldy = self.y
	self.x = self.x+self.dx * dt
	self.y = self.y+self.dy * dt

	if Level.get().tilegrid:pixelCollision(self.x,self.y) then
		self:onimpact((self.oldx+self.x)/2,(self.oldy+self.y)/2)
		self.purge = true
	end

end

function Projectile_mt.draw(self)
	love.graphics.line(self.x,self.y,self.oldx,self.oldy)
end


return Projectile