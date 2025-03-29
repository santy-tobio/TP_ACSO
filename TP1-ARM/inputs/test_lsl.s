.text
// Test de LSL (Logical Shift Left)
// La instrucción desplaza bits a la izquierda

// Test básico con desplazamiento pequeño
lsl X0, X1, 2      // X0 = X1 << 2

// Test con desplazamiento mayor
lsl X2, X3, 8      // X2 = X3 << 8

// Test con desplazamiento de 16 bits
lsl X4, X5, 16     // X4 = X5 << 16

// Test con valor de 1 (verificar comportamiento potencia de 2)
lsl X6, X7, 4      // Si X7 = 1, entonces X6 = 2^4 = 16

HLT 0