.text
// Prueba básica
adds X0, X1, X2      // X0 = X1 + X2, actualiza flags

// Prueba con XZR como registro fuente
adds X3, XZR, X4     // X3 = 0 + X4, actualiza flags

// Prueba con XZR como registro operando
adds X5, X6, XZR     // X5 = X6 + 0, actualiza flags

// Prueba que active flag Z (resultado cero)
adds X7, X8, X9      // Si X8 + X9 = 0, entonces Z=1

// Prueba que active flag N (resultado negativo)
adds X10, X11, X12   // Si X11 + X12 < 0, entonces N=1

HLT 0