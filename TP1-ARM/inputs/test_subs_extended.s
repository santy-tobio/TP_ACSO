.text
// Test básico de resta con registros
subs X0, X1, X2       // X0 = X1 - X2, actualiza flags

// Test que produce resultado cero (para flag Z)
subs X3, X4, X5       // Si X4 = X5, X3 = 0, Z=1

// Test que produce resultado negativo (para flag N)
subs X6, X7, X8       // Si X7 < X8, X6 < 0, N=1

// Test con números negativos
subs X9, X10, X11     // X9 = X10 - X11, actualiza flags

HLT 0