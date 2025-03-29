#!/bin/bash

# ./run_test_sim.sh inputs/file.s

# direct_method() {
#     input_file="$1"
#     modified_file="${input_file%.s}.x"
#     (cd src && make && cd .. && src/sim "inputs/$modified_file")
# }

# direct_method "$1"

direct_method() {
    input_file="$1"
    cd src
    make
    cd ..
    ./2hex "$input_file"
    modified_file="${input_file%.s}.x"
    src/sim "$modified_file"
}

# direct_method "$1"