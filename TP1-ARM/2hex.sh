#!/bin/bash

cd inputs
for file in "$@"
do
    ./asm2hex "$file"
done