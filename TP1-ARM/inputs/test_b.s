.text
// Caso básico: salto hacia adelante
adds x0, x1, 1
b forward_jump      // Salto simple hacia adelante
adds x0, x0, 10     // Esta instrucción debe ser saltada
adds x0, x0, 20     // Esta instrucción debe ser saltada

forward_jump:
adds x1, x0, 1      // Debería ejecutarse después del salto

// Caso: salto hacia atrás (loop)
adds x2, x2, 1
b backward_jump     
adds x2, x2, 100    // Esta instrucción nunca debería ejecutarse

backward_jump:
adds x3, x3, 1

// Caso: salto a la última instrucción
b end_test
adds x4, x4, 50     // Esta instrucción debe ser saltada

// Caso: salto largo (máximo offset posible para esta prueba)
end_test:
HLT 0
