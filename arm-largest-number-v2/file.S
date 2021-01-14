        .text
        .syntax unified
        .arch armv6t2

        .thumb
        .globl main
        .thumb_func
main:
        push    {r4, lr}
        // Begin number generation code
        movw    r3, #0x8010     // 4
        lsls    r3, r3, #16     // 6
        asrs    r2, r3, #31     // 8
        mvns    r3, r3          // 10
        // End number generation code
        adr     r0, .printf_str
        bl      printf
        pop     {r4, pc}

        .align 4
.printf_str:
        .asciz "%f\n"