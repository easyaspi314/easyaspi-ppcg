# Hacky Makefile driver.

arm-%: QEMU := qemu-arm-static -cpu cortex-a15
arm-%: TRIPLE := arm-linux-gnueabi
arm-%: LIBC := armel
aarch64-%: QEMU := qemu-aarch64-static -cpu cortex-a53
aarch64-%: TRIPLE := aarch64-linux-gnu
aarch64-%: LIBC := aarch64
mips-%: QEMU := qemu-mips-static
mips-%: TRIPLE := mips-linux-gnu
mips-%: LIBC := mips

# Any drivers that we need we can just compile when we link
C_DRIVERS := $(wildcard $(MAKECMDGOALS)/driver.[cS])

$(MAKECMDGOALS): %: %/a.out

%/a.out: %/file.o
	clang --target=$(TRIPLE) -static $< $(C_DRIVERS) -o $@
# - ignores exit code, as we don't really care about that in PPCG
	-printf "%s" "$(STDIN)" | $(QEMU) $@ $(ARGS); echo "exit code: $$?"

%/file.o: %/file.S packages
# clang's assembler > all :P
	clang --target=$(TRIPLE) -c $< -o $@
# Do a size -A and an objdump
	size -A $@
	$(TRIPLE)-objdump -d $@

.PHONY: packages
packages:
	@echo Installing dependencies...
	@sudo apt-get update -qq >/dev/null
	@sudo apt-get install -y -qq qemu-user-static libc6-dev-$(LIBC)-cross binutils-$(TRIPLE) >/dev/null
	