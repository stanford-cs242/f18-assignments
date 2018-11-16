local stringmatch = require "stringmatch"

assert(stringmatch.match("abc", "a") == 1)
assert(stringmatch.match("aaa", "a") == 3)
assert(stringmatch.match("abc", "d") == 0)
assert(stringmatch.match("hello world", "world") == 1)
