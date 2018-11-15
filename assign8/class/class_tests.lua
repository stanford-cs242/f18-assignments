-- luacheck: std max+busted
require 'busted.runner'()

local class = require "class.class"
local types = require "class.types"

local BasicClass = class.class({class.Object}, function(Class)
    function Class:set(x)
      self.x = x
    end

    function Class:get()
      return self.x
    end
end, {x = types.Number})

local ParentClass = class.class({class.Object}, function(Class)
    function Class:constructor(x)
      self.x = x + 1
    end

    function Class:incr()
      self.x = self.x + 1
    end
end, {x = types.Number})

local ChildClass = class.class({ParentClass}, function(Class)
    function Class:constructor(x, y)
      ParentClass.constructor(self, x)
      self.y = y
    end

    function Class:add()
      return self.x + self.y
    end
end, {y = types.Number})

local GrandchildClass = class.class({ChildClass}, function(_) end, {})

describe("Basic Class Tests", function()
  it("Object Tests", function()
    local p = BasicClass:new()
    p:set(1)
    assert.are.equals(1, p.x)
    assert.are.equals(1, p:get())
  end)

  it("Constructor Tests", function()
    local p = ParentClass:new(1)
    assert.are.equals(2, p.x)
    p:incr()
    assert.are.equals(3, p.x)
  end)

  it("Inheritance Tests", function()
    local p1 = ChildClass:new(1, 2)
    assert.are.equals(2, p1.x)
    p1:incr()
    assert.are.equals(3, p1.x)
    assert.are.equals(2, p1.y)
    assert.are.equals(5, p1:add())

    local p2 = GrandchildClass:new(1, 2)
    assert.are.equals(4, p2:add())
  end)

  it("Type Tests", function()
    local p1 = ChildClass:new(1, 2)
    assert.is_true(class.Object:is(p1))
    assert.is_true(ParentClass:is(p1))
    assert.is_true(ChildClass:is(p1))
    assert.is_false(GrandchildClass:is(p1))

    local Class = class.class(
      {class.Object}, function(_) end, {x = types.Number, y = ChildClass})
    local p2 = Class:new()
    assert.is_false(pcall(function() p2.x = "test" end))
    assert.is_true(pcall(function() p2.x = 0 end))
    assert.is_false(pcall(function() p2.y = "test" end))
    assert.is_true(pcall(function() p2.y = ChildClass:new(1, 2) end))
    assert.is_true(Class:is(p2))
    assert.is_true(class.Object:is(p2))
  end)
end)
