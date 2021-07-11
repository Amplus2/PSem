# collatz-collection
A collection of games and interactive statistics about the Collatz conjecture.

## Our topic: The Collatz conjecture
### 1. Procedure
Start with a number n ∊ ℕ
- If n is even → n becomes n / 2.
- If n is odd → n becomes 3n + 1.
- Repeat

### 2. Examples
8 → 4 → 2 → 1 → 4 → ...

5 → 16 → 8 → 4 → 2 → 1 → 4 → ...

### 3. Conclusion
Any number sequence of a starting number n ∊ ℕ (Collatz sequence)
ends in the following scheme 4 → 2 → 1 → 4 → ...

### 4. Problem
1.3 has not been proven.

### 5. Collatz-Steps
The length of the Collatz sequence is the number of steps required
to get to the value 1.

## Technical information
cc is built using completely static HTML, CSS and JS, as well as some C++ that
is compiled to WebAssembly for performance.

### Dependencies
For a full rebuild of collatz-collection you will need the following:
* A POSIX system (`sh`, `mkdir`, `rm`, `time`, ...)
* [`make`](https://www.gnu.org/software/make/)
* [`python3`](https://www.python.org)
* [`dart`](https://dart.dev)
* [`inkscape`](https://inkscape.org)
* [`imagemagick`](https://imagemagick.org)
* [`graphviz`](https://graphviz.org)
* [`qrencode`](https://fukuchi.org/works/qrencode/)
* [`clang++`](https://clang.llvm.org)
* [`lld`](https://lld.llvm.org) (for `wasm-ld`)
* Optionally [`wasmer`](https://wasmer.io) for testing

### Building
1. Generate the Makefile with `./configure`
2. Delete the previous build: `make clean`
3. Build: `make -j$(nproc) all`
4. Optionally test and benchmark: `make test benchmark`
