--- The RNG Class.
-- A Lua port of Johannes Baagøe's Alea
-- From http://baagoe.com/en/RandomMusings/javascript/
-- Johannes Baagøe <baagoe@baagoe.com>, 2010
-- Mirrored at:
-- https://github.com/nquinlan/better-random-numbers-for-javascript-mirror
-- @module ROT.RNG
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local RNG = ROT.Class:extend("RNG")

require "deps.randomlua"

function RNG:init(seed)
    self.twister = twister(seed)
end

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function RNG:setSeed(seed)
    self.twister:randomseed(seed)
end

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
function RNG:random(a, b)
  return self.twister:random(a, b)
end

RNG.randomseed = RNG.setSeed

RNG:init()

return RNG
