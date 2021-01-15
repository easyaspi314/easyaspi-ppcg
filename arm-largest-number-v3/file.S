        .text
        .syntax unified
        .arch armv6t2

        .thumb
        .globl main
        .thumb_func
main:
        push    {r4, lr}
        // Begin number generation code
        movw    r1, #0x8010     // 4
        lsls    r1, r1, #16     // 6
        mvns    r2, r1          // 8
        movs    r3, r2          // 10
        // End number generation code
        adr     r0, .printf_str
        bl      printf
        pop     {r4, pc}

        // Combine 0x80100000u (2148532224) with the same double we had before.
.printf_str:
        .asciz "%u%f\n"