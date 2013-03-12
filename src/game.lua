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

local GameObject_mt = require("Level")


--[[----------------------------------------------------------------------------
'GAME' GAMESTATE - state during which the game is played
--]]----------------------------------------------------------------------------

local state = gstate.new()


function state:init()
	vib = love.graphics.newCanvas(1024,1024)
	vib:setFilter("nearest","nearest")
	cnv = love.graphics.newCanvas(1024,1024)
	cnv:setFilter("nearest","nearest")
	toggleDrunk = 0
end


function state:enter()

end


function state:focus()

end


function state:mousepressed(x, y, btn)

end


function state:mousereleased(x, y, btn)
	
end


function state:joystickpressed(joystick, button)
	
end


function state:joystickreleased(joystick, button)
	
end


function state:quit()
	
end


function state:keypressed(key, uni)
	if key=="escape" then
		love.event.push("quit")
	end
	--if key==" " then
	--	toggleDrunk = not toggleDrunk
	--end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  Level.get():update(dt)
  toggleDrunk = math.max(0,toggleDrunk-dt*10)
  time = (time or 0) + dt*100
end


function state:draw()
	love.graphics.setCanvas(cnv)
	love.graphics.clear()
 	Level.get():draw()

 	love.graphics.setCanvas(vib)
 	love.graphics.push()
 	love.graphics.translate(400+math.sin(time)*2*toggleDrunk,200+math.sin(time/3)*2*toggleDrunk)
 	love.graphics.rotate((math.cos(time/3)/100)*toggleDrunk)
 	love.graphics.translate(-400,-200)
 	love.graphics.draw(cnv)
 	love.graphics.pop()
 	
 	love.graphics.setCanvas()
 	love.graphics.translate(-400,-200)
 	love.graphics.scale(2,2)
 	love.graphics.draw(vib)
end

return state