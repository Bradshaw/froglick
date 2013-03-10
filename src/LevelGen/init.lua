require("TileGrid")

local LevelGen = {}


function LevelGen.new(n_cols, n_rows)
	return TileGrid.new(n_cols, n_rows)
end

return LevelGen