useful = { }

-- map a set of functions to a set of objects
function useful.map(objects, ...)
  local args = useful.unpackArgs(...)
  local oi = 1
  -- for each object...
  while oi <= #objects do
    local obj = objects[oi]
    -- check if the object needs to be removed
    if obj.purge then
      table.remove(objects, oi)
    else
      -- for each function...
      for fi, func in ipairs(args) do
        -- map function to object
        if type(func)=="function" then -- Make sure it's a function, because, the 1st arguement is an object
          func(obj, oi, objects)
        end
      end -- for fi, func in ipairs(arg)
      -- next object
      oi = oi + 1
    end -- if obj.purge
  end -- while oi <= #objects
end -- useful.map(objects, functions)


-- Because Love2D implementation of args is different?
function useful.unpackArgs(a, ...)
  if a then
    local ret = useful.unpackArgs(...)
    table.insert(ret,1,a)
    return ret
  else
    return {}
  end
end