        .syntax unified
        .arch armv6t2
        .thumb
        .globl lobstah
        .thumb_func
        // C callable.
        // void lobstah(char *sentence, const char *target);
        // Input:
        //   sentence (null terminated string): r0
        //   target (null terminated string): r1
        // Output:
        //   sentence is modified in place
        //
        // This is nothing but the obvious approach: a linear
        // search loop. Sometimes, that's best. ¯\_(ツ)_/¯
lobstah:
.Lnext_target:
        // Load next byte from target, increment (wide insn)
        ldrb    r2, [r1], #1
        // Search
.Lsearch_loop:
        // Load byte from sentence
        ldrb    r3, [r0]
        // Is it our target?
        cmp     r3, r2
        // If it wasn't, replace with a '*'
        it      ne
        movne   r3, #'*'
        // Store back and increment (wide insn)
        strb    r3, [r0], #1
        // Loop while we don't have a match
        // (the flags were not modified since the cmp)
        bne     .Lsearch_loop
.Lsearch_loop.end:
        // Loop unless we reached the null terminator.
        cmp     r2, #0
        bne     .Lnext_target
.Lend:
        // Return
        bx      lr
