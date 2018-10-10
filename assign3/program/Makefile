all: stream2.native list2.native

BUILD = corebuild
FLAGS = -package ounit -use-ocamlfind -use-menhir 

%.native: always
	$(BUILD) $(FLAGS) src/$@

clean:
	rm -rf *.native *.top _build

always:

.PHONY: always
