#ifndef _SIM_H_
#define _SIM_H

#include "shell.h"
#include <stdint.h>

uint32_t extract_bits(uint32_t instruction, int start, int end);
void decode_and_execute_instruction(uint32_t instruction);
void process_instruction(); // Requerida por shell.h

// Opcodes de las instrucciones ARMv8

// ADDS (1) PÁGINA 531
#define ADDS_INMEDIATE_OPC 0xB1 // 8 bits
#define ADDS_EXTENDED_REGISTER_OPC 0x558 // 11 bits

// SUBS (2)
#define SUBS_INMEDIATE_OPC 0xF1 // 8 bits
#define SUBS_EXTENDED_REGISTER_OPC 0x758 // 11 bits

// HALT (3) PÁGINA 628
#define HLT_OPC 0x6a2 // 11 bits

// CPM (4) PÁGINA 589
// Equivalente a SUBS

// ANDS (5) PÁGINA 542
#define ANDS_SHIFTED_REGISTER_OPC 0xEA // 8 bits

// EOR (6) PÁGINA 620
#define EOR_SHIFTED_REGISTER_OPC 0xCA // 8 bits

// ORR (7) PÁGINA 792
#define ORR_SHIFTED_REGISTER_OPC 0xAA // 8 bits

// B (8) PÁGINA 550
#define B_OPC 0x5 // 6 bits

// BR (9) página 562
#define BR_OPC 0x3587C0 // 22 bits

// BEQ (10) página 549
#define BCOND_OPC 0x54 // 8 bits

// BEQ (10)  -- 0000
// BNE (11)  -- 0001
// BGT (12)  -- 1100
// BLT (13)  -- 1011
// BGE (14)  -- 1010
// BLE (15)  -- 1101

// LSL (16) página 754
#define LS_OPC 0x34D // 10 bits

// LSR (17) página 757
#define LSR_OPC 0x34D // 10 bits

// STUR (18) página 917
#define STUR_OPC 0x7C0 // 11 bits

// STURB (19) página 918
#define STURB_OPC 0x1C0 // 11 bits

// STURH (20) página 919
#define STURH_OPC 0x3C0 // 11 bits

// LDUR (21) página 739
#define LDUR_OPC 0x7C2 // 11 bits

// LDURH (22) página 742
#define LDURH_OPC 0x3C2 // 11 bits

// LDURB  (23) página 741
#define LDURB_OPC 0x1C2 // 11 bits

// MOVZ (24) página 770
#define MOVZ_OPC 0x1A5 // 9 bits

// ADD (inmediate) (25) página 525
#define ADD_INMEDIATE_OPC 0x91 // 8 bits

// ADD (extended register) (26) página 523
#define ADD_EXTENDED_REGISTER_OPC 0x458 // 11 bits

// MUL (27) página 778
#define MUL_OPC 0x4D8 // 11 bits

// CBZ (28) página 574
#define CBZ_OPC 0xB4 // 8 bits

// CBNZ (29) página 573
#define CBNZ_OPC 0xB5 // 8 bits

#endif