-- luacheck: std max+busted
require 'busted.runner'()

local types = require "class.types"

describe("Basic Type Tests", function()
  describe('Primitive Tests', function()
    it('Any', function()
      assert.is_true(types.Any:is(nil))
      assert.is_true(types.Any:is("a"))
      assert.is_true(types.Any:is(0))
    end)

    it('String', function()
      assert.is_true(types.String:is("a"))
      assert.is_false(types.String:is(0))
    end)

    it('Number', function()
      assert.is_true(types.Number:is(0))
      assert.is_false(types.Number:is("a"))
    end)

    it('Function', function()
      assert.is_true(types.Function:is(function() end))
      assert.is_false(types.Function:is(0))
    end)

    it('Boolean', function()
      assert.is_true(types.Boolean:is(true))
      assert.is_false(types.Boolean:is(0))
    end)

    it('Nil', function()
      assert.is_true(types.Nil:is(nil))
      assert.is_false(types.Nil:is(0))
    end)
  end)

  it('List Tests', function()
    local numlist = types.List(types.Number)
    assert.is_true(numlist:is({1, 2, 3}))
    assert.is_false(numlist:is(1))
    assert.is_false(numlist:is({"a", "b"}))
    assert.is_false(numlist:is({0, "a"}))

    local nestlist = types.List(types.List(types.String))
    assert.is_true(nestlist:is({{"a"}, {"b"}}))
    assert.is_false(nestlist:is({{"a"}, {0}}))
  end)

  it('Table Tests', function()
    local tab = types.Table(types.String, types.Number)
    assert.is_true(tab:is({a = 0, b = 1}))
    assert.is_false(tab:is({a = 0, b = "b"}))
  end)
end)
