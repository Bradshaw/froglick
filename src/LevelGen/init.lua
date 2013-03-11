require("TileGrid")
vector = require("vector")

local LevelGen = {}

LevelGen.DEFAULT = 0

local function surround(d,x,y)
	local sur = 0
	for i=-1,1 do
		for j=-1,1 do
			if i~=0 or j~=0 then
				if d[x+i][y+j]>0.8 then
					sur = sur+1
				elseif d[x+i][y+j]<0.2 then
					sur = sur - 1
				end
			end
		end
	end
	return sur
end


LevelGen.generator = {}

LevelGen.generator[LevelGen.DEFAULT] = function(lev)
	local lev = TileGrid.new(100, 100)
	local blobbiness = 3
	print(blobbiness)
	local dug = 0
	LevelGen.dirty(lev,0.35,Tile.FULL,Tile.EMPTY)
	LevelGen.blobify(lev)
	LevelGen.dirty(lev,0.3,Tile.FULL,Tile.EMPTY)
	LevelGen.dirty(lev,1,Tile.EMPTY,Tile.UNDECIDED)
	LevelGen.rectangle(lev, 45,48,55,52, Tile.FULL)
	dug = LevelGen.maze(lev, 50, 50, 1)
	print(dug)
	--LevelGen.maze(lev, 50, 51, 1)
	--LevelGen.maze(lev, 51, 50, 1)
	if blobbiness<4 then
		dug = LevelGen.maze(lev, 51, 51, 2)
	end
	print(dug)
	LevelGen.dirty(lev,1,Tile.UNDECIDED,Tile.FULL)
	for i=1,blobbiness do
		LevelGen.blobify(lev)
	end

	for i,v in ipairs(lev.tiles) do
		for j,u in ipairs(v) do
			if u.part>0 then
				u.wall = Tile.EMPTY
				u.part = 0
			end
		end
	end
	
	return lev
end

local dummy_tg = function()
  local tg = TileGrid.new(10, 10)
  for x = 1, tg.size.x do 
    for y = 1, tg.size.y do
      tg:gridToTile(x, y).wall = Tile.EMPTY;
    end
  end
  return tg
end

function LevelGen.new(method)
  --local lev = dummy_tg()
	local lev = LevelGen.generator[method or LevelGen.DEFAULT]()
  -- FIXME currently "LevelGen" returns a TileGrid, not a Level
	return lev
end

function LevelGen.rectangle(lev, x1, y1, x2, y2, wall)
	for i=x1,x2 do
		for j=y1,y2 do
			lev:set(i,j,wall)
		end
	end
end


function LevelGen.maze(lev, x, y,part)
	local dug = 0
	local unshuf = {{x=-1,y=0},{x=1,y=0},{x=0,y=-1},{x=0,y=1}}
	local shuf = {}
	while #unshuf>=1 do
		local i = math.random(1,#unshuf)
		table.insert(shuf,unshuf[i])
		table.remove(unshuf,i)
	end
	for i,v in ipairs(shuf) do
		if lev:get(x+v.x*2,y+v.y*2)==Tile.FULL then
			dug = dug + 2
			lev:set(x+v.x,y+v.y,Tile.EMPTY)
			lev:set(x+v.x*2,y+v.y*2,Tile.EMPTY)
			lev.tiles[x+v.x][y+v.y].part=part
			lev.tiles[x+v.x*2][y+v.y*2].part=part
			dug = dug + LevelGen.maze(lev,x+v.x*2,y+v.y*2,part)
		end
	end
	return dug
end

function LevelGen.count( lev, x, y )
	local cnt = 0
	for i=-1,1 do
		for j=-1,1 do
			if i~=0 or j~=0 then
				if lev:get(x,y)==lev:get(x+i,y+j) then
					cnt = cnt + 1
				end
			end
		end
	end
	return cnt
end

function LevelGen.dirty(lev, prob, mat1, mat2)
	prob = prob or 0.5
	mat1 = mat1 or Tile.FULL
	mat2 = mat2 or Tile.EMPTY
	for i,v in ipairs(lev.tiles) do
		for j,u in ipairs(v) do
			if u.wall == mat1 and math.random()<prob then
				u.wall = mat2
			end
		end
	end
end

function LevelGen.blobify(lev)
	local temp = {}
	for i,v in ipairs(lev.tiles) do
		temp[i]={}
		for j,u in ipairs(v) do

			if (u.wall==Tile.FULL and LevelGen.count(lev,i,j)>=4) or (u.wall==Tile.EMPTY and LevelGen.count(lev,i,j)<math.random(3,4)) then
				temp[i][j] = Tile.FULL
			else
				temp[i][j] = Tile.EMPTY
			end
		end
	end
	for i,v in ipairs(lev.tiles) do
		for j,u in ipairs(v) do
			u.wall = temp[i][j]
		end
	end


end

return LevelGen