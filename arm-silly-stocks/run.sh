echo "DISCLAIMER: The rules DID say \"separators not required\", and I take that quite literally."

do_test()
{
    run_executable $1
    printf "\nExpected: %s " "$2"
    if [ "$2" = "$OUTPUT" ]; then
        printf " -> OK\n"
    else
        printf " -> FAIL!!!\n"
    fi
}

do_test "AABaBbba" "A7.49B2.47"
# Note that the default printf rounding causes this to be .12.
# This is considered to be OK by the rules
do_test "DGdg" "D5.13G-.12"
do_test "ADJdja" "A2.24D5.38J-.14"