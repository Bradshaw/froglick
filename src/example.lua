local Example_mt = {}

local Example = {}

function Example.new()
	local self = setmetatable({},{__index=Example_mt})


	return self
end




return Example