require("TileGrid")
vector = require("vector")

local LevelGen = {}


function LevelGen.new(n_cols, n_rows)
	local lev = TileGrid.new(n_cols, n_rows)
	for row, v in ipairs(lev.tiles) do
		for col, u in ipairs(v) do
			lev:gridToTile(row, col).wall=math.random(0,5)
		end
	end
	return lev
end

return LevelGen