#!/bin/bash

# usage: ./run-test.sh folder-where-test-is
# First, install the correct tools for the job
case $1 in
arm-*)
    QEMU='qemu-arm-static -cpu cortex-a15'
    TRIPLE='arm-linux-gnueabi'
    LIBC='armel'
    ;;
aarch64-*)
    QEMU='qemu-aarch64-static -cpu cortex-a53'
    TRIPLE='aarch64-linux-gnu'
    LIBC='aarch64'
    ;;
mips-*)
    QEMU='qemu-mips-static'
    TRIPLE='mips-linux-gnu'
    LIBC='mips'
    ;;
*)
    echo "Unknown architecture!"
    exit 1
    ;;
esac

run_executable()
{
    [ -n "$STDIN" ] && printf "STDIN: '%s'\n" "$STDIN"
    printf "Command line args: ./a.out "
    for i in $@; do
        printf "\"%s\" " "$i"
    done

    eval $QEMU ./a.out $@
    echo "Return code: $?"
}
echo "Installing dependencies..." 
sudo apt-get update -y -qq >/dev/null
sudo apt-get install -y -qq gcc-$TRIPLE clang qemu-user-static libc6-dev-$LIBC-cross >/dev/null

set -x

cd $1
echo "Source code:"
cat file.S

# I prefer Clang's assembler, it is a little more flexible than GAS.
clang --target=$TRIPLE -c file.S -o file.o
echo "Object file info:"
# Show details about the object file
$TRIPLE-size -A file.o
$TRIPLE-objdump -d file.o
echo "Compiling test suite"

# If we have _start as a symbol, we will compile without the stdlib.
if [ $TRIPLE-nm -g file.o | grep -s _start ]; then
    LDFLAGS="$LDFLAGS -nostdlib -ffreestanding"
fi

# Link file.o, optionally with a driver.c or driver.S if it exists.
$TRIPLE-gcc -static $LDFLAGS "$(compgen -G 'driver.[cS]' || true)" file.o -o a.out
# Run the tests.
if [ -f run.sh ]; then
    . run.sh
else
    # If run.sh doesn't exist, just call ./a.out.
    run_executable
fi