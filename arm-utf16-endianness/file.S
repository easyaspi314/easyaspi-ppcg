        .syntax unified
        .arch armv6t2
        .text
        .thumb
        .globl check_utf16
        .thumb_func
        // r0: string, r1: len in BYTES
        // The string must be writeable, although its contents
        // will effectively be unchanged because we byteswap twice.
        // Returns in r3.
check_utf16:
        push    {r1, r4-r7, lr}
        movs    r3, #0
        // Load r5 now. This allows us to naturally align
        ldr     r5, .Lconst.SURROGATE_OFFSET
        // First, check little endian.
        // Yes, I did bl to the middle of a function. :P
        bl      .Ltest.entry
        // Reload the length, as test clobbered it.
        ldr     r1, [sp]
        // Byteswap the string.
        movs    r2, r1
.Lbswap_loop:
        subs    r2, #2
        ldrh    r4, [r0, r2]
        rev16   r4, r4
        strh    r4, [r0, r2]
        bne     .Lbswap_loop
.Lbswap_loop.end:
        // Negate r3
        negs    r3, r3
        // and call test again to check big endian
        bl      .Ltest.entry
        pop     {r1, r4-r7, pc}

.Lconst.SURROGATE_OFFSET:
        // Optimized constprop from utfcpp
        // 0x10000 - (LEAD_SURROGATE_MIN << 10) - TRAIL_SURROGATE_MIN
        .word 0xfca02400

.Ltest_loop:
        // Read the next character
        ldrh    r4, [r0, r1]
        // Check for FDD0-FDEF.
        // First we subtract 0xFDD0...
        movw    r6, #0xFDD0
        subs    r7, r4, r6
        // ...and if it is (unsigned) less than 0x20, it is
        // bad. Set the bad bit.
        // We need to keep going because we actually byteswap as we
        // process each halfword.
        cmp     r7, #0x20
        blo     .Lfalse

        // Is it a surrogate?
        // Equivalent to (r4 & 0xF800) != 0xD800
        lsrs    r7, r4, #11
        cmp     r7, #0xD800 >> 11
        bne     .Lnot_surrogate
.Lis_surrogate:
        // Beginning of string == unpaired surrogate
        cbz     r1, .Lfalse
        // Decrement r1
        subs    r1, #2

        // Is it a trail surrogate? We already know it is
        // a surrogate, so we only check the trail bit.
        // Uses lsrs's carry flag to test the 10th bit.
        // Equivalent to (r4 & 0x400) == 0
        lsrs    r7, r4, #11
        bcc     .Lfalse

        // Read the preceeding (hopefully) surrogate.
        ldrh    r2, [r0, r1]
        // Is it a lead surrogate?
        // Equivalent to ((r4 & 0xFC00) != 0xD800)
        lsrs    r7, r2, #10
        cmp     r7, #0xD800 >> 10
        bne     .Lfalse

        // Add the lead surrogate and the offset and put
        // it in r6.
        add.w   r6, r5, r2, lsl #10
        // Merge surrogate pair
        adds    r4, r6
.Lnot_surrogate:
        // Check for xxFFFE/F by sign extending and adding 2.
        // If it was, there will be a carry.
        sxth    r7, r4
        adds    r7, #2
        bcs     .Lfalse

        .thumb_func
        // We actually bl here, so we can subtract first
        // on the first iteration.
.Ltest.entry:
        // Loop while we still have data.
        subs    r1, #2
        bpl     .Ltest_loop
.Ltrue:
        // Subtract 1 for true.
        subs    r3, #1
.Lfalse:
        // return
        bx      lr
