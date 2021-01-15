#!/bin/bash

set -e

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

print_and_run()
{
    printf "$ "
    for i in $@; do
        printf "\"%s\" " "$i"
    done
    printf "\n"
    eval $@
}

run_executable()
{
    [ -n "$STDIN" ] && printf "STDIN: '%s'\n" "$STDIN"
    printf "Command line args: "
    printf "%s" "$STDIN" | print_and_run $QEMU ./a.out $@

    echo "Return code: $?"
}


echo "Installing dependencies..." 
travis_fold start "runtest.apt"
print_and_run sudo apt-get update
print_and_run sudo apt-get install -y gcc-$TRIPLE clang qemu-user-static libc6-dev-$LIBC-cross
travis_fold end "runtest.apt"

cd $1
echo "Source code:"
travis_fold start "sourcecode"
print_and_run cat file.S
travis_fold end "sourcecode"

# I prefer Clang's assembler, it is a little more flexible than GAS.
print_and_run clang --target=$TRIPLE -c file.S -o file.o
echo "Object file info:"
travis_fold start "objinfo"
# Show details about the object file
print_and_run $TRIPLE-size -A file.o
print_and_run $TRIPLE-objdump -d file.o
travis_fold end "objinfo"
echo "Compiling test suite"

LDFLAGS=

# If we have _start as a symbol, we will compile without the stdlib.
if [ $($TRIPLE-nm -g file.o | grep -s _start) ]; then
    LDFLAGS="$LDFLAGS -nostdlib -ffreestanding"
fi

# Link file.o, optionally with a driver.c or driver.S if it exists.
print_and_run $TRIPLE-gcc -static $LDFLAGS $(compgen -G 'driver.[cS]' || true) file.o -o a.out

# Disable error failing and command printing
set +e

echo Running tests...
# Run the tests.
if [ -f run.sh ]; then
    . run.sh
else
    # If run.sh doesn't exist, just call ./a.out.
    run_executable
fi