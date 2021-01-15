echo "DISCLAIMER: The rules DID say \"separators not required\", and I take that quite literally."

do_test()
{
    run_executable $1
    printf "\nExpected: %s \n" "$2"
    # TODO: fix this
    # if [ "$2" = "$OUTPUT" ]; then
    #     printf " -> OK\n"
    # else
    #     printf " -> FAIL!!!\n"
    # fi
}

do_test "AABaBbba" "A7.49B2.47"
# Note that the default printf rounding in Bionic libc causes this to be -0.12.
# This is considered to be OK by the rules.
# However, glibc seems to round it correctly.
do_test "DGdg" "D5.13G-0.13"
do_test "ADJdja" "A2.24D5.38J-0.14"