LFLAGS=$(shell pkg-config --libs lua5.3)
LUA=lua5.3

.PHONY: default clean check

default: point/native_point.so

GAME_TARGETS := $(wildcard class/*.lua point/*.lua game/*.lua)
GAME_TARGETS := roguelike.lua $(filter-out %_tests.lua, $(GAME_TARGETS))
roguelike.bin: $(GAME_TARGETS)
	squish
	@luac5.3 -o $@ solution.lua
	@rm solution.lua

point/%.so: point/%.rs
	rustc -O $< --crate-type dylib -o $@ $(CFLAGS) $(LFLAGS)

clean:
	rm -f *.so *.bin

check:
	@luacheck . --no-self --exclude-files deps/*

test:
	@$(LUA) class/class_tests.lua
	@$(LUA) class/type_tests.lua
	@$(LUA) game/game_tests.lua
	@$(LUA) point/point_tests.lua

SUBMISSION_FILES := class/class.lua class/types.lua game/monster.lua point/native_point.rs
submission: $(SUBMISSION_FILES)
	zip -r -0 submission.zip $^
