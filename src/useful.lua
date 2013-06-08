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
      if obj.onPurge then
        obj:onPurge()
      end
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

-- reduce the absolute value of something
function useful.absminus(v, minus)
  if v > 0 then
    return math.max(0, v - minus)
  else
    return math.min(0, v + minus)
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

function useful.sign(x)
  if x > 0 then 
    return 1 
  elseif x < 0 then 
    return -1
  else
    return 0
  end
end

function useful.sqr(x)
  return x*x
end

-- square distance between 2 points
function useful.dist2(x1, y1, x2, y2)
  local dx, dy = x1-x2, y1-y2
  return (dx*dx + dy*dy)
end

-- Hue-Saturation-Value function o' death
function useful.hsv(H, S, V, A, div, max, ang)
  local max = max or 255
  local ang = ang or 360
  local ang6 = ang/6
  local r, g, b
  local div = div or 100
  local S = (S or div)/div
  local V = (V or div)/div
  local A = (A or div)/div * max
  local H = H%ang
  if H>=0 and H<=ang6 then
    r = 1
    g = H/ang6
    b = 0
  elseif H>ang6 and H<=2*ang6 then
    r = 1 - (H-ang6)/ang6
    g = 1
    b = 0
  elseif H>2*ang6 and H<=3*ang6 then
    r = 0
    g = 1
    b = (H-2*ang6)/ang6
  elseif H>180 and H <= 240 then
    r = 0
    g = 1- (H-3*ang6)/ang6
    b = 1
  elseif H>4*ang6 and H<= 5*ang6 then
    r = (H-4*ang6)/ang6
    g = 0
    b = 1
  else
    r = 1
    g = 0
    b = 1 - (H-5*ang6)/ang6
  end
  local top = (V*max)
  local bot = top - top*S
  local dif = top - bot
  r = bot + r*dif
  g = bot + g*dif
  b = bot + b*dif

  return r, g, b, A
end