.text
// Prueba de la instrucción HLT
// Esta instrucción debería detener la simulación (RUN_BIT = 0)

// Realizamos algunas operaciones antes de HLT para asegurarnos de que todo funciona
adds X0, X0, 5     // X0 = X0 + 5
adds X1, X1, 10    // X1 = X1 + 10

// La instrucción HLT debería detener la simulación
HLT 0

// Estas instrucciones no deberían ejecutarse
adds X2, X2, 15    // X2 = X2 + 15
adds X3, X3, 20    // X3 = X3 + 20