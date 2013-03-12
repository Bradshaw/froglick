local Splosion_mt = {}
local Splosion = {}

Splosion.all = {}

function Splosion.new(x,y,mindiam,maxdiam,pow)
	toggleDrunk = toggleDrunk+pow/100
	local self = setmetatable({},{__index=Splosion_mt})
	self.x = x
	self.y = y
	self.diam = mindiam + math.random()*(maxdiam-mindiam)
	self.pow = pow
	table.insert(Splosion.all, self)
	return self
end

function Splosion.draw()
	love.graphics.setColor(255,125,0)
	useful.map(Splosion.all,
		function(s)
			love.graphics.circle("fill",s.x,s.y,s.diam+1)
			--s.purge = true
		end)
	love.graphics.setColor(255,255,255)
	useful.map(Splosion.all,
		function(s)
			love.graphics.circle("fill",s.x,s.y,s.diam)
			if s.rec then
				s.purge = true
				if s.pow>1 then
					local div = math.random(1,s.pow-1)
					local nextup = {}
					for i=1,div-1 do
						local a = math.random()*math.pi*2
						local d = math.random()*s.diam*2

						nextup[i]={pow = math.floor(s.pow/div),
						x = math.cos(a)*d,
						y = math.sin(a)*d}
					end
					local a = math.random()*math.pi*2
						local d = math.random()*s.diam*2
					nextup[div] = {pow = s.pow%div,
					x = math.cos(a)*d,
					y = math.sin(a)*d}
					for i,v in ipairs(nextup) do
						Splosion.new(s.x+v.x,s.y+v.y,s.diam*0.8,s.diam,v.pow)
					end
				end
			else
				s.rec = true
			end
		end)
end




return Splosion