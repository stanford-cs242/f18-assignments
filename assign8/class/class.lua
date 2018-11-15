local types = require "class.types"

local Object
Object = {
  new = function()
    local inst = {}
    return inst
  end,

  constructor = function() end,

  isinstance = function(_, v)
    return v:type() == Object
  end,

  type = function(self) return self end,

  datatypes = {}
}

local function class(bases, methods, datatypes)
  -- TODO: fill in this function
end

return {
  Object = Object,
  class = class,
}
