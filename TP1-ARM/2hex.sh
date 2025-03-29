#!/bin/bash

# cd inputs
# for file in "$@"
# do
#     ./asm2hex "$file"
# done

for file in "$@"
do
    inputs/asm2hex "inputs/$file"
done