.text
// Inicializar registros para comparaciones
movz x1, 10        // x1 = 10
movz x2, 10        // x2 = 10
movz x3, 5         // x3 = 5

// Prueba BEQ (debe saltar cuando Z=1)
cmp x1, x2         // Compara x1 y x2 (iguales), establece Z=1
beq beq_target     // Debería saltar
adds x10, x10, 1   // No debería ejecutarse
beq_target:
adds x11, x11, 1   // Debería ejecutarse

// Prueba BNE (debe saltar cuando Z=0)
cmp x1, x3         // Compara x1 y x3 (diferentes), establece Z=0
bne bne_target     // Debería saltar
adds x12, x12, 1   // No debería ejecutarse
bne_target:
adds x13, x13, 1   // Debería ejecutarse

// Prueba BGT (debe saltar cuando N=0 y Z=0)
cmp x1, x3         // Compara x1 > x3, establece N=0, Z=0
bgt bgt_target     // Debería saltar
adds x14, x14, 1   // No debería ejecutarse
bgt_target:
adds x15, x15, 1   // Debería ejecutarse

// Prueba BLT (debe saltar cuando N=1)
cmp x3, x1         // Compara x3 < x1, establece N=1
blt blt_target     // Debería saltar
adds x16, x16, 1   // No debería ejecutarse
blt_target:
adds x17, x17, 1   // Debería ejecutarse

// Prueba BGE (debe saltar cuando N=0)
cmp x1, x3         // Compara x1 >= x3, establece N=0
bge bge_target     // Debería saltar
adds x18, x18, 1   // No debería ejecutarse
bge_target:
adds x19, x19, 1   // Debería ejecutarse

// Prueba BLE (debe saltar cuando Z=1 o N=1)
cmp x1, x2         // Compara x1 == x2, establece Z=1
ble ble_target1    // Debería saltar
adds x20, x20, 1   // No debería ejecutarse
ble_target1:
adds x21, x21, 1   // Debería ejecutarse

// Segunda prueba BLE con N=1
cmp x3, x1         // Compara x3 <= x1, establece N=1
ble ble_target2    // Debería saltar
adds x22, x22, 1   // No debería ejecutarse
ble_target2:
adds x23, x23, 1   // Debería ejecutarse

HLT 0