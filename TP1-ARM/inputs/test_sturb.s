.text
// Test de STURB (Store Register Byte)
// La instrucción guarda el byte menos significativo de un registro en memoria

// Inicializar registros
movz X1, 0x1000               // Dirección base (0x10001000)
movz X2, 0xABCD               // Valor para guardar (solo se guardará 0xCD)
movz X3, 0xFF                 // Otro valor para guardar (0xFF)

// Test básico: guardar un byte
sturb W2, [X1, #0]            // Guarda los 8 bits menos significativos de X2 en [X1 + 0]

// Test con offset: guardar en otra dirección
sturb W3, [X1, #8]            // Guarda los 8 bits menos significativos de X3 en [X1 + 8]

// Test con offset negativo
sturb W2, [X1, #-4]           // Guarda los 8 bits menos significativos de X2 en [X1 - 4]

// Ahora leemos de vuelta para verificar
ldur X4, [X1, #0]             // X4 = MEM[X1 + 0]
ldur X5, [X1, #8]             // X5 = MEM[X1 + 8]
ldur X6, [X1, #-4]            // X6 = MEM[X1 - 4]

HLT 0