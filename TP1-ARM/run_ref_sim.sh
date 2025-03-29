#!/bin/bash

# direct_method() {
#     input_file="$1"
#     (./ref_sim_x86 "inputs/$input_file")
# }

# direct_method "$1"

process_file() {
    input_file="$1"
    base_name=$(basename "$input_file" .s)
    echo "Processing file: $input_file"
    echo "Base name: $base_name"
    ./2hex.sh "$input_file"
    ./ref_sim_x86 "$base_name.x"
}

process_file "$1"