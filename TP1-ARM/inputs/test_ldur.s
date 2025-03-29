.text
// Test de LDUR (Load Register Unscaled)
// La instrucción carga un valor de 64 bits desde la memoria a un registro

// Inicializar memoria con valores
movz X1, 0x1000               // Dirección base (0x10001000)
movz X2, 0xABCD               // Valor para guardar en memoria

// Guardamos valores en memoria primero
stur X2, [X1, #0]             // Guarda X2 en [X1 + 0]
movz X3, 0xDEF0
stur X3, [X1, #8]             // Guarda X3 en [X1 + 8]

// Ahora probamos LDUR
ldur X4, [X1, #0]             // X4 = MEM[X1 + 0]
ldur X5, [X1, #8]             // X5 = MEM[X1 + 8]
ldur X6, [X1, #-8]            // X6 = MEM[X1 - 8] (offset negativo)

HLT 0