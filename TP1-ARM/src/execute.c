#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "sim.h"
#include "shell.h"

// '0000 0000 0000 0000  0000 0000 0000 0000'

// Máscaras para ADDS inmediato

#define ADDS_INMEDIATE_SHIFT_MASK 0xC00000
#define ADDS_INMEDIATE_IMM12_MASK 0x3FFC00
#define ADDS_INMEDIATE_RD_MASK 0x1F
#define ADDS_INMEDIATE_RN_MASK 0x3E0

// Máscaras para ADDS extendido

void addsInmediate(uint32_t instruction)
{
    uint32_t shift = instruction & ADDS_INMEDIATE_SHIFT_MASK >> 22; 
    uint32_t imm12 = instruction & ADDS_INMEDIATE_IMM12_MASK >> 10;
    uint32_t rn = instruction & ADDS_INMEDIATE_RN_MASK >> 5; 
    uint32_t rd = instruction & ADDS_INMEDIATE_RD_MASK ;

    if (shift == 01) 
    {
        imm12 = imm12 << 12;
        imm12 = zeroExtend(imm12, 64);
    }
    else if (shift == 00)
    {
        imm12 = zeroExtend(imm12, 64);
    }

    // hay que testear esta implementacion !! tamibén testear el zeroExtend

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] + imm12;
    NEXT_STATE.FLAG_N = (NEXT_STATE.REGS[rd] < 0); // esto lo toman en binario?
    NEXT_STATE.FLAG_Z = (NEXT_STATE.REGS[rd] == 0);
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

int64_t zeroExtend(uint32_t value, int bits)
{
    int64_t mask = 0;
    for (int i = 0; i < bits; i++)
    {
        mask = mask << 1;
        mask = mask | 1;
    }
    return value & mask;
}