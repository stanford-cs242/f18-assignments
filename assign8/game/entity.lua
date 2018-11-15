local ROT = require 'deps/rotLove/rot'
local termfx = require "termfx"
local class = require "class.class"
local types = require "class.types"
local Point = require "point.point"
local tiles = require "game.tiles"

local id = 0

local Entity = class.class({class.Object}, function(Class)
    function Class:constructor(game, pos)
      self.game = game
      self._pos = pos
      self._id = id
      self._health = 100
      id = id + 1
      table.insert(self.game.entities, self)
    end

    function Class:id() return self._id end
    function Class:pos() return self._pos end
    function Class:set_pos(p) self._pos = p end
    function Class:char() return "*" end
    function Class:color() return termfx.color.CYAN end
    function Class:collide(_) end
    function Class:think() end
    function Class:die() end
    function Class:health() return self._health end

    function Class:set_health(h)
      self._health = h
      if h <= 0 then
        self:die()
        self.game:delete_entity(self)
      end
    end

    -- Returns a list of positions that represent the shortest path from
    -- a:pos() to b:pos(), including the endpoints.
    function Class:path_to(e)
      local src = self:pos()
      local dst = e:pos()
      local dj = ROT.Path.Dijkstra(
        dst:x(), dst:y(), function(x, y)
          return not tiles.WallTile:is(self.game.tiles[x][y])
      end)

      local path = {}
      dj:compute(
        src:x(), src:y(), function(x, y)
          table.insert(path, Point:new(x, y))
      end)
      return path
    end

    function Class:compute_lighting(intensity)
      local _, r, g, b = termfx.colorinfo(self:color())
      return termfx.rgb2color(
        math.ceil(r * intensity / 256.0 * 5.0),
        math.ceil(g * intensity / 256.0 * 5.0),
        math.ceil(b * intensity / 256.0 * 5.0))
    end

    function Class:visible_tiles()
      local src = self:pos()
      local fov = ROT.FOV.Precise:new(function(_, x, y)
          if x < 1 or x > #self.game.tiles or
            y < 1 or y > #self.game.tiles[1]
          then return false end
          return tiles.GroundTile:is(self.game.tiles[x][y])
      end)

      local visible = {}
      fov:compute(
        src:x(), src:y(), 10, function(x, y, _, _)
          table.insert(visible, Point:new(x, y))
      end)
      return visible
    end

    -- Returns true if the current entitiy can see entity e, otherwise false.
    function Class:can_see(e)
      local dst = e:pos()
      for _, p in ipairs(self:visible_tiles()) do
        if p == dst then
          return true
        end
      end
      return false
    end

    function Class:__eq(other)
      return self:id() == other:id()
    end
end, {
    game = types.Any,
    _id = types.Number,
    _health = types.Number,
    _pos = Point,
})

return Entity
