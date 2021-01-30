	.syntax unified
	.arch armv7-a
	.fpu neon
	.thumb
	.section ".text.xormul_boring_neon", "ax", %progbits
	.globl .xormul_boring_neon
	.thumb_func
.xormul_boring_neon:
	// q0[0-8] = d0[0-8] @ d1[0-8]
	vmull.p8 q0, d0, d1
	bx	lr


	.section ".text.xormul_scalar", "ax", %progbits
	.globl .xormul_scalar
	.thumb_func
.xormul_scalar:
	// acc -> 0
	movs	r3, #0
.Lloop:
	// test each bit in y by using lsrs carry-out
	lsrs	r1, r1, #1
	// was the bit set?
	it	cs
	// if so, acc ^= x
	eorcs	r3, r0
	// shift x left
	lsls	r0, r0, #1
	// loop while non zero
	bne	.Lloop
.Lend:
	// return in r3
	bx	lr
