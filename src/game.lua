local state = gstate.new()


function state:init()

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
end


function state:keyreleased(key, uni)
	
end


function state:update(dt)

end


function state:draw()

end

return state