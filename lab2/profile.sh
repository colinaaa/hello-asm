#!/bin/bash
CCFLAG="-O2 -Wa,--gstabs -save-temps -ggdb -nostdlib -m32 -no-pie"

echo "Deal with source file: $1"
src=""${1%%.*}""

echo "Cleaning up aux files..."
make clean &> /dev/null

echo "Build executable $src with flag $CCFLAG"
gcc $CCFLAG -o $src $1

valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes --collect-systime=yes ./$src

fd --regex "callgrind.out.[0-9]+" | callgrind_annotate --auto=yes > $src.profile

echo "Profile result writes to $src.profile! Check it out."
