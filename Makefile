# Install dependencies
# $(shell sudo apt-get install -y -qq clang-10 qemu-user-static >/dev/null)

arm-%: QEMU := qemu-arm-static -cpu cortex-a15
arm-%: TRIPLE := arm-linux-gnueabi
arm-%: LIBC := armel
aarch64-%: QEMU := qemu-aarch64-static -cpu cortex-a53
aarch64-%: TRIPLE := aarch64-linux-gnu
aarch64-%: LIBC := aarch64
mips-%: QEMU := qemu-mips-static
mips-%: TRIPLE := mips-linux-gnu
mips-%: LIBC := mips

$(MAKECMDGOALS): %: %/a.out

%/a.out: %/file.o
	$(TRIPLE)-gcc -static $< -o $@
	$(QEMU) $@ $(ARGS)
 
%/file.o: %/file.S packages
# clang's assembler > all :P
	clang --target=$(TRIPLE) -c $< -o $@
	size -A $@
	$(TRIPLE)-objdump -d $@

.PHONY: packages
packages:
	@echo Installing dependencies...
	sudo apt-get update && sudo apt-get install -y -qq clang-10 qemu-user-static libc6-dev-$(LIBC)-cross gcc-$(TRIPLE) >/dev/null
	