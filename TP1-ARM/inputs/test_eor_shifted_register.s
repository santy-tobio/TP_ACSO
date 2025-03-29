.text
// Test de EOR (Shifted Register)
// La instrucción realiza operación XOR bit a bit

// Test básico de XOR
eor X0, X1, X2     // X0 = X1 ^ X2

// Test con valores iguales (debería dar 0)
eor X3, X4, X5     // Si X4 = X5, entonces X3 = 0

// Test con valores complementarios
eor X6, X7, X8     // Si X7 y X8 son complementarios, X6 tendrá todos los bits en 1

// Test con un valor y cero
eor X9, X10, X11   // Si X11 = 0, entonces X9 = X10

HLT 0