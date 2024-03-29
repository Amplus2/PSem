# Spiel Mal Mathe

## collatz-collection
A collection of games and interactive statistics about the Collatz conjecture.

### Our topic: The Collatz conjecture
#### 1. Procedure
Start with a number n ∊ ℕ
- If n is even → n becomes n / 2.
- If n is odd → n becomes 3n + 1.
- Repeat

#### 2. Examples
8 → 4 → 2 → 1 → 4 → ...

5 → 16 → 8 → 4 → 2 → 1 → 4 → ...

#### 3. Conclusion
Any number sequence of a starting number n ∊ ℕ (Collatz sequence)
ends in the following scheme 4 → 2 → 1 → 4 → ...

#### 4. Problem
1.3 has not been proven.

#### 5. Collatz-Steps
The length of the Collatz sequence is the number of steps required
to get to the value 1.

## mathe-musik
A presentation on how Maths relates to Music.

## Technical information
These sites are built using completely static HTML, CSS and JS, as well as some
C++ that is compiled to WebAssembly for performance. We don't use warehouses of
Node packages, instead we use KaTeX for math rendering, Chart.js for plotting
charts, and reveal.js for presentations. The build, of course, requires more
dependencies.

### Dependencies

For a full rebuild of collatz-collection you will need the following software:

* A POSIX system (`sh`, `mkdir`, `rm`, `time`, ...)
* [`make`](https://www.gnu.org/software/make/)
* [`inkscape`](https://inkscape.org)
* [`imagemagick`](https://imagemagick.org)
* [`graphviz`](https://graphviz.org)
* [`qrencode`](https://fukuchi.org/works/qrencode/)
* [`clang++`](https://clang.llvm.org)
* [`lld`](https://lld.llvm.org) (for `wasm-ld`)
* [`python3`](https://www.python.org)
* [`npx`](https://npmjs.com) (for `babel` and `html-minify`)
* [`deno`](https://deno.land) (do not install it via snap as `Deno.run` wouldn't work properly)
* [`graphviz`](https://graphviz.org/) (for `dot`)
* Optionally [`wasmer`](https://wasmer.io) for testing

and the following fonts:

* [Inter](https://fonts.google.com/specimen/Inter)
* [Manjari](https://fonts.google.com/specimen/Manjari)

On a Debian-based system, run these commands:

```
apt install -y make python3 curl inkscape imagemagick graphviz qrencode clang lld-12 nodejs npm fonts-inter
```
```
curl -Lo /usr/share/fonts/truetype/Manjari.ttf 'https://github.com/google/fonts/raw/main/ofl/manjari/Manjari-Regular.ttf'
```

Even though installing deno without the 'install.sh' is recommended, running this command is fast and easy and gets you deno installed.
```
curl -fsSL https://deno.land/x/install/install.sh | export DENO_INSTALL=/usr/local sh
```

### Building
1. Delete the previous build: `make clean`
2. Build: `make -j$(nproc) all`
3. Optionally test and benchmark: `make test benchmark`
