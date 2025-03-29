.text
// Inicializar X1 con la dirección base (0x10000000)
movz X1, 0x1000, lsl 16  // X1 = 0x10000000 directamente

// Cargar desde memoria sin offset
ldur X3, [X1, #0]  // Carga lo que haya en 0x10000000

// Cargar desde memoria con offset
ldur X5, [X1, #8]  // Carga lo que haya en 0x10000008

HLT 0