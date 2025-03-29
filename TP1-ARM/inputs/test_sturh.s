.text
// Test de STURH (Store Register Halfword)
// La instrucción guarda los 16 bits menos significativos de un registro en memoria

// Inicializar registros
movz X1, 0x1000               // Dirección base (0x10001000)
movz X2, 0xABCD               // Valor para guardar (se guardará 0xABCD)
movz X3, 0xFFFF               // Otro valor para guardar (0xFFFF)

// Test básico: guardar un halfword
sturh W2, [X1, #0]            // Guarda los 16 bits menos significativos de X2 en [X1 + 0]

// Test con offset: guardar en otra dirección
sturh W3, [X1, #8]            // Guarda los 16 bits menos significativos de X3 en [X1 + 8]

// Test con offset negativo
sturh W2, [X1, #-4]           // Guarda los 16 bits menos significativos de X2 en [X1 - 4]

// Ahora leemos de vuelta para verificar
ldur X4, [X1, #0]             // X4 = MEM[X1 + 0]
ldur X5, [X1, #8]             // X5 = MEM[X1 + 8]
ldur X6, [X1, #-4]            // X6 = MEM[X1 - 4]

HLT 0