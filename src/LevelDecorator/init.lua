local LevelDecorator = {}


function LevelDecorator.decorate(lev)
	LevelDecorator.placeJoe(lev)
	LevelDecorator.plant(lev)
	print("Calling place Things")
	LevelDecorator.placeThings(lev)
end

function LevelDecorator.plant(lev)
	local candy = {}
	for i,v in ipairs(lev.tilegrid.tiles) do
		for j,u in ipairs(v) do
			if lev.tilegrid:get(i,j)==Tile.EMPTY and lev.tilegrid:get(i,j+1)==Tile.FULL then
				table.insert(candy,{i,j})
			end
		end
	end
	for i=1,#candy/2 do
		local ind = math.random(1,#candy)
		v = candy[ind]
		--print(v[1],v[2])
		lev.tilegrid.tiles[v[1]][v[2]].decoration = Tile.DECORATION.GRASS
		table.remove(candy, ind)
	end
	for i,v in ipairs(lev.game_objects) do
		for j,u in pairs(v) do
			--print(j,u)
		end
	end
end

function LevelDecorator.placeJoe(lev)
	local candy = {}
	local i = 1
	while not candy[1] do
		i = i+1
		v = lev.tilegrid.tiles[i]
		for j,u in ipairs(v) do
			if lev.tilegrid:get(i,j)==Tile.EMPTY and lev.tilegrid:get(i,j+1)==Tile.FULL then
				table.insert(candy,{i,j})
			end
		end
	end
	local newpos = candy[math.random(1,#candy)]
	for i,v in ipairs(newpos) do
		--print(i,v)
	end
  
  if not Spaceman[1] then
    Spaceman.new(0, 0)
  end
	Spaceman[1].pos.x=(newpos[1]+0.5)*Tile.SIZE.x
	Spaceman[1].pos.y=(newpos[2]+1.0)*Tile.SIZE.y
end

function LevelDecorator.placeThings(lev)
	local candy = {}
	for i,v in ipairs(lev.tilegrid.tiles) do
		for j,u in ipairs(v) do
			if lev.tilegrid:get(i,j)==Tile.EMPTY and lev.tilegrid:get(i,j+1)==Tile.FULL then
				table.insert(candy,{i,j})
			end
		end
	end
	for i=1,#candy/4 do
		local ind = math.random(1,#candy)
		v = candy[ind]
    
    --FIXME spammy spam spam test
    local dude = GameObject.new(v[1]*Tile.SIZE.x,v[2]*Tile.SIZE.y)
    dude.w, dude.h = 30, 30
    
		table.remove(candy, ind)
	end
	for i,v in ipairs(lev.game_objects) do
		for j,u in pairs(v) do
			--print(j,u)
		end
	end
end

return LevelDecorator