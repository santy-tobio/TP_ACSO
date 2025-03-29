.text
// Test básico de resta
subs X0, X1, 5        // X0 = X1 - 5, actualiza flags

// Test con shift=01 (imm12 << 12)
subs X2, X3, 10, lsl #12  // X2 = X3 - (10 << 12), actualiza flags

// Test que produce resultado cero (para flag Z)
subs X4, X5, 7        // Si X5 = 7, X4 = 0, Z=1

// Test que produce resultado negativo (para flag N)
subs X6, X7, 10       // Si X7 < 10, X6 < 0, N=1

HLT 0