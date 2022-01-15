CXX ?= c++
WASMC ?= clang++ --target=wasm32
WASMRUNNER ?= wasmer
CXXFLAGS ?= -Wall -Wextra -pedantic -O3 -flto
CXXFLAGS += -std=c++17
WASMFLAGS ?= -Wall -Wextra -pedantic -O3 -flto -nostdlib -s -Wl,--lto-O3 -Wl,--no-entry -Wl,--export-all
WASMFLAGS += -std=c++17

INKSCAPE_EXPORT_FLAG = -$(shell inkscape --export-type svg -o - >/dev/null && echo o || echo e)

$(shell mkdir -p tmp dist/cc/game dist/cc/graph dist/cc/seq dist/cc/stats dist/img dist/aequator dist/damenproblem dist/fibonacci dist/raeuber-beute dist/external_view)

all: dist

test:
	$(CXX) $(CXXFLAGS) -o tmp/testexe cpp/test.cc
	tmp/testexe

benchmark:
	$(WASMC) $(WASMFLAGS) cpp/benchmark.cc -o tmp/bench.wasm
	$(CXX) $(CXXFLAGS) cpp/benchmark.cc -o tmp/benchmarkexe
	time sh -c '$(WASMRUNNER) tmp/bench.wasm -i main 0 0 >/dev/null'
	time tmp/benchmarkexe

dist/cc/collatz.wasm: cpp/collatz.cc
	$(WASMC) $(WASMFLAGS) cpp/collatz.cc -o dist/cc/collatz.wasm

%.wasm: %.cc
	$(WASMC) $(WASMFLAGS) $< -o $@

HTML_MINIFY = npx html-minifier --collapse-whitespace --remove-attribute-quotes --remove-comments \
                                --remove-empty-attributes --remove-redundant-attributes --remove-tag-whitespace

dist: dist/external_view/index.html dist/aequator/index.html dist/aequator/anleitung.pdf dist/img/aequator.png dist/damenproblem/index.html dist/fibonacci/index.html dist/raeuber-beute/index.html dist/img/collatz.png dist/img/damenproblem.png dist/img/fibonacci.png dist/img/pythagoras.png dist/img/entstandenes_quadrat.png dist/img/raeuber_beute.png dist/index.html dist/cc/collatz.js dist/cc/stats/stats.js dist/kaskadierend.css dist/img/cc_logo.ico dist/img/kurs_logo.ico dist/img/qr.ico dist/cc/index.html dist/cc/graph/index.html dist/cc/seq/index.html dist/cc/stats/index.html dist/build.html dist/cc/game/index.html dist/cc/game/fail.htm dist/cc/collatz.wasm dist/mathe-musik/ dist/cc/graph/graph.svg

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
	qrencode -o html/img/qr.png "https://www.gymnasium-pegnitz.de/wp-content/uploads/psem-dist/"

dist/cc/graph/graph.svg: tools/graph.ts
	tools/graph.ts | dot -Tsvg | npx svgo -i - -o $@ --multipass

# TODO: simplify using macros
dist/cc/index.html: package-lock.json tools/tmplt html/cc/raw/index.htm
	tools/tmplt "" collatz-collection cc-tex < html/cc/raw/index.htm | $(HTML_MINIFY) -o $@

dist/cc/stats/index.html: package-lock.json tools/tmplt html/cc/raw/stats.htm
	tools/tmplt ../ "Statistiken zur Collatz-Folge" cc < html/cc/raw/stats.htm | $(HTML_MINIFY) -o $@

dist/cc/seq/index.html: package-lock.json tools/tmplt html/cc/raw/seq.htm
	tools/tmplt ../ Collatz-Folge cc < html/cc/raw/seq.htm | $(HTML_MINIFY) -o $@

dist/cc/graph/index.html: package-lock.json tools/tmplt html/cc/raw/graph.htm
	tools/tmplt ../ Collatz-Graph cc < html/cc/raw/graph.htm | $(HTML_MINIFY) -o $@

dist/aequator/index.html: package-lock.json tools/tmplt html/aequator/index.htm
	tools/tmplt "" Äquatoraufgabe tex-centered < html/aequator/index.htm | $(HTML_MINIFY) -o $@

dist/aequator/anleitung.pdf: html/aequator/anleitung.pdf
	cp $< $@

dist/damenproblem/index.html: package-lock.json tools/tmplt html/damenproblem/index.htm dp-imgs
	tools/tmplt "" Damenproblem centered < html/damenproblem/index.htm | $(HTML_MINIFY) -o $@

dist/fibonacci/index.html: package-lock.json tools/tmplt html/fibonacci/index.htm
	tools/tmplt "" Fibonacci-Folge centered < html/fibonacci/index.htm | $(HTML_MINIFY) -o $@

dist/raeuber-beute/index.html: package-lock.json tools/tmplt html/raeuber-beute/index.htm
	tools/tmplt "" Räuber-Beute-Beziehung centered < html/raeuber-beute/index.htm | $(HTML_MINIFY) -o $@

dist/external_view/index.html: html/external_view/index.html
	cp $< $@

dist/build.html: package-lock.json tools/build_info.sh
	tools/build_info.sh | tools/tmplt "" "PSem Build Info" centered | $(HTML_MINIFY) -o $@

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

dist/img/aequator.png: html/img/aequator.png
	cp $< $@

dist/img/collatz.png: html/img/collatz.png
	cp $< $@

dist/img/damenproblem.png: html/img/damenproblem.png
	cp $< $@

dist/img/fibonacci.png: html/img/fibonacci.png
	cp $< $@

dist/img/pythagoras.png: html/img/pythagoras.png
	cp $< $@

dist/img/entstandenes_quadrat.png: html/img/entstandenes_quadrat.png
	cp $< $@

dist/img/raeuber_beute.png: html/img/raeuber_beute.png
	cp $< $@

dist/damenproblem/%.jpg: html/damenproblem/%.jpg
	cp $< $@

dp-imgs: dist/damenproblem/1.jpg dist/damenproblem/2.jpg dist/damenproblem/3.jpg dist/damenproblem/4.jpg dist/damenproblem/5.jpg dist/damenproblem/6.jpg dist/damenproblem/7.jpg
