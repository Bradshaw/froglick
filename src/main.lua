

function love.load(arg)

	log = require("unrequited/log")
	DEBUG = false

	fontim = love.graphics.newImage("images/font.png")
    fontim:setFilter("nearest","nearest")
    font = love.graphics.newImageFont("images/myfont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%_`'*__[]\"" ..
    "<>&#=$")
	--]]
	--font = love.graphics.newFont("images/DisposableDroidBB.ttf",12)
	translote = love.graphics.translate
	love.graphics.translate = function(x,y)
		translote(math.floor(x),math.floor(y))
	end
	pront = love.graphics.print
	love.graphics.print = function(txt,x,y,...)
		pront(txt,math.floor(x),math.floor(y),...)
	end
	drow = love.graphics.draw
	love.graphics.print = function(txt,x,y,...)
		pront(txt,math.floor(x),math.floor(y),...)
	end
    love.graphics.setFont(font)
	local modes = love.graphics.getModes()
	table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)
	local m = modes[#modes]
  	--local success = love.graphics.setMode( m.width, m.height, true )
  	local success = true
  
	if not success then
		print("Failed to set mode")
		love.event.push("quit")
	end
	love.graphics.setDefaultImageFilter("nearest","nearest")
	love.graphics.setLineStyle("rough",1)
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

MAX_DT = 1/60 -- global!
function love.update(dt)
  -- update
  dt = math.min(MAX_DT, dt)
  gstate.update(dt)

  -- collect garbage
  collectgarbage("collect")
end

function love.draw()
	gstate.draw()
	--love.graphics.print(love.timer.getFPS(),10,10)

	-- draw the log
	if DEBUG then
		log:draw()
	end
end
