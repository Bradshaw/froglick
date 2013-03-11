require("TileGrid")
vector = require("vector")

local LevelGen = {}


LevelGen.generator = {}

function LevelGen.generator.DEFAULT(lev)

end



function LevelGen.new(n_cols, n_rows)
	local lev = TileGrid.new(n_cols, n_rows)
	LevelGen.generator.DEFAULT(lev)
	return lev
end


return LevelGen