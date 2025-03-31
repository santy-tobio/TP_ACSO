#include <stdio.h>
#include <stdint.h>
#include "shell.h"
#include "decode.h"
#include "sim.h"

// Decodificar un registro Rd (destino) - bits 0-4
uint32_t decode_rd(uint32_t instruction) {
    return extract_bits(instruction, 0, 4);
}

// Decodificar un registro Rn (operando 1) - bits 5-9
uint32_t decode_rn(uint32_t instruction) {
    return extract_bits(instruction, 5, 9);
}

// Decodificar un registro Rm (operando 2) - bits 16-20
uint32_t decode_rm(uint32_t instruction) {
    return extract_bits(instruction, 16, 20);
}

// Decodificar un immediate de 6 bits (immr) para LSL y LSR - bits 16-21
uint32_t decode_immr(uint32_t instruction) {
    return extract_bits(instruction, 16, 21);
}

// Decodificar un inmediato de 12 bits (imm12) - bits 10-21
int32_t decode_imm12(uint32_t instruction) {
    return extract_bits(instruction, 10, 21);
}

// Decodificar un inmediato de 19 bits (imm19) - bits 5-23
int32_t decode_imm19(uint32_t instruction) {
    return extract_bits(instruction, 5, 23);
}

// Decodificar un valor de shift - bits 22-23
uint32_t decode_shift(uint32_t instruction) {
    return extract_bits(instruction, 22, 23);
}

// Decodificar un immediate de 16 bits (imm16) para MOVZ - bits 5-20
uint32_t decode_imm16(uint32_t instruction) {
    return extract_bits(instruction, 5, 20);
}

// Decodificar un immediate de 26 bits (imm16) para B - bits 0-25
uint32_t decode_imm26(uint32_t instruction) {
    return extract_bits(instruction, 0, 25);
}

// Decodificar un offset para instrucciones de memoria - bits 12-20
int32_t decode_mem_offset(uint32_t instruction) {
    return extract_bits(instruction, 12, 20);
}

// Decodificar un código condicional para B.cond - bits 0-3
uint32_t decode_condition(uint32_t instruction) {
    return extract_bits(instruction, 0, 3);
}