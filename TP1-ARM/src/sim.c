#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "sim.h"
#include "shell.h"
#include "execute.h"

// Definimos los tipos de instrucciones con sus respectivos opcodes

// Funcion de opcode de largo 6 y opcode de largo 6
const void (*OPC6_FUNCS[])(uint32_t) = {b};
const uint32_t OPC6_CODES[] = {B_OPC};

// Funciones de opcodes de largo 8 y opcodes de largo 8
const void (*OPC8_FUNCS[])(uint32_t) = {
    adds_immediate, subs_immediate, ands_shifted_register, orr_shifted_register,
    eor_shifted_register, bcond, cbz, cbnz, add_immediate};
const uint32_t OPC8_CODES[] = {
    ADDS_INMEDIATE_OPC, SUBS_INMEDIATE_OPC, ANDS_SHIFTED_REGISTER_OPC, ORR_SHIFTED_REGISTER_OPC,
    EOR_SHIFTED_REGISTER_OPC, BCOND_OPC, CBZ_OPC, CBNZ_OPC, ADD_INMEDIATE_OPC};

// Funcion de opcode de largo 9 y opcode de largo 9
const void (*OPC9_FUNCS[])(uint32_t) = {movz};
const uint32_t OPC9_CODES[] = {MOVZ_OPC};

// Funcion de opcode de largo 10 y opcode de largo 10
const void (*OPC10_FUNCS[])(uint32_t) = {ls};
const uint32_t OPC10_CODES[] = {LS_OPC};

// Funciones de opcodes de largo 11 y opcodes de largo 11
const void (*OPC11_FUNCS[])(uint32_t) = {
    hlt, adds_extended_register, subs_extended_register, stur, sturb,
    sturh, ldur, ldurh, ldurb, add_extended_register, mul};
const uint32_t OPC11_CODES[] = {
    HLT_OPC, ADDS_EXTENDED_REGISTER_OPC, SUBS_EXTENDED_REGISTER_OPC, STUR_OPC, STURB_OPC,
    STURH_OPC, LDUR_OPC, LDURH_OPC, LDURB_OPC, ADD_EXTENDED_REGISTER_OPC, MUL_OPC};

// Funcion de opcode de largo 22 y opcode de largo 22
const void (*OPC22_FUNCS[])(uint32_t) = {br};
const uint32_t OPC22_CODES[] = {BR_OPC};

// Conjunto de conjuntos de funciones y códigos de opcodes
const void (**OPC_FUNC_SETS[])(uint32_t) = {
    OPC22_FUNCS, OPC11_FUNCS, OPC10_FUNCS, OPC9_FUNCS, OPC8_FUNCS, OPC6_FUNCS};
const uint32_t *OPC_CODES_SETS[] = {
    OPC22_CODES, OPC11_CODES, OPC10_CODES, OPC9_CODES, OPC8_CODES, OPC6_CODES};

// Largos de los opcodes y conjuntos de opcodes
const int OPC_LENGTHS[] = {22, 11, 10, 9, 8, 6};
const int OPC_SETS_LENGTHS[] = {
    sizeof(OPC22_FUNCS), sizeof(OPC11_FUNCS), sizeof(OPC10_FUNCS), sizeof(OPC9_FUNCS),
    sizeof(OPC8_FUNCS), sizeof(OPC6_FUNCS)};



void process_instruction() {
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);

    decode_and_execute_instruction(instruction);

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
    NEXT_STATE.REGS[31] = 0;
}

uint32_t extract_bits(uint32_t instruction, int start, int end) {
    // 'start' y 'end' son inclusivos, con 0 siendo el bit menos significativo
    // shiftea 'start' bits a la derecha y luego aplicar una máscara de 'end - start + 1' bits
    if (start > end || start < 0 || end > 31) {
        printf("ERROR: extract_bits: start > end o start o end fuera de rango\n");
        return 0;
    }

    uint32_t mask = (1 << (end - start + 1)) - 1;
    return (instruction >> start) & mask;
}

void decode_and_execute_instruction(uint32_t instruction) {
    int opc_sets_amt = sizeof(OPC_LENGTHS);
    for(int opc_set_idx=0; opc_set_idx<opc_sets_amt; opc_set_idx++) {

        int opcode_length = OPC_LENGTHS[opc_set_idx];
        int start = 32 - opcode_length;

        uint32_t opcode = extract_bits(instruction, start, 31);

        for (int opc_idx=0; opc_idx<OPC_SETS_LENGTHS[opc_set_idx]; opc_idx++) {
            if (opcode == OPC_CODES_SETS[opc_set_idx][opc_idx]) {
                // Si se encontró el opcode, ejecutar la función correspondiente
                OPC_FUNC_SETS[opc_set_idx][opc_idx](instruction);
                return;
            }
        }
    }

    // Si no se encontró el opcode, tirar error
    printf("ERROR: Opcode no encontrado\n");
    assert(0);
}
