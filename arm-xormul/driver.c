#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint16_t xormul_boring_neon(uint8_t x, uint8_t y);
uint32_t xormul_scalar(uint32_t x, uint32_t y);

struct test_data {
    uint8_t x;
    uint8_t y;
    uint16_t expected;
};

static const struct test_data tests[] = {
    { 0, 1, 0 },
    { 1, 2, 2 },
    { 9, 0, 0 },
    { 6, 1, 6 },
    { 3, 3, 5 },
    { 2, 5, 10 },
    { 7, 9, 63 },
    { 13, 11, 127 },
    { 5, 17, 85 },
    { 14, 13, 70 },
    { 19, 1, 19 },
    { 63, 63, 1365 }
};

int main(void)
{
    printf("x\ty\texpect\tneon\tscalar\n");
    for (size_t i = 0; i < sizeof(tests)/sizeof(tests[0]); i++) {
        uint32_t neon = xormul_boring_neon(tests[i].x, tests[i].y);
        uint32_t scalar = xormul_scalar(tests[i].x, tests[i].y);
        printf("%u\t%u\t%u\t%u\t%u\t%s\n",
               tests[i].x,
               tests[i].y,
               tests[i].expected,
               neon,
               scalar,
               (neon == tests[i].expected && scalar == tests[i].expected) ? "OK" : "FAIL"
        );
    }
}

