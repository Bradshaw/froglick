require("TileGrid")
vector = require("vector")

local LevelGen = {}


function LevelGen.new(n_cols, n_rows)
	local lev = TileGrid.new(n_cols, n_rows)
	for row, v in ipairs(lev.tiles) do
		for col, u in ipairs(v) do
			lev:gridToTile(row, col).wall=math.max(0,math.min(5,math.floor((math.sin(i)+1)*1+(math.cos(j)+1)*1*2)))
		end
	end
	return lev
end

return LevelGen