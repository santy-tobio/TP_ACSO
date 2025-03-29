.text
// Test de LSR (Logical Shift Right)
// La instrucción desplaza bits a la derecha

// Test básico con desplazamiento pequeño
lsr X0, X1, 2      // X0 = X1 >> 2

// Test con desplazamiento mayor
lsr X2, X3, 8      // X2 = X3 >> 8

// Test con desplazamiento de 16 bits
lsr X4, X5, 16     // X4 = X5 >> 16

// Test con número grande
lsr X6, X7, 4      // Si X7 = 0x100, entonces X6 = 0x10

HLT 0