Gate = {}
GameObject_mt = require("GameObject")
vector = require("vector")

function Gate.new()
	Gate = GameObject.new()
	function Gate.update(self)
		GameObject_mt.update(self,dt)
		local dx = Gate.pos.x-Spaceman[1].pos.x
		local dy = Gate.pos.y-Spaceman[1].pos.y

		if (dx*dx+dy*dy)<30*30 then
			Level.reset()
		end
	end
	Gate.view = {draw=function(self, gat)
			love.graphics.rectangle("fill",gat.pos.x,gat.pos.y,20,20)
		end}
end