#!/bin/bash

travis_fold start "runtest.apt"
sudo apt update
sudo apt install -y nasm clang
travis_fold end "runtest.apt"

print_and_run()
{
    echo "$ $@"
    eval $@
}

print_and_run cat objc.mm
print_and_run clang++ objc.mm -o a.out -fmodules
print_and_run ./a.out
print_and_run cat t.
print_and_run nasm t.
print_and_run cat arm.s
print_and_run clang arm.s -o arm.o --target=arm-none-eabi -c
