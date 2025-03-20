#include "sim.h"
#include "test.h"
#include <stdio.h>

void setup_test_state() {
    // Inicializar estado para pruebas
    CURRENT_STATE.PC = 0x00400000;
    NEXT_STATE.PC = 0x00400000;
    // Inicializar registros
}
