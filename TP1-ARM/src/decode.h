#ifndef DECODE_H
#define DECODE_H

#include <stdint.h>


uint32_t decode_rd(uint32_t instruction);
uint32_t decode_rn(uint32_t instruction);
uint32_t decode_rm(uint32_t instruction);
uint32_t decode_shift(uint32_t instruction);
uint32_t decode_immr(uint32_t instruction);
uint32_t decode_imms(uint32_t instruction);
int32_t decode_imm12(uint32_t instruction);
uint32_t decode_imm16(uint32_t instruction);
int32_t decode_imm19(uint32_t instruction);
uint32_t decode_imm26(uint32_t instruction);
uint32_t decode_shamt(uint32_t instruction);
int32_t decode_mem_offset(uint32_t instruction);
int32_t decode_branch_offset(uint32_t instruction);
uint32_t decode_condition(uint32_t instruction);

#endif