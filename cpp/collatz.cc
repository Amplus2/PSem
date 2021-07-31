#include <stdint.h>

typedef uint_fast32_t i32;
typedef uint_fast64_t i64;
typedef char         *str;
typedef const char   *cstr;

namespace {
static constexpr inline void collatz_step(i64 &i) {
        i = i % 2 ? 3 * i + 1 : i / 2;
}

static constexpr inline void sputs(str &bfr, cstr s) {
        while(*s) *bfr++ = *s++;
}

static constexpr inline void sprintd(str &bfr, i64 i) {
        char tmp[32] = {0};
        char *ptr = &tmp[30];
        do {
                *ptr-- = '0' + (i % 10);
                i /= 10;
        } while(i);
        sputs(bfr, ++ptr);
}
}

extern "C" i32 collatz_steps(i32 n) {
        i64 i = n;
        for(n = 0; i > 1; n++) {
                collatz_step(i);
        }
        return n;
}

extern "C" i32 collatz_seq(i32 wasmjsbad, str out) {
        str start = out;
        i64 i     = wasmjsbad;
        sprintd(out, i);
        while(i > 1) {
                collatz_step(i);
                sputs(out, " → ");
                sprintd(out, i);
        }
        sputs(out, " → …");
        return out - start;
}
