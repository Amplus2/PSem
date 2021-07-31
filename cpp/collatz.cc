#include <stdint.h>

typedef uint_fast32_t i32;
typedef uint_fast64_t i64;
typedef char *str;
typedef const char *cstr;

namespace {
static constexpr inline void collatz_step(i64 &i) {
  i = i % 2 ? 3 * i + 1 : i / 2;
}

static constexpr inline void sputs(str &bfr, cstr s) {
  while (*s)
    *bfr++ = *s++;
}

static constexpr inline void sprintd(str &bfr, i64 i) {
  char tmp[32] = {0};
  char *ptr = &tmp[30];
  do {
    *ptr-- = '0' + (i % 10);
    i /= 10;
  } while (i);
  sputs(bfr, ++ptr);
}

static constexpr inline i32 first_digit(i64 x) {
  i32 helper = 0;
  while (x) {
    helper = x;
    x /= 10;
  }
  return helper;
}

} // namespace

extern "C" i32 collatz_steps(i32 n) {
  i64 i = n;
  for (n = 0; i > 1; n++) {
    collatz_step(i);
  }
  return n;
}

extern "C" i32 collatz_seq(i32 wasmjsbad, str out) {
  str start = out;
  i64 i = wasmjsbad;
  sprintd(out, i);
  while (i > 1) {
    collatz_step(i);
    sputs(out, " → ");
    sprintd(out, i);
  }
  sputs(out, " → …");
  return out - start;
}

extern "C" i32 collatz_benford(i32 max, str out) {
  i32 result[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
  for (i32 i1 = 0; i1 < max; i1++) {
    i64 i2 = i1;
    result[first_digit(i2) - 1] += 1;
    while (i2 > 1) {
      collatz_step(i2);
      result[first_digit(i2) - 1] += 1;
    }
  }

  str start = out;
  sputs(out, "[ ");
  for (int i = 0; i < 9; i++) {
    sprintd(out, result[i]);

    if (i != 8) {
      sputs(out, ", ");
    }
  }
  sputs(out, " ]");

  return out - start;
}
