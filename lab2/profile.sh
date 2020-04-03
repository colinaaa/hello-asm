#!/bin/bash
CCFLAG="-O2 -ggdb -nostdlib -m32 -no-pie"

echo "Deal with source file: $1"
src=""${1%%.*}""

echo "Cleaning up aux files..."
make clean &>/dev/null

echo "Build executable $src with flag $CCFLAG"
gcc $CCFLAG -o $src $1

function do_runtime() {
  echo "running $src with runtime_$1"
  ./$src <runtime_$1 | grep -o -E '[0-9]+' | perl -nle '$sum += $_ } END { print "$sum(ns)"'
}

function do_valgrind() {
  echo "using valgrind to simulate and profile..."
  valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes --collect-systime=yes ./$src &>/dev/null

  fd --regex "callgrind.out.[0-9]+" | callgrind_annotate --auto=yes >$src.profile

  less $src.profile
}

if [[ $2 == "valgrind" ]]; then
  do_valgrind
fi

if [[ $2 == "runtime" ]]; then
  do_runtime 1000
  do_runtime 10000
fi
