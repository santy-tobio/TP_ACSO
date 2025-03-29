.text
// Test de LDURH (Load Register Halfword Unscaled)
// La instrucción carga un halfword (16 bits) desde la memoria a un registro

// Inicializar registros
movz X1, 0x1000               // Dirección base (0x10001000)

// Primero guardamos valores específicos en memoria
movz X2, 0xABCD               // Valor de 16 bits para primer test
sturh W2, [X1, #0]            // Guarda 0xABCD en [X1 + 0]

movz X3, 0xFFFF               // Valor máximo de 16 bits
sturh W3, [X1, #8]            // Guarda 0xFFFF en [X1 + 8]

movz X4, 0x1234               // Otro valor para test
sturh W4, [X1, #-4]           // Guarda 0x1234 en [X1 - 4]

// Ahora probamos LDURH
ldurh W5, [X1, #0]            // W5 = MEM[X1 + 0] = 0xABCD
ldurh W6, [X1, #8]            // W6 = MEM[X1 + 8] = 0xFFFF
ldurh W7, [X1, #-4]           // W7 = MEM[X1 - 4] = 0x1234

HLT 0