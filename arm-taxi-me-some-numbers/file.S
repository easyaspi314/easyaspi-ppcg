        .syntax unified
        .text
        .arch armv6t2
        .thumb
        .globl taxi_safe
        .thumb_func
taxi_safe:
        @ Nickname some registers for clarity
        n .req r0
        candidate .req r1
        i .req r2
        j .req r3
        matches_left .req r4
        i_cubed .req r5
        j_cubed_sum .req r6

        push    {r4-r6, lr}
        @ Start with a candidate of 1 (even though it's impossible)
        movs    candidate, #1
.Lcandidate_loop:
        @ reset match counter
        movs    matches_left, n
        @ start checking cubes
        @ This version loops forwards from 1 and short circuits logically.
        @ It can correctly calculate n == 3.
        @ for (i = 1; i * i * i < candidate; i++) but the check is after the loop
        movs    i, #1
.Li_loop:
        @ i_cubed = i * i * i
        mul     i_cubed, i, i                        @ wide insn
        muls    i_cubed, i
        @ for (j = i; --j;)
        movs    j, i
.Lj_loop:
        @ j_cubed_sum = j * j * j + i_cubed
        mul     j_cubed_sum, j, j                    @ wide insn
        mla     j_cubed_sum, j_cubed_sum, j, i_cubed @ wide insn
        @ Compare to the candidate
        cmp     j_cubed_sum, candidate
        bne     .Lno_match
.Lmatch:
        @ If it is the same, decrement matches_left
        subs    matches_left, #1
        @ Exit if we found all of the matches
        bne     .Lexit
.Lno_match:
        @ Decrement j and loop while non-zero.
        subs    j, #1
        bhi     .Lj_loop
.Lnext_i:
        @ Increment i, and loop if i_cubed is less than candidate.
        adds    i, #1
        cmp     i_cubed, candidate
        blo     .Li_loop
.Lnext_candidate:
        @ Next candidate.
        adds    candidate, #1
        b       .Lcandidate_loop
.Lexit:
        movs    r0, candidate
        pop     {r4-r6, pc}