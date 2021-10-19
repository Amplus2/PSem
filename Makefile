CXX ?= c++
WASMC ?= clang++ --target=wasm32
WASMRUNNER ?= wasmer
CXXFLAGS ?= -Wall -Wextra -pedantic -O3 -flto
CXXFLAGS += -std=c++17
WASMFLAGS ?= -Wall -Wextra -pedantic -O3 -flto -nostdlib -s -Wl,--lto-O3 -Wl,--no-entry -Wl,--export-all
WASMFLAGS += -std=c++17

INKSCAPE_EXPORT_FLAG = -$(shell inkscape --export-type svg -o - >/dev/null && echo o || echo e)

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

dist: dist/collatz.js dist/stats/stats.js dist/kaskadierend.css dist/img/logo.ico dist/img/kurs_logo.ico dist/img/qr.ico dist/index.html dist/graph/index.html dist/seq/index.html dist/stats/index.html dist/build.html dist/game/index.html dist/game/fail.htm dist/collatz.wasm dist/mathe-musik/ dist/graph/graph.svg

dist/kaskadierend.css: package-lock.json html/kaskadierend.css
	npx csso html/kaskadierend.css -o dist/kaskadierend.css

dist/game/%: html/game/% package-lock.json
	$(HTML_MINIFY) -o $@ $<

dist/collatz.js: package-lock.json html/collatz.js
	npx babel html/collatz.js -o dist/collatz.js
	
dist/stats/stats.js: package-lock.json html/stats.js
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
dist/index.html: package-lock.json tools/tmplt html/raw/index.htm
	tools/tmplt "" collatz-collection < html/raw/index.htm | $(HTML_MINIFY) -o dist/index.html

dist/stats/index.html: package-lock.json tools/tmplt html/raw/stats.htm
	tools/tmplt ../ "Statistiken zur Collatz-Folge" < html/raw/stats.htm | $(HTML_MINIFY) -o dist/stats/index.html

dist/seq/index.html: package-lock.json tools/tmplt html/raw/seq.htm
	tools/tmplt ../ Collatz-Folge < html/raw/seq.htm | $(HTML_MINIFY) -o dist/seq/index.html

dist/graph/index.html: package-lock.json tools/tmplt html/raw/graph.htm
	tools/tmplt ../ Collatz-Graph < html/raw/graph.htm | $(HTML_MINIFY) -o dist/graph/index.html

dist/build.html: package-lock.json tools/build_info.sh
	tools/build_info.sh | tools/tmplt "" PSem-Build | $(HTML_MINIFY) -o dist/build.html

dist/mathe-musik/: html/mathe-musik/arrow.svg html/mathe-musik/index.html html/mathe-musik/pythagroaeisches-zahlentripel.png html/mathe-musik/frequenzverhaeltnis.png html/mathe-musik/klaviatur.png html/mathe-musik/sinuswellen.png html/mathe-musik/grosse-sexte.png html/mathe-musik/naturtonreihe.png html/mathe-musik/tonkreis.png
	mkdir -p $@
	cp $? $@

package-lock.json: package.json
	npm install

.PHONY: all benchmark clean dist test dist/build.html

RES = 32 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512

define picrender
tmp/%-$(1).png: html/img/%.$(2)
	$(3)
endef

$(foreach r,$(RES),$(eval $(call picrender,$(r),svg,inkscape -w $(r) -h $(r) $$< $(INKSCAPE_EXPORT_FLAG) tmp/$$*-$(r).png)))
$(foreach r,$(RES),$(eval $(call picrender,$(r),png,convert -resize $(r)x$(r) $$< tmp/$$*-$(r).png)))

dist/img/%.ico: $(foreach r,$(RES),tmp/%-$(r).png)
	convert tmp/$*-*.png $@
