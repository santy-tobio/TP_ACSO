#include <stdio.h>
#include <stdint.h>
#include "shell.h"
#include "decode.h"
#include "execute.h"
#include "sim.h"
#include <stdbool.h>

void adds_immediate(uint32_t instruction) {

    uint32_t shift = decode_shift(instruction);
    int32_t imm12 = decode_imm12(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rd = decode_rd(instruction);

    imm12 = zeroExtend_imm12(imm12, shift);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] + imm12;
    update_flags(NEXT_STATE.REGS[rd]);
}

void adds_extended_register(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] + CURRENT_STATE.REGS[rm];

    update_flags(NEXT_STATE.REGS[rd]);
}

void subs_immediate(uint32_t instruction) {

    uint32_t shift = decode_shift(instruction);
    uint32_t imm12 = decode_imm12(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rd = decode_rd(instruction);

    imm12 = zeroExtend_imm12(imm12, shift);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] - imm12;
    update_flags(NEXT_STATE.REGS[rd]);
}

void subs_extended_register(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] - CURRENT_STATE.REGS[rm];

    update_flags(NEXT_STATE.REGS[rd]);
}

void hlt(uint32_t instruction) {RUN_BIT = 0;}

void ands_shifted_register(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] & CURRENT_STATE.REGS[rm];

    update_flags(NEXT_STATE.REGS[rd]);
}

void eor_shifted_register(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] ^ CURRENT_STATE.REGS[rm];
}

void orr_shifted_register(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] | CURRENT_STATE.REGS[rm];
}

void movz(uint32_t instruction) {

    uint32_t imm16 = decode_imm16(instruction);
    uint32_t rd = decode_rd(instruction);

    NEXT_STATE.REGS[rd] = imm16;
}

void b(uint32_t instruction) {

    uint32_t imm26 = decode_imm26(instruction); // inmediato que indica cuanto saltar

    // -4 para que se cancele con el +4 del process_instruction()
    CURRENT_STATE.PC = CURRENT_STATE.PC + imm26 * 4 - 4;
}

void br(uint32_t instruction) {

    uint32_t rn = decode_rn(instruction);

    CURRENT_STATE.PC = CURRENT_STATE.REGS[rn] - 4;
}

void bcond(uint32_t instruction) {

    uint32_t condition = decode_condition(instruction);
    uint32_t imm19 = decode_imm19(instruction);

    // Evalua la condicion en base a los flags
    if (evaluate_condition(condition, CURRENT_STATE.FLAG_N, CURRENT_STATE.FLAG_Z)) {
        CURRENT_STATE.PC = CURRENT_STATE.PC + imm19 * 4 - 4;
    }
}

void ls(uint32_t instruction) {
    // Diferencia entre LSL y LSR mediante el imms
    uint32_t is_right = extract_bits(instruction, 10, 15) == 0b111111;
    if (is_right) { lsr(instruction); }
    else          { lsl(instruction); }
}

void lsl(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t immr = decode_immr(instruction);

    // Para LSL, el valor de desplazamiento es (-immr) % 64
    uint32_t shift = (-immr) % 64;

    // Ahora hacemos el desplazamiento correcto
    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] << shift;
}

void lsr(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t immr = decode_immr(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] >> immr;
}

void stur(uint32_t instruction) {

    uint32_t rt = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    int32_t offset = decode_mem_offset(instruction);

    uint64_t address = CURRENT_STATE.REGS[rn] + offset;
    mem_write_32(address, CURRENT_STATE.REGS[rt]);
}

void sturb(uint32_t instruction) {

    uint32_t rt = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    int32_t offset = decode_mem_offset(instruction);

    uint64_t address = (CURRENT_STATE.REGS[rn] + offset);
    uint32_t value = CURRENT_STATE.REGS[rt] & 0xFF;
    mem_write_32(address, value);
}

void sturh(uint32_t instruction) {
    uint32_t rt = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    int32_t offset = decode_mem_offset(instruction);

    uint64_t address = (CURRENT_STATE.REGS[rn] + offset);
    uint32_t value = CURRENT_STATE.REGS[rt] & 0xFFFF;
    mem_write_32(address, value);
}

void ldur(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    int32_t offset = decode_mem_offset(instruction);
    uint64_t address = CURRENT_STATE.REGS[rn] + offset;

    NEXT_STATE.REGS[rd] = mem_read_32(address);
}

void ldurb(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    int32_t offset = decode_mem_offset(instruction);
    uint64_t address = CURRENT_STATE.REGS[rn] + offset;

    NEXT_STATE.REGS[rd] = mem_read_32(address) & 0xFF;
}

void ldurh(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    int32_t offset = decode_mem_offset(instruction);
    uint64_t address = CURRENT_STATE.REGS[rn] + offset;

    NEXT_STATE.REGS[rd] = mem_read_32(address) & 0xFFFF;
}

void add_immediate(uint32_t instruction) {

    uint32_t shift = decode_shift(instruction);
    int32_t imm12 = decode_imm12(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rd = decode_rd(instruction);

    imm12 = zeroExtend_imm12(imm12, shift);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] + imm12;
}

void add_extended_register(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] + CURRENT_STATE.REGS[rm];
}

void mul(uint32_t instruction) {

    uint32_t rd = decode_rd(instruction);
    uint32_t rn = decode_rn(instruction);
    uint32_t rm = decode_rm(instruction);

    NEXT_STATE.REGS[rd] = CURRENT_STATE.REGS[rn] * CURRENT_STATE.REGS[rm];
}

void cbz(uint32_t instruction) {

    uint32_t imm19 = decode_imm19(instruction);
    uint32_t rn = decode_rd(instruction);

    if (CURRENT_STATE.REGS[rn] == 0) {
        CURRENT_STATE.PC = CURRENT_STATE.PC + imm19 * 4 - 4;
    }
}

void cbnz(uint32_t instruction) {

    uint32_t imm19 = decode_imm19(instruction);
    uint32_t rn = decode_rd(instruction);

    if (CURRENT_STATE.REGS[rn] != 0) {
        CURRENT_STATE.PC = CURRENT_STATE.PC + imm19 * 4 - 4;
    }
}


void update_flags(int64_t result) {
    NEXT_STATE.FLAG_N = (result < 0) ? 1 : 0;
    NEXT_STATE.FLAG_Z = (result == 0) ? 1 : 0;
}

int64_t zeroExtend(uint32_t value, int bits) {
    int64_t mask = 0;
    for (int i = 0; i < bits; i++) {
        mask = mask << 1;
        mask = mask | 1;
    }
    return value & mask;
}

int64_t zeroExtend_imm12(uint32_t imm12, uint32_t shift) {
    if (shift == 1) {
        imm12 = imm12 << 12;
        imm12 = zeroExtend(imm12, 64);
    }
    else if (shift == 00) {
        imm12 = zeroExtend(imm12, 64);
    }
    return imm12;
}

bool evaluate_condition(uint32_t condition, int flag_n, int flag_z) {
    switch (condition) {
        case 0b0000: // BEQ - Equal
            return flag_z == 1;
        case 0b0001: // BNE - Not Equal
            return flag_z == 0;
        case 0b1100: // BGT - Greater Than
            return flag_n == 0 && flag_z == 0;
        case 0b1011: // BLT - Less Than
            return flag_n == 1;
        case 0b1010: // BGE - Greater Than or Equal
            return flag_n == 0;
        case 0b1101: // BLE - Less Than or Equal
            return flag_z == 1 || flag_n == 1;
        default:
            return false;
    }
}