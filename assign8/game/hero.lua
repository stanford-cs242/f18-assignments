local class = require "class.class"
local Entity = require "game.entity"

local Hero = class.class({Entity}, function(Class)
    function Class:collide(e)
      self.game:log("You hit a monster for 10 damage.")
      e:set_health(e:health() - 10)
    end

    function Class:set_health(h)
      self.game:log(string.format('Your health is now %d', h))

      Entity.set_health(self, h)
    end
end, {})

return Hero
