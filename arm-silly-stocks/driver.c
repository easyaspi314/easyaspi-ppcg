#include <stdio.h>
#include <stdint.h>

void silly_stocks(const char *str);

int main(int argc, char *argv[])
{
    if (argc != 2) {
        return 1;
    }
    silly_stocks(argv[1]);
}