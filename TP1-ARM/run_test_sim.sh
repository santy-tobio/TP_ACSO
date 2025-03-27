#!/bin/bash

direct_method() {
    input_file="$1"
    (cd src && make && cd .. && src/sim "inputs/$input_file")
}

direct_method "$1"
