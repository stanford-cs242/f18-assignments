local termfx = require "termfx"
local class = require "class.class"
local types = require "class.types"
local Entity = require "game.entity"
local Hero = require "game.hero"
local Point = require "point.point"

local Monster = class.class({Entity}, function(Class)
    function Class:constructor(...)
      Entity.constructor(self, ...)
      self._state_machine = coroutine.create(function() self:logic() end)
    end

    function Class:logic()
      local hero = self.game:hero()
      while true do
        if self:can_see(hero) then
          -- Your code here.
        else
          -- Idle
          local rand_vec = Point:new(_G.game_random:random(3) - 2, _G.game_random:random(3) - 2)
          self.game:try_move(self, rand_vec)
          coroutine.yield()
        end
      end
    end

    function Class:char() return "%" end

    function Class:color() return termfx.color.RED end

    function Class:collide(e)
      if Hero:is(e) then
        self.game:log("A monster hits you for 2 damage.")
        e:set_health(e:health() - 2)
      end
    end

    function Class:die()
      self.game:log("The monster dies.")
    end

    function Class:think()
      local status, err = coroutine.resume(self._state_machine)
      if not status then error(err) end
    end
end, {_state_machine = types.Any})

return Monster
