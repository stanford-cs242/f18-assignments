local class = require "class.class"
local types = require "class.types"

local Point = class.class({class.Object}, function(Class)
    function Class:constructor(x, y)
      self._x = x
      self._y = y
    end

    function Class:dist(p)
      return ((p:x() - self._x)^2 + (p:y() - self._y)^2)^(0.5)
    end

    function Class:x() return self._x end
    function Class:y() return self._y end
    function Class:set_x(x) self._x = x end
    function Class:set_y(y) self._y = y end

    function Class:__add(p)
        return Class:new(self:x() + p:x(), self:y() + p:y())
    end

    function Class:__sub(p)
        return Class:new(self:x() - p:x(), self:y() - p:y())
    end

    function Class:__eq(p)
      return self:x() == p:x() and self:y() == p:y()
    end

    function Class:__tostring()
      return string.format("{%d, %d}", self:x(), self:y())
    end
end, {
    _x = types.Number,
    _y = types.Number
})

if _G.NATIVE_POINT then
  local mod = require "point.native_point"
  function mod:is(_) return true end
  return mod
else
  return Point
end
