#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

void lobstah(char *sentence, const char *target);


static void test(const char *sentence, const char *target, const char *expected)
{
    char *sentence_copy = strdup(sentence);
    lobstah(sentence_copy, target);
    printf("%s\n%s\n%s\n", sentence, target, sentence_copy);
    if (strcmp(sentence_copy, expected) != 0) {
        printf("->FAIL!!!\n\n");
    } else {
        printf("->OK\n\n");
    }
    free(sentence_copy);
}

int main()
{
    test(
        "I do not control the speed at which lobsters die",
        "code",
        "*********co**************d***************e******"
    );

    test(
        "testcase string",
        "tas",
        "t****as********"
    );

    test(
        "uglhwagp qvyntzmf",
        "ulhwagpqvyntzmf",
        "u*lhwagp*qvyntzmf"
    );

    test(
        "qrkacxx wwfja jsyjdffa vwfgxf",
        "qcfvf",
        "q***c*****f************v*f***"
    );

    test(
        "z wzsgovhh jopw igcx muxj xmmisxdn t lmb",
        "gcujxlb",
        "*****g************c***u*j*x**********l*b"
    );


    test(
        "kxf jgmzejypb ya",
        "e",
        "********e*******"
    );

    test(
        "fe oxyk y",
        "ex",
        "*e**x****"
    );

    test(
        "o wr fmik",
        "owrfmik",
        "o*wr*fmik"
    );

    test(
        "pgezt yozcyqq drxt gcvaj hx l ix xemimmox",
        "e",
        "**e**************************************"
    );

    test(
        "kqclk b hkgtrh",
        "k",
        "k*************"
    );

    test(
        "sia prcrdfckg otqwvdv wzdqxvqb h xclxmaj xjdwt lzfw",
        "crwqqhxl",
        "******cr*********w*******q**q**h*x*l***************"
    );

    test(
        "teatsase",
        "tas",
        "t*a*s***"
    );
}
