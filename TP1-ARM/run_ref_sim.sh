#!/bin/bash

direct_method() {
    input_file="$1"
    (./ref_sim_x86 "inputs/$input_file")
}

direct_method "$1"
