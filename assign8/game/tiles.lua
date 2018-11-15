local class = require "class.class"
local types = require "class.types"

local mod = {}

mod.Tile = class.class({class.Object}, function(Class)
    function Class:constructor()
        self.seen = false
    end

    function Class:char()
        return error("char has not been overridden.")
    end

    function Class:seen_char()
        return error("seen_char has not been overridden.")
    end
end, {
    seen = types.Boolean
})

mod.GroundTile = class.class({mod.Tile}, function(Class)
    function Class:char() return "." end
    function Class:seen_char() return " " end
end, {})

mod.WallTile = class.class({mod.Tile}, function(Class)
    function Class:char() return "#" end
    function Class:seen_char() return "+" end
end, {})

return mod
