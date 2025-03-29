.text
// Test de LDURB (Load Register Byte Unscaled)
// La instrucción carga un byte desde la memoria a un registro

// Inicializar registros
movz X1, 0x1000               // Dirección base (0x10001000)

// Primero guardamos valores específicos en memoria
movz X2, 0xCD                 // Valor de 8 bits para primer test
sturb W2, [X1, #0]            // Guarda 0xCD en [X1 + 0]

movz X3, 0xFF                 // Valor máximo de 8 bits
sturb W3, [X1, #8]            // Guarda 0xFF en [X1 + 8]

movz X4, 0xAB                 // Otro valor para test
sturb W4, [X1, #-4]           // Guarda 0xAB en [X1 - 4]

// Ahora probamos LDURB
ldurb W5, [X1, #0]            // W5 = MEM[X1 + 0] = 0xCD
ldurb W6, [X1, #8]            // W6 = MEM[X1 + 8] = 0xFF
ldurb W7, [X1, #-4]           // W7 = MEM[X1 - 4] = 0xAB

HLT 0