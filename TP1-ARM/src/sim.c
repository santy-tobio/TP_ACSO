#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "sim.h"
#include "shell.h"
#include "execute.h"
#include "decode.h"

// hacemos shifts por largos de opcode
// muy similar la decodificación de adds a la de subs
// ADDS y SUBS tienen mal el bit 21, debería ser 0 en vez de 1
// load en pagina 637

// ADDS (1) PÁGINA 531

#define ADDS_INMEDIATE_OPCODE 0xB1 // 8 bits
#define ADDS_EXTENDED_REGISTER_OPCODE 0x558 // 11 bits

// SUBS (2)

#define SUBS_INMEDIATE_OPCODE 0xF1 // 8 bits
#define SUBS_EXTENDED_REGISTER_OPCODE 0x758 // 11 bits

// HALT (3) PÁGINA 628

#define HALT_OPCODE 0x6a2 // 11 bits

// CPM (4) PÁGINA 589
// ! Probablemente redundante? es equivalente a SUBS
#define CMP_INMEDIATE_OPCODE 0xF1 // 8 bits
#define CMP_EXTENDED_REGISTER_OPCODE 0x758 // 11 bits

// ANDS (5) PÁGINA 542

#define ANDS_SHIFTED_REGISTER_OPCODE 0xEA // 8 bits

// EOR (6) PÁGINA 620

#define EOR_SHIFTED_REGISTER_OPCODE 0xCA // 8 bits

// ORR (7) PÁGINA 792

#define ORR_SHIFTED_REGISTER_OPCODE 0xAA // 8 bits

// B (8) PÁGINA 550

#define B_OPCODE 0x5 // 6 bits

// BR (9) página 562

#define BR_OPCODE 0x3587C0 // 22 bits

// BEQ (10) página 549

#define BEQ_OPCODE 0x54 // 8 bits

// BEQ (10)  -- 0000
// BNE (11)  -- 0001
// BGT (12)  -- 1100
// BLT (13)  -- 1011
// BGE (14)  -- 1010
// BLE (15)  -- 1101


// =================================
// LSL (16) página 754
#define LSL_OPCODE 0x34D // 10 bits

// LSR (17) página 757
#define LSR_OPCODE 0x34D // 10 bits
// =================================

// STUR (18) página 917
#define STUR_OPCODE 0x7C0 // 11 bits

// STURB (19) página 918
#define STURB_OPCODE 0x1C0 // 11 bits opcode start 21

// STURH (20) página 919
#define STURH_OPCODE 0x3C0 // 11 bits opcode start 21

// LDUR (21) página 739
#define LDUR_OPCODE 0x7C2 // 11 bits

// LDURH (22) página 742
#define LDURH_OPCODE 0x3C2 // 11 bits opcode start 21

// LDURB  (23) página 741
#define LDURB_OPCODE 0x1C2 // 11 bits opcode start 21

// MOVZ (24) página 770
#define MOVZ_OPCODE 0x1A5 // 9 bits

// ADD (inmediate) (25) página 525
#define ADD_INMEDIATE_OPCODE 0x91 // 8 bits

// ADD (extended register) (26) página 523
#define ADD_EXTENDED_REGISTER_OPCODE 0x459 // 11 bits

// MUL (27) página 778
#define MUL_OPCODE 0x4D8 // 11 bits

// CBZ (28) página 574
#define CBZ_OPCODE 0xB4 // 8 bits

// CBNZ (29) página 573
#define CBNZ_OPCODE 0xB5 // 8 bits


uint32_t extract_bits(uint32_t instruction, int start, int end) {
    // 'start' y 'end' son inclusivos, con 0 siendo el bit menos significativo
    // shiftea 'start' bits a la derecha y luego aplicar una máscara de 'end - start + 1' bits
    if (start > end || start < 0 || end > 31) { //! Tirar error
        printf("ERROR: extract_bits: start > end o start o end fuera de rango\n");
        return 0;
    }

    uint32_t mask = (1 << (end - start + 1)) - 1;
    return (instruction >> start) & mask;
}

void print_bits(uint32_t instruction) {
    for (int i = 31; i >= 0; i--) {
        printf("%d", (instruction >> i) & 1);
        if (i % 4 == 0) {
            printf(" ");
        }
    }
    printf("\n");
}

void process_instruction() {

    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);
    decode_and_execute_instruction(instruction);
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
    NEXT_STATE.REGS[31] = 0;
}

void decode_and_execute_instruction(uint32_t instruction) {
    uint32_t opcode6 = extract_bits(instruction, 26, 31); // Opcode de 6 bits (bits 26-31)
    uint32_t opcode8 = extract_bits(instruction, 24, 31); // Opcode de 8 bits (bits 24-31)
    uint32_t opcode9 = extract_bits(instruction, 23, 31);  // Opcode de 9 bits (bits 23-31)
    uint32_t opcode10 = extract_bits(instruction, 22, 31); // Opcode de 10 bits (bits 22-31)
    uint32_t opcode11 = extract_bits(instruction, 21, 31); // Opcode de 11 bits (bits 21-31)
    uint32_t opcode22 = extract_bits(instruction, 10, 31); // Opcode de 22 bits (bits 10-31)

    // Verificamos opcodes de 22 bits
    if (opcode22 == BR_OPCODE) {
        execute_br(instruction);
        return;
    }
    
    // Verificamos opcodes de 11 bits
    switch (opcode11) {
        case HALT_OPCODE:
            execute_halt(instruction);
            return;
        case ADDS_EXTENDED_REGISTER_OPCODE:
            execute_adds_extended_register(instruction);
            return;
        case SUBS_EXTENDED_REGISTER_OPCODE:
            execute_subs_extended_register(instruction);
            return;
        // case CMP_EXTENDED_REGISTER_OPCODE:
        //     execute_cmp_extended_register(instruction);
        //     return;
        case STUR_OPCODE:
            execute_stur(instruction);
            return;
        case STURB_OPCODE:
            execute_sturb(instruction);
            return;
        case STURH_OPCODE:
            execute_sturh(instruction);
            return;
        case LDUR_OPCODE:
            execute_ldur(instruction);
            return;
        case LDURH_OPCODE:
            execute_ldurh(instruction);
            return;
        case LDURB_OPCODE:
            execute_ldurb(instruction);
            return;
        case ADD_EXTENDED_REGISTER_OPCODE:
            printf("ENTRO EN ADD_EXTENDED_REGISTER_OPCODE\n");
            execute_add_extended_register(instruction);
            return;
        case MUL_OPCODE:
            printf("ENTRO EN MUL_OPCODE\n");
            execute_mul(instruction);
            return;
    }

    // Verificrmos opcodes de 10 bits
    switch (opcode10) {
        case LSL_OPCODE:
        // Diferenciar entre LSL y LSR mediante el bit 15
        uint32_t is_right = extract_bits(instruction, 10, 15) == 0b111111;
        if (is_right) {
            execute_lsr(instruction);
        } else {
            execute_lsl(instruction);
        }
        return;
    }

    // Verificarmos opcodes de 9 bits
    switch (opcode9) {
        case MOVZ_OPCODE:
            execute_movz(instruction);
            return;
    }

    // Verificarmos opcodes de 8 bits
    switch (opcode8) {
        case ADDS_INMEDIATE_OPCODE:
            execute_adds_immediate(instruction);
            return;
        case SUBS_INMEDIATE_OPCODE:
            // if (decode_rd(instruction) == 0b11111) {
            //     execute_cmp_immediate(instruction);
            // }
            // else {
            //     execute_subs_immediate(instruction);
            // }
            execute_subs_immediate(instruction);
            return;
        case ANDS_SHIFTED_REGISTER_OPCODE:
            execute_ands_shifted_register(instruction);
            return;
        case ORR_SHIFTED_REGISTER_OPCODE:
            execute_orr_shifted_register(instruction);
            return;
        case EOR_SHIFTED_REGISTER_OPCODE:
            execute_eor_shifted_register(instruction);
            return;
        case BEQ_OPCODE:
            execute_bcond(instruction);
            return;
        case CBZ_OPCODE:
            execute_cbz(instruction);
            return;
        case CBNZ_OPCODE:
            execute_cbnz(instruction);
            return;
        case ADD_INMEDIATE_OPCODE:
            printf("ENTRO EN ADD_INMEDIATE_OPCODE\n");
            execute_add_immediate(instruction);
            return;
    }

    // Verificarmos opcodes de 6 bits
    switch (opcode6) {
        case B_OPCODE:
            execute_b(instruction);
            return;
    }

    // Si no se encontró el opcode, tirar error
    printf("ERROR: Opcode no encontrado\n");
    assert(0);
}
