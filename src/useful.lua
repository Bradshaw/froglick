useful = { }

-- map a set of functions to a set of objects
function useful.map(objects, ...)
  local args = useful.packArgs(...)
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
function useful.packArgs(a, ...)
  if a then
    local ret = useful.packArgs(...)
    table.insert(ret,1,a)
    return ret
  else
    return {}
  end
end

-- trinary operator
function useful.tri(cond, a, b)
  if cond then 
    return a
  else
    return b
  end
end

-- function missing from math
function useful.round(x, n) 
  if n then
    -- round to nearest n
    return useful.round(x / n) * n
  else
    -- round to nearest integer
    local floor = math.floor(x)
    if (x - floor) > 0.5 then
      return floor
    else
      return math.ceil(x)
    end
  end
end

function useful.floor(x, n)
  if n then
    -- floor to nearest n
    return math.floor(x / n) * n
  else
    -- floor to nearest integer
    return math.floor(x)
  end
end

function useful.ceil(x, n)
  if n then
    -- ceil to nearest n
    return math.ceil(x / n) * n
  else
    -- ceil to nearest integer
    return math.ceil(x)
  end
end