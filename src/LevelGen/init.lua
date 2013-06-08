LevelDecorator = require("LevelDecorator")
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

LevelGen.generator[LevelGen.DEFAULT] = function(grid)

  local grid = TileGrid.new(5, 5)
  for i,v in ipairs(grid.tiles) do
    for j,u in ipairs(v) do
      u.wall = Tile.EMPTY
    end
  end
  return grid
  
  --[[
  local grid = TileGrid.new(100, 100)
	local blobbiness = 3
	local dug = 0
	LevelGen.dirty(grid,0.35,Tile.FULL,Tile.EMPTY)
	LevelGen.blobify(grid)
	LevelGen.dirty(grid,0.3,Tile.FULL,Tile.EMPTY)
	LevelGen.dirty(grid,1,Tile.EMPTY,Tile.UNDECIDED)
	LevelGen.rectangle(grid, 45,48,55,52, Tile.FULL)
	dug = LevelGen.maze(grid, 50, 50, 1)
	--LevelGen.maze(grid, 50, 51, 1)
	--LevelGen.maze(grid, 51, 50, 1)
	if blobbiness<4 then
		dug = LevelGen.maze(grid, 51, 51, 2)
	end
	LevelGen.dirty(grid,1,Tile.UNDECIDED,Tile.FULL)
	for i=1,3 do
		LevelGen.blobify(grid)
	end

	for i,v in ipairs(grid.tiles) do
		for j,u in ipairs(v) do
			if u.part>0 then
				u.wall = Tile.EMPTY
				u.part = 34
			end
		end
	end
	LevelGen.slopify(grid)
	LevelGen.unspikeify(grid)
	LevelGen.setPartsToDist(grid)
	return grid --]]
end


function LevelGen.setPartsToDist(grid)
	for i,v in ipairs(grid.tiles) do
		for j,u in ipairs(v) do
			u.distance = 10
		end
	end
	local changed = true
	while changed do
		changed = false
		for i,v in ipairs(grid.tiles) do
			for j,u in ipairs(v) do
				if u.wall == Tile.FULL and u.distance~= 0 then
					u.distance = 0
					--print("Got an unset tile")
					changed = true
				else
					local min = math.huge
					for x=-1,1 do
						for y=-1,1 do
							if (x~=0 or y~=0) and grid.tiles[i+x] and grid.tiles[i+x][j+y] then
								min = math.min(grid.tiles[i+x][j+y].distance,min)
							end
						end
					end
					if u.distance> min+1 then
						u.distance = min+1
						--print("Got a tile with a high distance value")
						changed = true
					end
				end
			end
		end
	end
end

function LevelGen.new(method)
  --local grid = dummy_tg()
	local grid = LevelGen.generator[method or LevelGen.DEFAULT]()
  -- FIXME currently "LevelGen" returns a TileGrid, not a Level
  grid:batchTiles()
	return grid
end


function LevelGen.generate(lvl)
  lvl.tilegrid = LevelGen.new()
end

function LevelGen.rectangle(grid, x1, y1, x2, y2, wall)
	for i=x1,x2 do
		for j=y1,y2 do
			grid:setWall(i,j,wall)
		end
	end
end

function LevelGen.slopify(grid)
	local temp = {}
	for i,v in ipairs(grid.tiles) do
		temp[i]={}
		for j,u in ipairs(v) do
			temp[i][j]=u.wall==Tile.FULL
		end
	end
	for i = 2,#temp-1 do
		local v = grid.tiles[i]
		for j=2,#temp[i]-1 do
			local u=v[j]
			if temp[i][j] then
				if (temp[i-1][j]) and (temp[i][j-1]) and (not temp[i+1][j]) and (not temp[i][j+1]) then
					u.wall = Tile.TOP_LEFT
				elseif (not temp[i-1][j]) and (temp[i][j-1]) and (temp[i+1][j]) and (not temp[i][j+1]) then
					u.wall = Tile.TOP_RIGHT
				elseif (not temp[i-1][j]) and (not temp[i][j-1]) and (temp[i+1][j]) and (temp[i][j+1]) then
					u.wall = Tile.BOTTOM_RIGHT
				elseif (temp[i-1][j]) and (not temp[i][j-1]) and (not temp[i+1][j]) and (temp[i][j+1]) then
					u.wall = Tile.BOTTOM_LEFT
				end
			end
		end
	end
end

function LevelGen.unspikeify(grid)
	for i,v in ipairs(grid.tiles) do
		for j,u in ipairs(v) do
			if u.wall == Tile.BOTTOM_RIGHT and grid.tiles[i+1][j].wall==Tile.BOTTOM_LEFT then
				if j<#v then
					u.wall = Tile.FULL
					grid.tiles[i+1][j].wall=Tile.FULL
				end
			end
		end
	end
end

function LevelGen.maze(grid, x, y,part)
	local dug = 0
	local unshuf = {{x=-1,y=0},{x=1,y=0},{x=0,y=-1},{x=0,y=1}}
	local shuf = {}
	while #unshuf>=1 do
		local i = math.random(1,#unshuf)
		table.insert(shuf,unshuf[i])
		table.remove(unshuf,i)
	end
	for i,v in ipairs(shuf) do
		if grid:isWall(x+v.x*2,y+v.y*2) and grid:validGridPos(x+v.x*2,y+v.y*2) then
			dug = dug + 2
			grid:setWall(x+v.x,y+v.y,Tile.EMPTY)
			grid:setWall(x+v.x*2,y+v.y*2,Tile.EMPTY)
			grid.tiles[x + v.x][y + v.y].part = part
			grid.tiles[x + v.x*2][y + v.y*2].part = part
			dug = dug + LevelGen.maze(grid,x+v.x*2,y+v.y*2,part)
		end
	end
	return dug
end

function LevelGen.count( grid, x, y )
	local cnt = 0
	for i=-1,1 do
		for j=-1,1 do
			if i~=0 or j~=0 then
				if grid:getWall(x, y) == grid:getWall(x+i, y+j) then
					cnt = cnt + 1
				end
			end
		end
	end
	return cnt
end

function LevelGen.dirty(grid, prob, mat1, mat2)
	prob = prob or 0.5
	mat1 = mat1 or Tile.FULL
	mat2 = mat2 or Tile.EMPTY
	for i,v in ipairs(grid.tiles) do
		for j,u in ipairs(v) do
			if u.wall == mat1 and math.random()<prob then
				u.wall = mat2
			end
		end
	end
end

function LevelGen.blobify(grid)
	local temp = {}
	for i,v in ipairs(grid.tiles) do
		temp[i]={}
		for j,u in ipairs(v) do

			if (u.wall==Tile.FULL and LevelGen.count(grid,i,j)>=4) or (u.wall==Tile.EMPTY and LevelGen.count(grid,i,j)<math.random(3,4)) then
				temp[i][j] = Tile.FULL
			else
				temp[i][j] = Tile.EMPTY
			end
		end
	end
	for i,v in ipairs(grid.tiles) do
		for j,u in ipairs(v) do
			u.wall = temp[i][j]
		end
	end


end

return LevelGen