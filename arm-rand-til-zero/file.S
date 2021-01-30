	.syntax unified
	.arch armv6t2 // technically ARMv4T compatible
	.thumb
	.globl _start
	.thumb_func
_start:
.Lloop:
	// It sucks that this takes the buffer in r0. :(
	// buf = sp
	mov	r0, sp
	// size = 1
	movs	r1, #1
	// flags = GRND_RANDOM | GRND_NOBLOCK = 3
	// 0 is preferred, but this allows us to cheat loading the getrandom
	// syscall which won't fit in a narrow movs.
	movs	r2, #3
	// getrandom = 0x180 = 3 << 7
	// no movw required
	// movw	r7, #0x180
	lsls	r7, r2, #7
	// getrandom(&x, 1, GRND_RANDOM | GRND_NOBLOCK)
	svc	#0

	// getrandom for sizes < 256 return 1 in r0, as long as it isn't
	// interrupted, blocked, or out of entropy, corner cases I don't care
	// about. :P

	// fd = stdout
	// movs	r0, #1
	// buf = sp
	mov	r1, sp
	// len = 1
	movs	r2, #1
	// write = 4
	movs	r7, #4

	// load the random byte returned by getrandom()
	// note: ldrb r5, [sp] is a wide instruction. :(
	ldrb	r5, [r1]

	// modulo 100 using subtraction loop
	// x %= 100
.Lmodloop:
	subs	r5, #100
	bhi	.Lmodloop
.Lmodloop.end:
	// note: this sets the zero flag which is preserved in syscalls
	adds	r5, #100

	// store the random byte mod 100 back to [r1]
	strb	r5, [r1]
	// write(1, &x, 1);
	svc	#0
	// syscalls preserve flags
	bne	.Lloop
.Lloop.end:
	// exit
	movs	r7, #1
	// exit(dontcare)
	svc	#0
