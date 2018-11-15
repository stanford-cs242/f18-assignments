local LuaPoint = require 'point.point'
local NativePoint = require 'point.native_point'

local function benchmark(name, func, count)
  print("===== " .. name .. " (" .. count .. " iterations) " .. " =====")

  local a, b = LuaPoint:new(64, 59), LuaPoint:new(98, 70)
  local na, nb = NativePoint:new(64, 59), NativePoint:new(98, 70)

  local clock = os.clock

  local start_lua = clock()
  for _=1, count do func(a, b, LuaPoint) end
  local lua_duration = clock() - start_lua

  local start_native = clock()
  for _=1, count do func(na, nb, NativePoint) end
  local native_duration = clock() - start_native

  print("Pure Lua:", lua_duration)
  print("Rust Extension:", native_duration)
end

benchmark('Point Creation', function(_, _, Point)
  local _ = Point:new(64, 59)
end, 500000)

benchmark('Point Property Access', function(a, b)
  local _, _ = a:x(), a:y()
  local _, _ = b:x(), b:y()
end, 500000)

benchmark('Point Arithmetic', function(a, b)
  local _ = a + b
  local _ = a - b
end, 500000)

benchmark('Point Distance', function(a, b)
  local _ = a:dist(b)
end, 500000)

benchmark('Point Equality', function(a, b)
  local _ = a == b
  local _ = a == a
  local _ = b == b
end, 500000)

benchmark('Point To String (Lua)', function(a, b)
  local _ = tostring(a)
  local _ = tostring(b)
end, 500000)
