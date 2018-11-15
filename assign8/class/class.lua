local types = require "class.types"

local Object
Object = {
  new = function()
    local inst = {}
    inst.type = Object.type
    return inst
  end,

  constructor = function() end,

  is = function(class, val)
    -- TODO: fill in this function
  end,

  type = function(_) return Object end,

  datatypes = {},

  bases = {}
}

local function class(bases, methods, datatypes)
  -- TODO: fill in this function
end

return {
  Object = Object,
  class = class,
}
