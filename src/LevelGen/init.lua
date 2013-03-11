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
	LevelGen.dirty(lev,0.45,Tile.FULL,Tile.EMPTY)
	for i=1,10 do
		LevelGen.blobify(lev)
	end
	
	return lev
end



function LevelGen.new(method)
	local lev = LevelGen.generator[method or LevelGen.DEFAULT]()
	return lev
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
			if (u.wall==Tile.FULL and LevelGen.count(lev,i,j)>=4) or (u.wall==Tile.EMPTY and LevelGen.count(lev,i,j)<3) then
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