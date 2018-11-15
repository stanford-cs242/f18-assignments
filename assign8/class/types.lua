local Any = {}
function Any:is() return true end

local String = nil
local Number = nil
local Function = nil
local Boolean = nil
local Nil = nil
local List = nil
local Table = nil

return {
  Any = Any,
  String = String,
  Number = Number,
  Function = Function,
  Boolean = Boolean,
  Nil = Nil,
  List = List,
  Table = Table,
}
