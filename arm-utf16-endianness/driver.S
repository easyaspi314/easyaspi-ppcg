        .syntax unified
        .arch armv6t2
        .thumb
        // W+X because PIE sucks.
        .section ".writeable_text","awx",%progbits

.macro $TEST expected:req, argc:req, argv:vararg
        // Load string buffer into r0
        adr     r0, 1f
        // Convert element count to size in bytes by doubling.
        movs    r1, #\argc * 2
        // Skip over our constant pool
        b       3f
1:
        // The UTF-16 string 
        .short \argv
        .align 2
2:
        // blatant abuse of macro stringification to avoid a printf loop :P
        .asciz "\argv"
        .align 2
3:
        // Call check_utf16
        bl      check_utf16
        // Stringified version of the UTF-16 string
        adr     r1, 2b
        // Expected
        movs    r2, #\expected
        // r3 is already in place
        adr     r0, .Lprintf_str
        // printf("{ %s } -> expected: %d, got: %d\n", STR(arr), expected, retval)
        bl      printf
.endm

        .globl main
        .thumb_func
main:
        push    {r4, lr}
        // Original test cases
        $TEST   -1, 3, 0x0000, 0xDBFF, 0xDFFE
        $TEST    0, 3, 0x0000, 0x0000, 0x0000
        $TEST    1, 1, 0xFEFF
        
        // I've added more test cases, feel free to take them
        // 1: D3FD becomes FDD3 when swapped, which is bad
        $TEST    1, 3, 0xD3FD, 0xD83D, 0xDE0F
        // 0: proper string with surrogates both ways
        $TEST    0, 3, 0x0A00, 0xD83D, 0xDE0F
        // -1: DF10 is a lone trail surrogate
        $TEST   -1, 1, 0xDF10
        // 1: D9E0 is a lone head surrogate
        $TEST    1, 1, 0xE0D9
        // 0: 0xffff is invalid in both endiannesses
        $TEST    0, 2, 0x0314, 0xFFFF
        pop     {r4, pc}
.Lprintf_str:
        .asciz "{ %s } -> expected: %d, got: %d\n"