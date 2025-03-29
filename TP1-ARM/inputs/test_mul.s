.text
// Test de MUL (Multiply)
// La instrucción multiplica dos valores de registros

// Test básico
movz X1, 5
movz X2, 7
mul X0, X1, X2               // X0 = X1 * X2 = 5 * 7 = 35

// Test con valores grandes
movz X3, 0xFFFF              // 65535
movz X4, 2
mul X5, X3, X4               // X5 = X3 * X4 = 65535 * 2 = 131070

// Test con valor cero
movz X6, 42
movz X7, 0
mul X8, X6, X7               // X8 = X6 * X7 = 42 * 0 = 0

// Test con números negativos
movz X9, 0
sub X9, X9, 5                // X9 = -5
movz X10, 3
mul X11, X9, X10             // X11 = X9 * X10 = -5 * 3 = -15

HLT 0