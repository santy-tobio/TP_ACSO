.text
// Prueba básica
adds X0, X1, 5       // X0 = X1 + 5, actualiza flags

// Prueba con shift=01 (imm12 << 12)
adds X2, X3, 0x123   // X2 = X3 + 0x123, actualiza flags

// Prueba con registro cero
adds X5, X4, 42     // X5 = 0 + 42, actualiza flags

// Prueba que active flag Z (resultado cero)
adds X6, X7, 0       // Si X7 = 0, entonces X6 = 0 y Z=1

// Prueba que active flag N (resultado negativo)
adds X8, X9, 1       // Si X9 = -1, entonces X8 = 0 y N=0
                    // Si X9 < -1, entonces X8 < 0 y N=1

HLT 0