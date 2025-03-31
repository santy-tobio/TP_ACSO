#ifndef EXECUTE_H
#define EXECUTE_H

#include <stdint.h>
#include <stdbool.h>

// Funciones auxiliares
void update_flags(int64_t result);
bool evaluate_condition(uint32_t condition, int flag_n, int flag_z);
int64_t zeroExtend(uint32_t value, int bits);
int64_t zeroExtend_imm12(uint32_t imm12, uint32_t shift);


// Funciones para ejecutar instrucciones
void adds_immediate(uint32_t instruction);
void adds_extended_register(uint32_t instruction);
void subs_immediate(uint32_t instruction);
void subs_extended_register(uint32_t instruction);
void hlt(uint32_t instruction);
void ands_shifted_register(uint32_t instruction);
void eor_shifted_register(uint32_t instruction);
void orr_shifted_register(uint32_t instruction);
void b(uint32_t instruction);
void br(uint32_t instruction);
void bcond(uint32_t instruction);
void ls(uint32_t instruction);
void lsl(uint32_t instruction);
void lsr(uint32_t instruction);
void stur(uint32_t instruction);
void sturb(uint32_t instruction);
void sturh(uint32_t instruction);
void ldur(uint32_t instruction);
void ldurh(uint32_t instruction);
void ldurb(uint32_t instruction);
void movz(uint32_t instruction);
void add_immediate(uint32_t instruction);
void add_extended_register(uint32_t instruction);
void mul(uint32_t instruction);
void cbz(uint32_t instruction);
void cbnz(uint32_t instruction);

#endif