# Guía para testear Simulador ARMv8

Este documento explica cómo funciona el sistema de test para el simulador ARMv8 y cómo utilizarlo para verificar la correcta implementación de las instrucciones requeridas. Esto lo hacemos comparando contra el simulador de referencia otorgado por la cátedra 

## Estructura de las Pruebas

El sistema de pruebas consta de:

1. **Programas de prueba en assembler (`.s`)**: Ubicados en `/inputs`, contienen código ARMv8 que ejercita cada instrucción.
2. **Archivo binario generado (`.x`)**: Creado con `asm2hex` a partir del código assembler.
3. **Script `test_simulator.sh`**: Ejecuta las pruebas y compara los resultados con el simulador de referencia.

## Cómo Funciona `test_simulator.sh`

El script `test_simulator.sh` automatiza el proceso de prueba mediante los siguientes pasos:

1. Compila el simulador con `make`
2. Crea un directorio temporal para los archivos de salida
3. Para cada prueba:
   - Genera un archivo de comandos específico para esa prueba
   - Ejecuta el simulador de referencia (`ref_sim`) con esos comandos
   - Ejecuta nuestro simulador con los mismos comandos
   - Compara las salidas para verificar que son idénticas
4. Muestra un resumen de las pruebas pasadas y fallidas

Los comandos de prueba incluyen:
- `input <reg> <value>`: Establece valores iniciales en registros
- `run <n>`: Ejecuta n instrucciones
- `rdump`: Muestra el estado de registros y flags
- `mdump <start> <end>`: Muestra el contenido de memoria

## Cómo Usar el Script de Pruebas

### Ejecutar todas las pruebas

```bash
./test_simulator.sh
```

Esto ejecutará todas las pruebas `.x` encontradas en el directorio `/inputs` y mostrará un resumen al final.

### Ejecutar una prueba específica

```bash
./test_simulator.sh test_adds_extended
```

Esto ejecutará solo la prueba especificada (sin la extensión `.x`).

### Interpretar los resultados

- ✅ **Verde**: La prueba pasó correctamente
- ❌ **Rojo**: La prueba falló, mostrando las diferencias entre el resultado en el simulador de referencia y nuestro simulaodr

## Instrucciones Probadas

El sistema incluye pruebas para todas las instrucciones requeridas:

- ADDS (Immediate y Extended Register)
- SUBS (Immediate y Extended Register)
- HLT
- ANDS (Shifted Register)
- EOR (Shifted Register)
- ORR (Shifted Register)
- B
- BR
- B.cond (BEQ, BNE, BGT, BLT, BGE, BLE)
- LSL (Immediate)
- LSR (Immediate)
- STUR, STURB, STURH
- LDUR, LDURB, LDURH
- MOVZ
- ADD (Immediate y Extended Register)
- MUL
- CBZ
- CBNZ