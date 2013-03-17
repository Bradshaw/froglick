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

Gate = {}
GameObject_mt = require("GameObject")
vector = require("vector")

function Gate.new()
	Gate = GameObject.new()
	function Gate.update(self)
		GameObject_mt.update(self,dt)
		local dx = Gate.pos.x-Spaceman[1].pos.x
		local dy = Gate.pos.y-Spaceman[1].pos.y

    -- reset the level
		if (dx*dx+dy*dy)<30*30 then
			Level.reset()
		end
	end
	Gate.view = {draw=function(self, gat)
			love.graphics.rectangle("fill",gat.pos.x,gat.pos.y,20,20)
		end}
end