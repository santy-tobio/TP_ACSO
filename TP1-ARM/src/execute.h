#ifndef EXECUTE_H
#define EXECUTE_H

#include <stdint.h>

// Función auxiliar para actualizar las banderas N y Z
void update_flags(int64_t result);

// Funciones para ejecutar instrucciones
void execute_adds_immediate(uint32_t instruction);
void execute_adds_extended_register(uint32_t instruction);
void execute_subs_immediate(uint32_t instruction);
void execute_subs_extended_register(uint32_t instruction);
void execute_halt(uint32_t instruction);
void execute_cmp_extended_register(uint32_t instruction);
void execute_cmp_immediate(uint32_t instruction);
void execute_ands_shifted_register(uint32_t instruction);
void execute_eor_shifted_register(uint32_t instruction);
void execute_orr_shifted_register(uint32_t instruction);
void execute_b(uint32_t instruction);
void execute_br(uint32_t instruction);
void execute_bcond(uint32_t instruction);
void execute_lsl(uint32_t instruction);
void execute_lsr(uint32_t instruction);
void execute_stur(uint32_t instruction);
void execute_sturb(uint32_t instruction);
void execute_sturh(uint32_t instruction);
void execute_ldur(uint32_t instruction);
void execute_ldurh(uint32_t instruction);
void execute_ldurb(uint32_t instruction);
void execute_movz(uint32_t instruction);
void execute_add_immediate(uint32_t instruction);
void execute_add_extended_register(uint32_t instruction);
void execute_mul(uint32_t instruction);
void execute_cbz(uint32_t instruction);
void execute_cbnz(uint32_t instruction);

#endif // EXECUTE_H