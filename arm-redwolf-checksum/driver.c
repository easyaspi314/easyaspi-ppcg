#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

void redwolf(const uint8_t *data, size_t data_size, char *block, size_t block_size);

static void test(const uint8_t *data, size_t data_size, size_t block_size, const char *expected)
{
    printf("[");
    for (size_t i = 0; i < data_size; i++) {
        printf("%u, ", data[i]);
    }
    printf("]; %zu -> \"%s\" ", block_size, expected);

    char *block = malloc(block_size);
    memset(block, '?', block_size);
    redwolf(data, data_size, block, block_size);

    printf("got: \"");
    fwrite(block, 1, block_size, stdout);
    printf("\" -> ");
    if (!memcmp(expected, block, block_size)) {
        printf("OK\n");
    } else {
        printf("FAIL!!!\n");
    }
    free(block);
}

int main(void)
{
    test(NULL, 0, 8, "00000000");
    test((const uint8_t[]){0, 1, 2, 3, 4, 5, 6, 7}, 8, 8, "14589cd8");
    test((const uint8_t[]){0, 1, 2, 3, 4, 5, 6, 7}, 8, 6, "eb589b");
    test((const uint8_t[]){0, 4, 2, 1}, 4, 48, "473100000000000000000000000000000000000000000000");
    test((const uint8_t[]){195, 180, 1, 0}, 4, 4, "0123");
    test((const uint8_t[]){31, 32, 65, 4}, 4, 4, "wxyz");
    test((const uint8_t[]){20, 8, 247, 41}, 4, 4, "tw4p");
    test((const uint8_t[]){250, 175, 225, 200}, 4, 4, "ewhb");
}