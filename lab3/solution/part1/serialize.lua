-- parens("(a)((b)(c))(d)") == {"a", "(b)(c)", "d"}
local function parse_parens(s)
  local idx = 1
  local parts = {}
  while true do
    local start_idx = idx
    local ctr = 0
    repeat
      if idx > s:len() then
        return parts
      end
      if s:sub(idx, idx) == "(" then
        ctr = ctr + 1
      elseif s:sub(idx, idx) == ")" then
        ctr = ctr - 1
      end
      idx = idx + 1
    until ctr == 0
    table.insert(parts, s:sub(start_idx+1, idx-2))
  end
end

local function serialize(t)
  local ty = type(t)
  local s
  if ty == "number" then
    s = tostring(t)
  elseif ty == "string" then
    s = t
  elseif ty == "table" then
    s = ""
    for k, v in pairs(t) do
      s = s .. string.format("((%s)(%s))", serialize(k), serialize(v))
    end
  else
    return nil
  end

  return string.format("(%s)(%s)", ty, s)
end

local function deserialize(s)
  local parts = parse_parens(s)
  local ty = parts[1]
  local val = parts[2]
  if ty == "number" then
    return tonumber(val)
  elseif ty == "string" then
    return val
  elseif ty == "table" then
    local t = {}
    for _, pair in pairs(parse_parens(val)) do
      local parts = parse_parens(pair)
      local k = deserialize(parts[1])
      local v = deserialize(parts[2])
      t[k] = v
    end
    return t
  else
    print("Invalid type", ty)
    return nil
  end
end

local values = {
  0, "Hello", "foo bar", {"a", " ", "b"}, {5, 10, 20}, {x = 1, y = "yes"}, {a = {b = {c = 1}}}
}

function table.equals(t1, t2)
   for k, _ in pairs(t1) do
      local b
      if type(t1[k]) == "table" then
         b = table.equals(t1[k], t2[k])
      else
         b = t1[k] == t2[k]
      end
      if not b then return false end
   end
   return true
end

for _, value in ipairs(values) do
  local value2 = deserialize(serialize(value))
  if type(value) == "table" then assert(table.equals(value, value2))
  else assert(value == value2) end
end
