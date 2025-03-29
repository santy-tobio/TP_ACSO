.text
// Test de ADD (Immediate)
// La instrucción suma un valor inmediato a un registro sin actualizar flags

// Test básico
movz X1, 10                   // X1 = 10
add X0, X1, 5                 // X0 = X1 + 5 = 15

// Test con shift=1 (LSL #12)
movz X3, 15                   // X3 = 15
add X2, X3, 10, lsl #12       // X2 = X3 + (10 << 12) = 15 + 40960 = 40975

// Test con valores grandes
movz X5, 0xFFFF               // X5 = 65535
add X4, X5, 1                 // X4 = X5 + 1 = 65536

// Test con números negativos (usando SUB para crear un negativo)
movz X7, 0                    // X7 = 0
sub X7, X7, 5                 // X7 = -5
add X6, X7, 10                // X6 = X7 + 10 = -5 + 10 = 5

HLT 0