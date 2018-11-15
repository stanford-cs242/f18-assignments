LFLAGS=$(shell pkg-config --libs lua5.3)
LUA=lua5.3

default: stringmatch.so

%.so: %.rs
	rustc -O $< --crate-type dylib -o $@ $(CFLAGS) $(LFLAGS)
