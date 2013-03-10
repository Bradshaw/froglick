useful = { }

-- map a set of functions to a set of objects
function useful.map(objects, ...)
  local oi = 1
  -- for each object...
  while oi <= #objects do
    local obj = objects[oi]
    -- check if the object needs to be removed
    if obj.purge then
      table.remove(objects, oi)
    else
      -- for each function...
      for fi, func in ipairs(arg) do
        -- map function to object
        func(obj, oi, objects)
      end -- for fi, func in ipairs(arg)
      -- next object
      oi = oi + 1
    end -- if obj.purge
  end -- while oi <= #objects
end -- useful.map(objects, functions)
