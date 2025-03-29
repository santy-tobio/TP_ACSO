.text
// Test de ANDS (Shifted Register)
// La instrucción realiza operación AND bit a bit y actualiza flags

// Test básico de AND
ands X0, X1, X2    // X0 = X1 & X2, actualiza flags

// Test que produce resultado cero (para flag Z)
ands X3, X4, X5    // Si uno de los registros es 0, X3 = 0, Z=1

// Test con números negativos (para flag N)
ands X6, X7, X8    // Si el bit más significativo del resultado es 1, N=1

// Test con todos los bits en 1
ands X9, X10, X11  // X9 = X10 & X11

HLT 0

