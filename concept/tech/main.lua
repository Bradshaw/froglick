function love.load()
	require("armortest")
	stepsize = 5
end

function love.keypressed(key,uni)
	if (key=="escape") then
		love.event.push("quit")
	end
end


function love.draw()
	for arm=0,love.graphics.getWidth(),stepsize do
		for dmg = 0,love.graphics.getHeight(),stepsize do
			local a,h = 100,100
			armor = math.floor(arm/love.graphics.getWidth() * 100)
			damage = math.floor(dmg/love.graphics.getHeight() * 200)

			a, h = hit(damage,armor,100,    1,   1  )
			--a = math.max(0,math.min(100,a))



			local armour_lost_abs = armor - a

			local armour_lost_rel = armour_lost_abs / armor



			love.graphics.setColor(0,0,(armour_lost_rel)*255)
			love.graphics.rectangle("fill",arm,dmg,stepsize-1,stepsize-1)
		end
	end
end