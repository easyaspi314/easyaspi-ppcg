        .syntax unified
        .arch armv6t2
        .text
        .thumb
        .globl check_utf16
        .thumb_func
        // r0: string, r1: len in BYTES
        // The string will be clobbered as an internal buffer.
        // Returns in r3.
check_utf16:
        push    {r1, r4, r7, lr}
        // Set starting return value to 0. This will accumulate both results.
        movs    r3, #0
        // First, check little endian.
        // Yes, I did bl to the middle of a function. :P
        bl      .Ltest.entry
        // Reload the length, as test clobbered it.
        ldr     r1, [sp]
        // Byteswap the string.
        movs    r2, r1
.Lbswap_loop:
        // Looping backwards...
        subs    r2, #2
        // Load a halfword to r4,
        ldrh    r4, [r0, r2]
        // do a 16-bit byteswap,
        rev16   r4, r4
        // and store it back.
        strh    r4, [r0, r2]
        bne     .Lbswap_loop
.Lbswap_loop.end:
        // Negate r3 to make the start return value from native endianness positive.
        // Then, we subtract the big endian version from this to get the -1/0/1 result.
        negs    r3, r3
        // and call test again to check big endian
        bl      .Ltest.entry
        pop     {r1, r4, r7, pc}

.Ltest_loop:
        // Read the next character
        ldrh    r4, [r0, r1]
        // Check for FDD0-FDEF.
        // First we subtract 0xFDD0...
        movw    r2, #0xFDD0
        subs    r7, r4, r2
        // ...and if it is (unsigned) less than 0x20, it is
        // bad. Return false.
        cmp     r7, #0x20
        blo     .Lfalse

        // Is it a surrogate?
        // Equivalent to (r4 & 0xF800) != 0xD800
        lsrs    r7, r4, #11
        cmp     r7, #0xD800 >> 11
        bne     .Lnot_surrogate

        // NOTE: We are looping backwards, that is why we check
        // trail surrogates first.
.Lis_surrogate:
        // Beginning of string == unpaired surrogate == bad
        cbz     r1, .Lfalse
        // Decrement r1
        subs    r1, #2

        // Is it a trail surrogate? We already know it is
        // a surrogate, so we only check the trail bit.
        // Uses lsrs's carry flag to test the 10th bit.
        // Equivalent to (r4 & 0x400) == 0
        lsrs    r7, r4, #11
        bcc     .Lfalse

        // Load the preceeding (hopefully) lead surrogate to r2.
        ldrh    r2, [r0, r1]
        // Is it a lead surrogate?
        // Equivalent to (r2 & 0xFC00) != 0xD800
        lsrs    r7, r2, #10
        cmp     r7, #0xD800 >> 10
        bne     .Lfalse

        // We have two surrogates, let's merge them into a
        // full codepoint.
        //
        // Just kidding. We only need the low 16 bits, so we can take
        // a huge shortcut and let sxth correct any overflow.
        //
        // utfcpp showed us that converting a UTF-16 pair to UTF-32
        // is simply this:
        //     0xfca02400 + trail + (lead << 10)
        //
        // 0x10000 - (LEAD_SURROGATE_MIN << 10) - TRAIL_SURROGATE_MIN
        //
        // Since we are only using 16 bits, we can just add 0x2400
        // instead. That saves 4 bytes, as we can do a wide add.
        //
        // HOWEVER, we can do even better: 0x2400 has the low 10 bits
        // clear, and since we need to shift the lead surrogate 10
        // bits to the left, we can just add 0x2400 >> 10 (or 0x09)
        // to the lead surrogate, then do trail + (lead << 10).
        //
        // This means that instead of generating a 32-bit constant
        // into a register, we can use the immediate narrow form of
        // adds, saving 6 bytes (4 for literal, 2 for ldr).
        adds    r2, #0x2400 >> 10
        add.w   r4, r4, r2, lsl #10
.Lnot_surrogate:
        // At this point, r4 contains the low 16 bits of the
        // codepoint, and the upper bits are garbage.

        // Check for xxFFFE/F by sign extending and adding 2.
        // If it was, there will be a carry.
        // The act of sign extending eliminates all of those
        // garbage bits for us, allowing laziness in the surrogate
        // code.
        sxth    r7, r4
        adds    r7, #2
        bcs     .Lfalse

        .thumb_func
        // We actually bl here, so we can subtract first
        // on the first iteration.
        // The possibilities of assembly are endless.
.Ltest.entry:
        // Loop while we still have data.
        subs    r1, #2
        bpl     .Ltest_loop
.Ltrue:
        // Subtract 1 for true. This is negated for native endianness, and it
        // cancels out on both true.
        subs    r3, #1
.Lfalse:
        // return
        bx      lr
