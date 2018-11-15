require "deps.randomlua"

local argparse = require "argparse"

local parser = argparse("rougelike.lua", "CS242 Roguelike Assignment")
parser:option("--seed", "Set the RNG seed.", nil, tonumber)
parser:flag("--lights-on", "Make the entire play field visible.")
parser:flag("--native-point", "Use the native point implementation.")
local args = parser:parse()

if args.seed then
  local ROT = require 'deps/rotLove/rot'
  ROT.RNG:init(args.seed)
  _G.game_random = _G.twister(args.seed)
else
  _G.game_random = _G.twister()
end

-- Use native point impl if --native-point flag is provided.
if args.native_point then
  _G.NATIVE_POINT = true
end

local game = require("game.game"):new()

if args.lights_on then
  game.lights_on = true
end

game:start()
