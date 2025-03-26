#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <sim.h>
#include <shell.h>

// Acemos shifts por largos de opcode 

#define ADDS_INMEDIATE_OPCODE 0b10110001 // 8 bits
#define ADDS_EXTENDED_REGISTER_OPCODE 0b10101011001 // 11 bits


// Máscaras de bits

#define EIGHT_BITS_MASK 0b11111111
#define ELEVEN_BITS_MASK 0b11111111111


void process_instruction() {
    // Obtener la instrucción en la dirección PC
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);


    
    // Avanzar PC
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void decode_instruction()
{
 
}


