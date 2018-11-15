local class = require "class.class"
local types = require "class.types"
local Entity = require "game.entity"

local Light = class.class({Entity}, function(Class)
    function Class:constructor(game, pos, intensity)
      Entity.constructor(self, game, pos)
      self._intensity = intensity
    end

    function Class:intensity()
      return self._intensity
    end
end, {
    _intensity = types.Number
})

return Light
