.text
// Test de MOVZ (Move Wide with Zero)
// La instrucción carga un valor inmediato en un registro, poniendo a cero los bits no afectados

// Test básico
movz X0, 0          // X0 = 0

// Test con valor pequeño
movz X1, 10         // X1 = 10

// Test con valor máximo de 16 bits
movz X2, 0xFFFF     // X2 = 0xFFFF (65535)

// Test con valor arbitrario
movz X3, 0xABCD     // X3 = 0xABCD (43981)

HLT 0