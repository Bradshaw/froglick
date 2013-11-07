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

require("Level")
LevelGen = require("LevelGen")

--[[----------------------------------------------------------------------------
'GAME' GAMESTATE - state during which the game is played
--]]----------------------------------------------------------------------------

local state = gstate.new()


function state:init()
	local nextpow2 = 1
  	while nextpow2<love.graphics.getWidth() or nextpow2<love.graphics.getHeight() do
  		nextpow2 = nextpow2*2
  	end
  	nextpow2 = nextpow2
	vib = love.graphics.newCanvas(nextpow2,nextpow2)
	vib:setFilter("nearest","nearest")
	cnv = love.graphics.newCanvas(nextpow2,nextpow2)
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
	if DEBUG and key=="m" then
		Level.reset()
	end


	if Spaceman[1].hitpoints <= 0 then
		Level.reset()
	end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  -- update the game level
  Level.get():update(dt)
  
  -- 2D "shaders"
  toggleDrunk = math.max(0,toggleDrunk-dt*10)
  time = (time or 0) + dt*100
end


function state:draw()

	local w, h = love.graphics.getWidth(), love.graphics.getHeight()

	love.graphics.setCanvas(cnv)
	love.graphics.clear()
 	Level.get():draw()

 	love.graphics.setCanvas(vib)
 	love.graphics.push()
	 	love.graphics.setColor(255,255,255)
	 	love.graphics.translate(w/2+math.sin(time)*2*toggleDrunk,h/2+math.sin(time/3)*2*toggleDrunk)
	 	love.graphics.rotate((math.cos(time/3)/100)*toggleDrunk)
	 	love.graphics.translate(-w/2,-h/2)
	 	love.graphics.draw(cnv)
 	love.graphics.pop()
 	
 	love.graphics.setCanvas()
 	love.graphics.push()
	 	love.graphics.setColor(255,255,255)
	 	love.graphics.translate(-w/2,-h/2)
	 	love.graphics.scale(2,2)
	 	love.graphics.draw(vib)
		if Spaceman[1].hitpoints <= 0 then
			love.graphics.setFont(font)
			love.graphics.printf("YOU LOSE", w*0.5, h*0.5, 0, "center")
		end

		love.graphics.setFont(font)
		total_enemies, current_enemies = Level.get().starting_enemies, Level.get().current_enemies
		love.graphics.print(tostring(total_enemies - current_enemies) .. " / " .. tostring(total_enemies), w*0.7, h*0.3)

 	love.graphics.pop()
end

return state