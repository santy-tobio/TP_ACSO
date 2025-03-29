#ifndef _SIM_H_
#define _SIM_H

#include "shell.h"
#include <stdint.h>

uint32_t extract_bits(uint32_t instruction, int start, int end);
void decode_and_execute_instruction(uint32_t instruction);
void process_instruction(); // Requerida por shell.h
void flags_updater();

#endif