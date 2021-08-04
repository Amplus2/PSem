SCADS = $(wildcard *.scad)
STLS = $(SCADS:.scad=.stl)

all: $(STLS)

clean:
	rm -f $(STLS)

%.stl: %.scad
	openscad -o $@ $<

.PHONY: all clean
