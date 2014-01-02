--[[
"Unrequited", a Löve 2D extension library
(C) Copyright 2013 William Dyce


All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

local Class = require("hump/class")

--[[------------------------------------------------------------
TILE CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local Tile = Class
{
		REGROWTH_SPEED = 0.05,

		MAX_REGROWTH_PER_SECOND = 1,

		ACID_DECAY = 0.9,

		acidity = 0,

		init = function(self, i, j, w, h)
			self.i, self.j = i, j
			self.x, self.y, self.w, self.h = (i-1)*w, (j-1)*h, w, h
			self.energy = math.random()

			self.owner = 0
			self.conversion = 0 
			self.non_mans_land = true
			self.acidView = AnimationView(Tile.ANIM_ACID, 5, 1, 0, 20)
		end
}


--[[------------------------------------------------------------
Resources
--]]

Tile.IMAGES = {}
for i = 1, 6 do
  Tile.IMAGES[i] = love.graphics.newImage("assets/tiles/tile" .. i .. ".png")
end

Tile.IMG_ACID = love.graphics.newImage("assets/acid.png")
Tile.ANIM_ACID = Animation(Tile.IMG_ACID, 64, 64, 5, 0, 0)

--[[------------------------------------------------------------
Conversion
--]]

function Tile:convert(amount, converter)

	self.no_mans_land = false

	-- convert enemy
	if self.owner ~= converter then
		amount = amount*(1 + self.conversion)
		if self.conversion < amount then
			self.conversion = (amount - self.conversion)
			self.owner = converter
		else 
			self.conversion = math.min(1, self.conversion - amount)
		end

	-- reinforce ally
	else
		self.conversion = math.min(1, self.conversion + amount*(1 - self.conversion))
	end

end

--[[------------------------------------------------------------
Game loop
--]]

local LINE_WIDTH = 3

function Tile:drawOverlay(x, y)

	x, y = x or self.x, y or self.y

	-- draw acid burn
	if self.acidity > 0 then
		love.graphics.setColor(255, 255, 255, self.acidity*255)
			self.acidView:draw(self)
		love.graphics.setColor(255, 255, 255)
	end
end

function Tile:draw(x, y, forceDrawOccupant)

	x, y = x or self.x, y or self.y

	-- draw grass on tiles
	local subimage = math.min(#Tile.IMAGES, math.floor(#Tile.IMAGES * self.energy) + 1)
	love.graphics.draw(Tile.IMAGES[subimage], x, y)

	-- draw overlay if empty
	if not self.occupant then
		self:drawOverlay(x, y)
	end

  -- draw overlord tile selection
  if self.overlord then

  	-- cache
    local speed2 = useful.sqr(self.overlord.dx+self.overlord.dy)
    local lineWidth, radius = math.min(4, 200000/speed2), math.min(24, 1000000/speed2)
    love.graphics.setLineWidth(lineWidth)

  	-- draw circle
    player[self.overlord.player].bindTeamColour()
      love.graphics.circle("line", self.x+32, self.y+32, radius)

    -- draw acid icon if bomb is ready
    if self.overlord:canBomb() then
    	local bulge = math.cos(self.overlord.wave*0.3)
    	love.graphics.draw(Plant.ICON_ACID, self.x+32, self.y+32, 0, 0.1*bulge+0.7, 0.1*bulge+0.7, 32, 32)

    -- draw cross if invalid
    elseif (not self.overlord:canLand()) then
   		love.graphics.draw(Plant.ICON_INVALID, self.x+32, self.y+32, 0, 0.5*radius/24, 0.5*radius/24, 32, 32)

   	-- draw down-arrow if egg ready
    elseif self.overlord:canPlant() then
    	local offy = math.cos(self.overlord.wave*0.3)*4
   		love.graphics.draw(Plant.ICON_DROP, self.x+32, self.y+32+offy, 0, 0.5*radius/24, 0.5*radius/24, 32, 32)
   	end
	  -- reset
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
  end

  -- force draw occupants if needed
	if forceDrawOccupant and self.occupant then
		self.occupant:draw(x + self.w/2, y + self.h/2)
	end

	if self.BURNT then
		love.graphics.print(tostring(self.acidity), self.x, self.y+16)
	end
end

function Tile:drawContours(x, y)

	x, y = x or self.x, y or self.y

	if (self.owner ~= 0) and (self.conversion > 0.1) then

		local alpha = (self.conversion*0.2)*255
		if player[self.owner].winning > 0 then
			local spike = 
				(player[self.owner].winning - math.floor(player[self.owner].winning))

			if spike < 0.5 and (math.sin(spike*2*math.pi) <= 1) then
				alpha = alpha + math.sin(spike*2*math.pi)*0.6*255
			end
		end


		love.graphics.setLineWidth(LINE_WIDTH)
		player[self.owner].bindTeamColour(alpha)
			love.graphics.rectangle("fill", x, y, self.w, self.h)
		player[self.owner].bindTeamColour()

			-- calculate offsets
			local left, right = x, x+self.w
			local top, bottom = y, y+self.h
	    if not self.leftContiguous then
	    	left = left + LINE_WIDTH
	    end
	    if not self.rightContiguous  then
	    	right = right - LINE_WIDTH
	    end
	    if not self.aboveContiguous  then
	    	top = top + LINE_WIDTH
	    end
	    if not self.belowContiguous  then
	    	bottom = bottom - LINE_WIDTH
	    end

	   	-- draw boundaries
	    if not self.leftContiguous then
	    	love.graphics.line(left, top, left, bottom)
	    end
	    if not self.rightContiguous  then
	    	love.graphics.line(right, top, right, bottom)
	    end
	    if not self.aboveContiguous  then
	    	love.graphics.line(left, top, right, top)
	    end
	    if not self.belowContiguous  then
	    	love.graphics.line(left, bottom, right, bottom)
	    end

	    -- draw boundary corners
			if self.leftContiguous and self.aboveContiguous and (not self.nwContiguous) then -- NW
				love.graphics.line(x - LINE_WIDTH, y + LINE_WIDTH, x + LINE_WIDTH, y - LINE_WIDTH)
			end
			if self.leftContiguous and self.belowContiguous and (not self.swContiguous) then -- SW
				love.graphics.line(x - LINE_WIDTH, y + self.h - LINE_WIDTH, x + LINE_WIDTH, y + self.h + LINE_WIDTH)
			end
			if self.rightContiguous and self.aboveContiguous and (not self.neContiguous) then -- NE
				love.graphics.line(x + self.w - LINE_WIDTH, y - LINE_WIDTH, x + self.w + LINE_WIDTH, y + LINE_WIDTH)
			end
			if self.rightContiguous and self.belowContiguous and (not self.seContiguous) then -- SE
				love.graphics.line(x + self.w - LINE_WIDTH, y + self.h + LINE_WIDTH, x + self.w + LINE_WIDTH, y + self.h - LINE_WIDTH)
			end


		-- reset
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 255, 255)
	end
end

function Tile:update(dt, total_energy)

	if self.acidity == 0 then

		-- regrowth
		local regrowth_speed = math.min(Tile.MAX_REGROWTH_PER_SECOND, 
			Tile.REGROWTH_SPEED/(self.energy*total_energy)*(1 + 4*self.conversion))
		self.energy = math.min(1, self.energy + dt*regrowth_speed)

		-- convert
		if self.no_mans_land then
			self.conversion = math.max(0, self.conversion - 0.5*dt)
			if self.conversion == 0 then
				self.owner = 0
			end
		end

	else

		-- acid - animate
		self.acidView.speed = 5 + 5*self.acidity
		self.acidView:update(dt)

		-- acid - unconvert
		self.conversion = math.max(0, self.conversion - dt)

		-- acid - burn grass
		self.energy = math.max(0, self.energy - self.acidity*dt)

		-- acid - decay
		self.acidity = self.acidity*math.pow(self.ACID_DECAY, dt)
		if self.acidity < 0.1 then
			self.acidity = 0
		end

	end

	-- reset
	self.no_mans_land = true
end



--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Tile