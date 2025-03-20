#ifndef _SIM_H_
#define _SIM_H

#include "shell.h"
#include <stdint.h>

typedef enum {
    INST_ARITH,     // Instrucciones aritméticas (ADDS, SUBS, ADD)
    INST_LOGIC,     // Instrucciones lógicas (ANDS, EOR, ORR)
    INST_BRANCH,    // Instrucciones de salto (B, BEQ, BNE, BGT, etc.)
    INST_LOAD_STORE,// Instrucciones LDUR/STUR y variantes
    INST_SHIFT,     // Instrucciones LSL, LSR
    INST_HLT,       // Instrucción HLT
    INST_MOVE,      // Instrucción MOVZ
    INST_COMP,      // Instrucciones de comparación (CMP, CBZ, CBNZ)
    INST_UNKNOWN    // Tipo desconocido
} inst_type_t;

typedef struct {
    uint32_t raw;           // Instrucción original sin decodificar
    inst_type_t type;       // Tipo de instrucción
    uint8_t rd;             // Registro destino
    uint8_t rn;             // Registro operando 1
    uint8_t rm;             // Registro operando 2
    int32_t imm;            // Valor inmediato
    uint8_t shift_amount;   // Cantidad de desplazamiento
    uint8_t cond;           // Código de condición para B.cond
} instruction_t;

instruction_t decode_instruction(uint32_t inst);
void execute_instruction(instruction_t inst);
void process_instruction(); // Requerida por shell.h
void flags_updater();

#endif