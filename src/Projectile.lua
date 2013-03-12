local Projectile_mt = {}

local Projectile = {}

function Projectile.new( x, y, ndx, ndy, onimpact)
	local self = setmetatable({},{__index=Projectile_mt})
	self.x = x
	self.y = y
	self.dx = ndx*500
	self.dy = ndy*500
	self.onimpact = onimpact or function() end

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
	self.x = self.x+self.dx * dt
	self.y = self.y+self.dy * dt

	if Level.get().tilegrid:pixelCollision(self.x,self.y) then
		self:onimpact()
		self.purge = true
	end

end

function Projectile_mt.draw(self)
	love.graphics.point(self.x,self.y)
end


return Projectile