        .syntax unified
        .arch armv6t2
        // We need VFPv2 for this.
        .fpu vfpv2
        // We modify an inline string in place, so we need W+X.
        .section ".writeable_text","awx",%progbits
        .thumb
        .globl silly_stocks
        .thumb_func
        // Must NOT be 4 byte aligned.
        // This 2 byte nop is not part of the score, it is to make the compiler
        // properly align the function.
        .align 4
        nop

        // void silly_stocks(const char *input);
        // Follows AAPCS convention.
        // input is a null-terminated string in r0.
silly_stocks:
        push          {r3-r7, lr}
        // double buf[26] = {0}
        movs          r1, #0
        movs          r2, #26*2
.Lclear_loop:
        subs          r2, #1
        push          {r1}
        bhi           .Lclear_loop
.Lclear_loop_end:
        // note: r1 and r2 are zero at this point
        // r1:r2 = 0x4049000000000000 = 50.0 double
        movt           r2, #0x4049
        vmov           d0, r1, r2
        vldr           d1, .Lfloat_pool
.Lprocess_loop:
        // Loop until the null terminator.
        // while (r2 = *input++)
        ldrb          r2, [r0], #1
        cbz           r2, .Lprocess_loop_end
        // tolower(r2) - 'a'
        //
        // Specifically, we subtract 'a', and if the char was uppercase,
        // it would be negative, triggering the N flag, which is why we
        // check the mi condition in the following IT blocks.
        subs          r2, #'a'
        it            mi
        // if (isupper(r2))
          addmi       r2, #'a' - 'A'

        // Yucky. We can't use proper offsetting with VFP and we need to
        // keep the flags for the IT block.
        add.w         r2, sp, r2, lsl #3
        // Behold, the beautiful syntax of VFP/NEON.
        // Combine it with a an IT block and you get a 10 letter mnemonic. OwO
        vldr.64       d5, [r2]
        ittee         mi
        // if (isupper(r2)) {    // Buy
          vsubmi.f64  d5, d5, d0 //   profit[i]   -= d0
          vmlami.f64  d0, d0, d1 //   stock_price += stock_price * 0.05
        // } else {              // Sell
          vaddpl.f64  d5, d5, d0 //   profit[i]   += stock_price
          vmlspl.f64  d0, d0, d1 //   stock_price -= stock_price * 0.05
        // } endif
        vstr.64       d5, [r2]
        b             .Lprocess_loop
.Lprocess_loop_end:

        movs          r6, #'A'
.Lprint_loop:
        // Pop the double into r2 and r3. We are using the softfp abi, so
        // doubles are passed in integer registers.
        pop           {r2, r3}
        // Only check if the most signicant half of the double is zero.
        // Any non-zero double that is 0x00000000xxxxxxxx is denormal.
        cbz           r3, .Lprint_loop_skip
        // Set up an AEABI call to printf.
        adr           r0, .Lprintf_str
        // Instead of %c, store the char directly (that's why we need W+X)
        strb          r6, [r0]
        bl            printf
.Lprint_loop_skip:
        // Loop from A-Z.
        adds          r6, #1
        cmp           r6, #'Z'
        ble           .Lprint_loop
        pop           {r3-r7, pc}
        // At least for the softfp ABI, doubles are smaller than floats.
        // This is because printf takes doubles, not floats, and we need
        // to pass them in a register pair.
        // So we would need something like this, which is 12 bytes.
        //  vpop         {d0}
        //  vcvt.f64.f32 d0, s0
        //  vmov         r2, r3, d0
        .align 2
.Lfloat_pool:
        .double       0.05
.Lprintf_str:
        // Our printf string. We modify X directly.
        .asciz        "X%.2f"