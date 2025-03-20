#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <sim.h>
#include <shell.h>

// '0000 0000 1100 0000  0000 0000 0000 0000'

#define MASK_ADD_SHIFT 0x00C00000

void addsInmediate(uint32_t instruction){

    uint32_t shift = instruction & MASK_ADD_SHIFT; 
    uint32_t imm12 = ;
    uint32_t rn; 
    uint32_t rd;


}