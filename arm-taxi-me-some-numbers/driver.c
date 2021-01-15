#include <stdio.h>
#include <stdint.h>

uint32_t taxi_safe(uint32_t n);

static void test(uint32_t n, uint32_t expected)
{
    uint32_t result = taxi_safe(n);
    printf("n: %u, expected: %u, got: %u -> %s\n", n, expected, result, expected == result ? "OK" : "FAIL!!!");
}

int main(void)
{
    test(1, 2);
    test(2, 1729);
    test(3, 87539319);
}