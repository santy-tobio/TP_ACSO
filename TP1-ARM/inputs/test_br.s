.text
// Incrementar X0 antes del salto
adds x0, x0, 5

// Hacer el salto a la dirección guardada en X1
br x1              // Saltar a la dirección almacenada en X1

// Estas instrucciones deben ser saltadas
adds x2, x2, 10    // No debería ejecutarse
adds x3, x3, 15    // No debería ejecutarse

// Destino del salto
adds x4, x4, 1     // Esta instrucción debe ejecutarse después del BR

HLT 0