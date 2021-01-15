        .text
        .syntax unified
        .arch armv6t2
        .thumb
        .globl redwolf
        .thumb_func
redwolf:
        push    {r4-r7,lr}
        sub     sp, sp, r3
        mov     r7, sp
        movs    r5, r3
        movs    r6, #0
.Lmemset_loop:
        subs    r5, #1
        strb    r6, [r7, r5]
        bne     .Lmemset_loop
.Lmemset_loop_end:
        cbz     r1, .Lsum_loop_end
.Lsum_loop:
        ldrb    r4, [r7, r6]
        ldrb    r5, [r0], #1
        adds    r5, r4
        strb    r5, [r7, r6]
        adds    r6, #1
        cmp     r6, r3
        it      eq
        moveq   r6, #0
        subs    r1, #1
        bne     .Lsum_loop
.Lsum_loop_end:
        movs    r4, r7
        subs    r5, r3, #2
.Lchecksum_loop:
        ldrb    r6, [r4, #1]
        ldrb    r1, [r4, #2]
        bl      checksum
        subs    r5, #1
        bhi     .Lchecksum_loop
.Lchecksum_loop_end:
        ldrb    r6, [r4, #1]
        ldrb    r1, [r7]
        bl      checksum
        ldrb    r6, [r7]
        ldrb    r1, [r7, #1]
        bl      checksum
        add     sp, r3
        pop     {r4-r7, pc}

        .thumb_func
checksum:
        ldrb    r0, [r4], #1
        and.w   r6, r6, #31
        lsrs    r1, r1, #1
        adcs    r0, r6
.Lmodulo_loop:
        subs    r0, #36
        bge     .Lmodulo_loop
.Lmodulo_loop_end:
        cmp.w   r0, #9 - 36
        it      gt
        addgt   r0, #'a'-10-'0'
        adds    r0, #'0'+36
        strb    r0, [r2], #1
        bx      lr