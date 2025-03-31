.text
// Test de ADD (Extended Register)
// La instrucción suma dos registros sin actualizar flags

// Test básico
movz X1, 20                   // X1 = 20
movz X2, 30                   // X2 = 30
add X0, X1, X2                // X0 = X1 + X2 = 50

// Test con cero
movz X4, 40                   // X4 = 40
movz X5, 0                    // X5 = 0
add X3, X4, X5                // X3 = X4 + X5 = 40

// Test con valores grandes
movz X7, 0xFFFF               // X7 = 65535
movz X8, 0xFFFF               // X8 = 65535
add X6, X7, X8                // X6 = X7 + X8 = 131070

// Test con números negativos (usando SUB para crear negativos)
movz X10, 0                   // X10 = 0
subs X10, X10, 5               // X10 = -5
movz X11, 0                   // X11 = 0
subs X11, X11, 10              // X11 = -10
add X9, X10, X11              // X9 = X10 + X11 = -15

HLT 0