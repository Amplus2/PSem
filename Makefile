CXX ?= c++
WASMC ?= clang++ --target=wasm32
WASMRUNNER ?= wasmer
CXXFLAGS ?= -Wall -Wextra -pedantic -O3 -flto
CXXFLAGS += -std=c++17
WASMFLAGS ?= -Wall -Wextra -pedantic -O3 -flto -nostdlib -s -Wl,--lto-O3 -Wl,--no-entry -Wl,--export-all
WASMFLAGS += -std=c++17

INKSCAPE_EXPORT_FLAG = -$(shell inkscape --export-type svg -o - >/dev/null && echo o || echo e)

$(shell mkdir -p tmp dist/cc/game dist/cc/graph dist/cc/seq dist/cc/stats dist/img)

all: dist

test:
	$(CXX) $(CXXFLAGS) -o tmp/testexe cpp/test.cc
	tmp/testexe

benchmark:
	$(WASMC) $(WASMFLAGS) cpp/benchmark.cc -o tmp/bench.wasm
	$(CXX) $(CXXFLAGS) cpp/benchmark.cc -o tmp/benchmarkexe
	time sh -c '$(WASMRUNNER) tmp/bench.wasm -i main 0 0 > /dev/null'
	time tmp/benchmarkexe

dist/cc/collatz.wasm: cpp/collatz.cc
	$(WASMC) $(WASMFLAGS) cpp/collatz.cc -o dist/cc/collatz.wasm

%.wasm: %.cc
	$(WASMC) $(WASMFLAGS) $< -o $@

HTML_MINIFY = npx html-minifier --collapse-whitespace --remove-attribute-quotes --remove-comments \
                                --remove-empty-attributes --remove-redundant-attributes --remove-tag-whitespace

dist: dist/img/index-placeholder.png dist/index.html dist/cc/collatz.js dist/cc/stats/stats.js dist/kaskadierend.css dist/img/cc_logo.ico dist/img/kurs_logo.ico dist/img/qr.ico dist/cc/index.html dist/cc/graph/index.html dist/cc/seq/index.html dist/cc/stats/index.html dist/build.html dist/cc/game/index.html dist/cc/game/fail.htm dist/cc/collatz.wasm dist/mathe-musik/ dist/cc/graph/graph.svg

dist/index.html: html/index.html
	cp $< $@

dist/kaskadierend.css: package-lock.json html/kaskadierend.css
	npx csso html/kaskadierend.css -o dist/kaskadierend.css

dist/cc/game/%: html/cc/game/% package-lock.json
	$(HTML_MINIFY) -o $@ $<

dist/cc/collatz.js: package-lock.json html/cc/collatz.js
	npx babel html/cc/collatz.js -o dist/cc/collatz.js
	
dist/cc/stats/stats.js: package-lock.json html/cc/stats.js
	npx babel html/cc/stats.js -o dist/cc/stats/stats.js

clean:
	rm -rf tmp/ dist/ package-lock.json

open: all
	sleep 0.1 && tools/open.sh http://localhost:8004/ &
	python3 -m http.server -d dist/ 8004

html/img/qr.png:
	qrencode -o html/img/qr.png "https://www.gymnasium-pegnitz.de/unterricht/faecher/mathematik/SpielMalMathe/"

dist/cc/graph/graph.svg: tools/graph.ts
	tools/graph.ts dist/cc/graph/graph.svg

# TODO: simplify using macros
dist/cc/index.html: package-lock.json tools/tmplt html/cc/raw/index.htm
	tools/tmplt "" collatz-collection < html/cc/raw/index.htm | $(HTML_MINIFY) -o dist/cc/index.html

dist/cc/stats/index.html: package-lock.json tools/tmplt html/cc/raw/stats.htm
	tools/tmplt ../ "Statistiken zur Collatz-Folge" < html/cc/raw/stats.htm | $(HTML_MINIFY) -o dist/cc/stats/index.html

dist/cc/seq/index.html: package-lock.json tools/tmplt html/cc/raw/seq.htm
	tools/tmplt ../ Collatz-Folge < html/cc/raw/seq.htm | $(HTML_MINIFY) -o dist/cc/seq/index.html

dist/cc/graph/index.html: package-lock.json tools/tmplt html/cc/raw/graph.htm
	tools/tmplt ../ Collatz-Graph < html/cc/raw/graph.htm | $(HTML_MINIFY) -o dist/cc/graph/index.html

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

dist/img/index-placeholder.png: html/img/index-placeholder.png
	cp $< $@

dist/img/%.ico: $(foreach r,$(RES),tmp/%-$(r).png)
	convert tmp/$*-*.png $@
