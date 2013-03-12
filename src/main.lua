function love.load(arg)
	love.graphics.setDefaultImageFilter("nearest","nearest")
	gstate = require "gamestate"
	game = require("game")
	gstate.switch(game)
end


function love.focus(f)
	gstate.focus(f)
end

function love.mousepressed(x, y, btn)
	gstate.mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
	gstate.mousereleased(x, y, btn)
end

function love.joystickpressed(joystick, button)
	gstate.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	gstate.joystickreleased(joystick, button)
end

function love.quit()
	gstate.quit()
end

function love.keypressed(key, uni)
	gstate.keypressed(key, uni)
end

function keyreleased(key, uni)
	gstate.keyreleased(key)
end

local MAX_DT = 1/60
function love.update(dt)
  dt = math.min(MAX_DT, dt)
	gstate.update(dt)
end

function love.draw()
	gstate.draw()
end
