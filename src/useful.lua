useful = {}

function useful.cleanFlor(tab, fn)
	local i = 1
	while i<= #tab do
		local v = tab[i]
		if v.purge then
			table.remove(tab, i)
		else
			fn(v, i, tab)
			i = i + 1
		end
	end
end

