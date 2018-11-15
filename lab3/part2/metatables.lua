local function guard(t, keys)
  -- TODO
end

local t = {d = 0}
guard(t, {"a", "b"})
assert(pcall(function() t.a = 0 end))
assert(pcall(function() t.b = 0 end))
assert(not pcall(function() t.c = 0 end))
assert(pcall(function() t.d = 1 end))


local function multilink(t, parents)
  -- TODO
end

local t = {a = 0}
multilink(t, {{x = 1}, {x = 2, y = 2}, {z = 3}})
assert(t.a == 0)
assert(t.x == 1)
assert(t.y == 2)
assert(t.z == 3)
