local Splosion_mt = {}
local Splosion = {}

Splosion.all = {}

function Splosion.new(x,y,diam,pow)
	local self = setmetatable({},{__index=Splosion_mt})
	self.x = x
	self.y = y
	self.diam = diam
	self.pow = pow
	table.insert(Splosion.all, self)
	if pow>1 then
		local div = math.random(1,pow-1)
		local nextup = {}
		for i=1,div-1 do
			local a = math.random()*math.pi*2
			local d = math.random()*diam

			nextup[i]={pow = math.floor(pow/div),
			x = math.cos(a)*d,
			y = math.sin(a)*d}
		end
		local a = math.random()*math.pi*2
		local d = math.random()*diam
		nextup[div] = {pow = pow%div,
		x = math.cos(a)*d,
		y = math.sin(a)*d}
		for i,v in ipairs(nextup) do
			--print("recur")
			Splosion.new(self.x+v.x,self.y+v.y,diam*0.8,v.pow)
		end
	end
	return self
end

function Splosion.update(dt)
	useful.map(Splosion.all,
		function(s)
			s.diam = s.diam-dt*250
		end)
end

function Splosion.draw()
	love.graphics.setColor(255,180,0)
	useful.map(Splosion.all,
		function(s)
			love.graphics.circle("fill",s.x,s.y,(s.diam)+2)
			--s.purge = true
		end)
	love.graphics.setColor(255,255,255)
	useful.map(Splosion.all,
		function(s)
			love.graphics.circle("fill",s.x,s.y,s.diam)
			if s.diam<2 then
				s.purge = true
			end
		end)
end




return Splosion