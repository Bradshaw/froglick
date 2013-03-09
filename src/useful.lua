useful = { }

function useful.multimap(objects, functions)
  local oi = 1
  -- for each object...
  while oi <= #objects do
    local obj = objects[oi]
    -- check if the object needs to be removed
    if obj.purge then
      table.remove(objects, oi)
    else
      -- for each function...
      while fi <= #functions do
        local fun = functions[fi]
        -- map function to object
        fun(object, oi, objects)
        -- next function
        fi = fi + 1
      end
      -- next object
      oi = oi + 1
    end -- if obj.purge
  end -- while oi <= #objects
end -- useful.map(objects, functions)

function useful.map(object, _function)
  return useful.multimap(object, { _function })
end