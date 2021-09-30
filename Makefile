CXX ?= c++
WASMC ?= clang++ --target=wasm32
WASMRUNNER ?= wasmer
CXXFLAGS ?= -Wall -Wextra -pedantic -O3 -flto
CXXFLAGS += -std=c++17
WASMFLAGS ?= -Wall -Wextra -pedantic -O3 -flto -nostdlib -s -Wl,--lto-O3 -Wl,--no-entry -Wl,--export-all
WASMFLAGS += -std=c++17

ifeq ($(shell inkscape --export-type svg -o - >/dev/null && echo 1),1)
	INKSCAPE_EXPORT_FLAG ?= -o
else
	INKSCAPE_EXPORT_FLAG ?= -e
endif

$(shell mkdir -p tmp dist/game dist/graph dist/seq dist/stats dist/img)

all: dist

test:
	$(CXX) $(CXXFLAGS) -o tmp/testexe cpp/test.cc
	tmp/testexe

benchmark:
	$(WASMC) $(WASMFLAGS) cpp/benchmark.cc -o tmp/bench.wasm
	$(CXX) $(CXXFLAGS) cpp/benchmark.cc -o tmp/benchmarkexe
	time sh -c '$(WASMRUNNER) tmp/bench.wasm -i main 0 0 > /dev/null'
	time tmp/benchmarkexe

dist/collatz.wasm: cpp/collatz.cc
	$(WASMC) $(WASMFLAGS) cpp/collatz.cc -o dist/collatz.wasm

%.wasm: %.cc
	$(WASMC) $(WASMFLAGS) $< -o $@

HTML_MINIFY = npx html-minifier --collapse-whitespace --remove-attribute-quotes --remove-comments \
                                --remove-empty-attributes --remove-redundant-attributes --remove-tag-whitespace

dist: dist/style.css dist/logo.ico dist/kurs_logo.ico dist/qr.ico dist/index.html dist/graph/index.html dist/seq/index.html dist/stats/index.html dist/build.html html/game/index.html html/game/fail.htm dist/graph/graph.svg dist/collatz.wasm package-lock.json

dist/style.css: html/style.css
	npx csso html/style.css -o dist/style.css

dist/game/%: html/game/%
	$(HTML_MINIFY) -o $@ $<

dist/collatz.js: html/collatz.js
	npx babel html/collatz.js -o dist/collatz.js
dist/stats/stats.js: html/stats.js
	npx babel html/stats.js -o dist/stats/stats.js

clean:
	rm -rf tmp/ dist/ package-lock.json

open: all
	sleep 0.1 && tools/open.sh http://localhost:8004/ &
	python3 -m http.server -d dist/ 8004

html/img/qr.png:
	qrencode -o html/img/qr.png "https://www.gymnasium-pegnitz.de/unterricht/faecher/mathematik/SpielMalMathe/"

dist/graph/graph.svg: tools/graph.ts
	tools/graph.ts dist/graph/graph.svg

# TODO: simplify using macros
dist/index.html: tools/tmplt html/raw/index.htm
	tools/tmplt "" collatz-collection < html/raw/index.htm | $(HTML_MINIFY) -o dist/index.html

dist/stats/index.html: tools/tmplt html/raw/stats.htm
	tools/tmplt ../ "Statistiken zur Collatz-Folge" < html/raw/stats.htm | $(HTML_MINIFY) -o dist/stats/index.html

dist/seq/index.html: tools/tmplt html/raw/seq.htm
	tools/tmplt ../ Collatz-Folge < html/raw/seq.htm | $(HTML_MINIFY) -o dist/seq/index.html

dist/graph/index.html: tools/tmplt html/raw/graph.htm
	tools/tmplt ../ Collatz-Graph < html/raw/graph.htm | $(HTML_MINIFY) -o dist/graph/index.html

dist/build.html:
	tools/build_info.sh | tools/tmplt "" Collatz-Build | $(HTML_MINIFY) -o dist/build.html

package-lock.json: package.json
	npm install

.PHONY: all benchmark clean dist test tmp/build.html

RES = 32 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512

define picrender
tmp/%-$(1).png: html/img/%.$(2)
	$(3)
endef

$(foreach r,$(RES),$(eval $(call picrender,$(r),svg,inkscape -w $(r) -h $(r) $$< $(INKSCAPE_EXPORT_FLAG) tmp/$$*-$(r).png 2>/dev/null)))
$(foreach r,$(RES),$(eval $(call picrender,$(r),png,convert -resize $(r)x$(r) $$< tmp/$$*-$(r).png)))

dist/%.ico: $(foreach r,$(RES),tmp/%-$(r).png)
	convert tmp/$*-*.png $@
