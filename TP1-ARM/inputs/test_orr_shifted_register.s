.text
// Test de ORR (Shifted Register)
// La instrucción realiza operación OR bit a bit

// Test básico de OR
orr X0, X1, X2     // X0 = X1 | X2

// Test con un operando con todos los bits en 0
orr X3, X4, X5     // Si X5 = 0, entonces X3 = X4

// Test con un operando con todos los bits en 1
orr X6, X7, X8     // Si X8 = 0xFFFFFFFFFFFFFFFF, entonces X6 = 0xFFFFFFFFFFFFFFFF

// Test con ambos operandos complementarios
orr X9, X10, X11   // Si X10 = 0xAAAAAAAAAAAAAAAA y X11 = 0x5555555555555555, X9 = 0xFFFFFFFFFFFFFFFF

HLT 0