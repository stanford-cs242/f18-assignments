-- luacheck: std max+busted
require 'busted.runner'()

local ROT = require 'deps/rotLove/rot'
local termfx = require "termfx"
require "deps.randomlua"

local function map(func, array)
  local new_array = {}
  for i, v in ipairs(array) do new_array[i] = func(v) end
  return new_array
end

local keys = {
  left = termfx.key.ARROW_LEFT,
  right = termfx.key.ARROW_RIGHT,
  up = termfx.key.ARROW_UP,
  down = termfx.key.ARROW_DOWN,
  wait = termfx.key.TAB,
}

local function monsterPositions(game)
  local monsters = game:monsters()
  return map(function(m)
    local pos = m:pos()
    return {x = pos:x(), y = pos:y()}
  end, monsters)
end

describe("Game Tests", function()
  it("Idle Monster Test", function()
    ROT.RNG:init(50)
    _G.game_random = _G.twister(50)

    local game = require("game.game"):new()

    assert.are.same(
      {{x = 45, y = 24}, {x = 50, y = 5}, {x = 13, y = 20}},
      monsterPositions(game))
    game:handle_input({char = "", key = keys.wait})
    game:handle_input({char = "", key = keys.wait})
    game:handle_input({char = "", key = keys.wait})
    assert.are.same(
      {{x = 43, y = 24}, {x = 48, y = 5}, {x = 14, y = 20}},
      monsterPositions(game))
  end)

  it("Monster Follow / Attack", function()
    ROT.RNG:init(22)
    _G.game_random = _G.twister(22)

    local game = require("game.game"):new()
    for _=1, 12 do
      game:handle_input({char = "", key = keys.right})
    end

    assert.are.same({_x = 59, _y = 7}, game:monsters()[1]:pos())
  end)

  it("Monster Run away", function()
    ROT.RNG:init(25)
    _G.game_random = _G.twister(25)

    local game = require("game.game"):new()
    for _=1, 2 do game:handle_input({char = "", key = keys.wait}) end
    for _=1, 9 do game:handle_input({char = "", key = keys.right}) end
    for _=1, 5 do game:handle_input({char = "", key = keys.wait}) end

    assert.are.same({_x = 22, _y = 12}, game:monsters()[3]:pos())
  end)

  it("Monster Lose Sight", function()
    ROT.RNG:init(32)
    _G.game_random = _G.twister(32)

    local game = require("game.game"):new()
    game:handle_input({char = "", key = keys.right})
    game:handle_input({char = "", key = keys.down})
    game:handle_input({char = "", key = keys.right})
    game:handle_input({char = "", key = keys.down})
    game:handle_input({char = "", key = keys.down})
    game:handle_input({char = "", key = keys.right})
    game:handle_input({char = "", key = keys.down})
    game:handle_input({char = "", key = keys.right})
    game:handle_input({char = "", key = keys.down})
    game:handle_input({char = "", key = keys.down})
    for _=1, 10 do game:handle_input({char = "", key = keys.wait}) end

    assert.are.same({_x = 17, _y = 6}, game:monsters()[3]:pos())
  end)
end)
