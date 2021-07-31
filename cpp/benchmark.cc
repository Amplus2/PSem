#include "collatz.cc"

int main() {
        volatile i32 j;
        for(i32 i = 0; i < 10000000; i++) {
                j = collatz_steps(i);
        }
}
