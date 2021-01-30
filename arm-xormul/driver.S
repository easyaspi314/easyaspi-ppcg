	.syntax unified
	.arch armv7-a
	.fpu neon
	.thumb
	.globl xormul_boring_neon
	.thumb_func
xormul_boring_neon:
	push	{r4, lr}
	vmov.u8	d0[0], r0
	vmov.u8	d1[0], r1
	bl	.xormul_boring_neon
	vmov.u16 r0, d0[0]
	pop	{r4, pc}

	.thumb
	.globl xormul_scalar
	.thumb_func
xormul_scalar:
	push	{r4, lr}
	bl	.xormul_scalar
	movs	r0, r3
	pop	{r4, pc}

