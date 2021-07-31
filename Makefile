CXX ?= c++
WASMC ?= clang++ --target=wasm32
WASMRUNNER ?= wasmer
CXXFLAGS ?= -Wall -Wextra -pedantic -O3 -flto -std=c++17
WASMFLAGS ?= $(CXXFLAGS) -nostdlib -s -Wl,--lto-O3 -Wl,--no-entry -Wl,--export-all

HTMLS = index.html graph/index.html stats/index.html seq/index.html
ICOS = img/logo.ico img/kurs_logo.ico img/qr.ico

all: collatz.wasm graph/graph.svg $(ICOS) $(HTMLS)

test:
	@mkdir -p tmp
	$(CXX) $(CXXFLAGS) -o tmp/testexe test.cc
	tmp/testexe

benchmark:
	@mkdir -p tmp
	$(WASMC) $(WASMFLAGS) benchmark.cc -o tmp/bench.wasm
	$(CXX) $(CXXFLAGS) benchmark.cc -o tmp/benchmarkexe
	time sh -c '$(WASMRUNNER) tmp/bench.wasm -i main 0 0 >/dev/null'
	time tmp/benchmarkexe

%.wasm: %.cc
	$(WASMC) $(WASMFLAGS) $< -o $@

HTML_MINIFY = npx html-minifier --collapse-whitespace --remove-attribute-quotes --remove-comments \
                                --remove-empty-attributes --remove-redundant-attributes --remove-tag-whitespace

dist: all package-lock.json
	mkdir -p dist/game/ dist/graph/ dist/seq/ dist/stats/ dist/img/

	$(HTML_MINIFY) -o dist/index.html index.html
	$(HTML_MINIFY) -o dist/game/index.html game/index.html
	$(HTML_MINIFY) -o dist/game/fail.htm game/fail.htm
	$(HTML_MINIFY) -o dist/graph/index.html graph/index.html
	$(HTML_MINIFY) -o dist/seq/index.html seq/index.html
	$(HTML_MINIFY) -o dist/stats/index.html stats/index.html

	npx babel collatz.js -o dist/collatz.js

	cp -f game/fail.htm dist/game/
	cp -f graph/graph.svg dist/graph/graph.svg
	cp -f style.css collatz.wasm img/* dist/

clean:
	rm -rf collatz.wasm *.ico qr.png tmp/ graph/graph.svg tools/pubspec.lock $(HTMLS)

img/qr.png:
	qrencode -o img/qr.png "https://www.gymnasium-pegnitz.de/unterricht/faecher/mathematik/SpielMalMathe/"

graph/graph.svg: tools/graph.ts
	deno run --allow-write --allow-run --allow-read tools/graph.ts graph/graph.svg

index.html: tools/tmplt raw/index.htm
	tools/tmplt "" collatz-collection < raw/index.htm > index.html

stats/index.html: tools/tmplt raw/stats.htm
	tools/tmplt ../ "Statistiken zur Collatz-Folge" < raw/stats.htm > stats/index.html

seq/index.html: tools/tmplt raw/seq.htm
	tools/tmplt ../ Collatz-Folge < raw/seq.htm > seq/index.html

graph/index.html: tools/tmplt raw/graph.htm
	tools/tmplt ../ Collatz-Graph < raw/graph.htm > graph/index.html

package-lock.json: package.json
	npm install

.PHONY: all benchmark clean test

# !caution! do not remove these comments
# auto-generated block comes here

tmp/%-32.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 32 -h 32 $< -o tmp/$*-32.png 2>/dev/null

tmp/%-64.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 64 -h 64 $< -o tmp/$*-64.png 2>/dev/null

tmp/%-96.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 96 -h 96 $< -o tmp/$*-96.png 2>/dev/null

tmp/%-128.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 128 -h 128 $< -o tmp/$*-128.png 2>/dev/null

tmp/%-160.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 160 -h 160 $< -o tmp/$*-160.png 2>/dev/null

tmp/%-192.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 192 -h 192 $< -o tmp/$*-192.png 2>/dev/null

tmp/%-224.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 224 -h 224 $< -o tmp/$*-224.png 2>/dev/null

tmp/%-256.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 256 -h 256 $< -o tmp/$*-256.png 2>/dev/null

tmp/%-288.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 288 -h 288 $< -o tmp/$*-288.png 2>/dev/null

tmp/%-320.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 320 -h 320 $< -o tmp/$*-320.png 2>/dev/null

tmp/%-352.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 352 -h 352 $< -o tmp/$*-352.png 2>/dev/null

tmp/%-384.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 384 -h 384 $< -o tmp/$*-384.png 2>/dev/null

tmp/%-416.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 416 -h 416 $< -o tmp/$*-416.png 2>/dev/null

tmp/%-448.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 448 -h 448 $< -o tmp/$*-448.png 2>/dev/null

tmp/%-480.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 480 -h 480 $< -o tmp/$*-480.png 2>/dev/null

tmp/%-512.png: img/%.svg
	@mkdir -p tmp
	inkscape -w 512 -h 512 $< -o tmp/$*-512.png 2>/dev/null

tmp/%-32.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 32x32 tmp/$*-32.png

tmp/%-64.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 64x64 tmp/$*-64.png

tmp/%-96.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 96x96 tmp/$*-96.png

tmp/%-128.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 128x128 tmp/$*-128.png

tmp/%-160.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 160x160 tmp/$*-160.png

tmp/%-192.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 192x192 tmp/$*-192.png

tmp/%-224.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 224x224 tmp/$*-224.png

tmp/%-256.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 256x256 tmp/$*-256.png

tmp/%-288.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 288x288 tmp/$*-288.png

tmp/%-320.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 320x320 tmp/$*-320.png

tmp/%-352.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 352x352 tmp/$*-352.png

tmp/%-384.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 384x384 tmp/$*-384.png

tmp/%-416.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 416x416 tmp/$*-416.png

tmp/%-448.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 448x448 tmp/$*-448.png

tmp/%-480.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 480x480 tmp/$*-480.png

tmp/%-512.png: img/%.png
	@mkdir -p tmp
	convert $< -resize 512x512 tmp/$*-512.png

img/%.ico: tmp/%-32.png tmp/%-64.png tmp/%-96.png tmp/%-128.png tmp/%-160.png tmp/%-192.png tmp/%-224.png tmp/%-256.png tmp/%-288.png tmp/%-320.png tmp/%-352.png tmp/%-384.png tmp/%-416.png tmp/%-448.png tmp/%-480.png tmp/%-512.png
	convert tmp/$*-*.png $@
