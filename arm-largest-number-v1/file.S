        .text
        .syntax unified
        .arch armv6t2
        .thumb

        .globl main
        .thumb_func
main:
        push    {r4, lr}
        // start number generation code
        movs    r3, #6             // 2
        subs    r1, r3, #7         // 4
        movs    r2, r1             // 6
        push    {r1, r2, r3}       // 8
        push    {r1, r2, r3}       // 10
        // end number generation code
        // now printf everything
        adr     r0, .Lprintf_str
        bl      printf
        pop     {r1, r2, r3}
        pop     {r1, r2, r3, r4, pc}
        // print 32 bits at a time
.Lprintf_str:
        .asciz "%#08x%08x%08x%08x%08x%08x%08x%08x%08x\n"
