#include <stdio.h>
#include <time.h>
#include <collatz.h>

typedef struct {
        int y;
        int x;
} test_case;

const test_case cases[] = {
        // http://www.ericr.nl/wondrous/delrecs.html
        {1000, 1412987847},
        {987, 1341234558},
        {986, 670617279},
        {965, 537099606},
        {964, 268549803},
        {956, 226588897},
        {953, 169941673},
        {950, 127456254},
        {949, 63728127},
        {744, 36791535},
        {705, 31466382},
        {704, 15733191},
        {691, 14934241},
        {688, 11200681},
        {685, 8400511},
        {664, 6649279},
        {612, 5649499},
        {596, 3732423},
        {583, 3542887},
        {562, 3064033},
        {559, 2298025},
        {556, 1723519},
        {530, 1501353},
        {527, 1117065},
        {524, 837799},
        {508, 626331},
        {469, 511935},
        {448, 410011},
        {442, 230631},
        {385, 216367},
        {382, 156159},
        {374, 142587},
        {353, 106239},
        {350, 77031},
        {339, 52527},
        {323, 35655},
        {310, 34239},
        {307, 26623},
        {281, 23529},
        {278, 17647},
        {275, 13255},
        {267, 10971},
        {261, 6171},
        {237, 3711},
        {216, 2919},
        {208, 2463},
        {182, 2223},
        {181, 1161},
        {178, 871},
        {170, 703},
        {144, 649},
        {143, 327},
        {130, 313},
        {127, 231},
        {124, 171},
        {121, 129},
        {118, 97},
        {115, 73},
        {112, 54},
        {111, 27},
        {23, 25},
        {20, 18},
        {19, 9},
        {16, 7},
        {8, 6},
        {7, 3},
        {1, 2},
};
#define len(a) sizeof(a) / sizeof(a[0])

int main() {
        int failed = 0;
        clock_t start = clock();
        for(unsigned i = 0; i < len(cases); i++) {
                int got = collatz_steps(cases[i].x);
                if(got != cases[i].y) {
                        printf("Failed test case: "
                               "{x: %d, got: %d, want: %d}\n",
                               cases[i].x, got, cases[i].y);
                        failed++;
                }
        }
        clock_t end = clock();
        clock_t dt = end - start;

        if(failed) printf("%d/%lu tests failed.\n", failed, len(cases));
        else       printf("All tests passed within %lu ticks. "
                          "(approx %fms)\n", dt, dt * 1000.0F / CLOCKS_PER_SEC);

        return failed;
}
