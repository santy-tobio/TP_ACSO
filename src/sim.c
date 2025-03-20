#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <sim.h>
#include <shell.h>

void process_instruction() {
    // Obtener la instrucción en la dirección PC
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);
    
    // Verificar si es HLT (opcode 0x6a2, según el PDF)
    if ((instruction & 0xFFFFFC1F) == 0x6a2) {  // Máscara para aislar bits relevantes
        // Es HLT, detener la simulación
        RUN_BIT = 0;
    }
    
    // Avanzar PC
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void decode_instruction()
{

}

