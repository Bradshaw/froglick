require("TileGrid")
vector = require("vector")

local LevelGen = {}


function LevelGen.new(n_cols, n_rows)
	local lev = TileGrid.new(n_cols, n_rows)
	for i,v in ipairs(lev.tiles) do
		for j,u in ipairs(v) do
			lev:gridToTile(vector(i,j)).wall=math.random(0,5)
		end
	end
	return lev
end

return LevelGen