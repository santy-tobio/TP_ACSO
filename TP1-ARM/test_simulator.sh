#!/bin/bash

cd src
make clean  # Siempre limpia primero
make

cd ..

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' 

REF_SIM="./ref_sim_x86"
MY_SIM="./src/sim"
TEST_DIR="./inputs"
TEMP_DIR="./temp_test"

# hacemos un directorio temporal para no juntar basura
mkdir -p $TEMP_DIR

# con esta funcion podemos correr los tests
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .x)

    echo -e "${BLUE}Testing $test_name...${NC}"
    COMMAND_FILE="$TEMP_DIR/commands.txt"
    echo "rdump" > $COMMAND_FILE  

    # Estos comando son específicos para cada instrucción
    case "$test_name" in
        test_adds_immediate)
            echo "Prueba de ADDS IMMEDIATE"
            echo "input 1 10" >> $COMMAND_FILE       # X1 = 10
            echo "input 3 15" >> $COMMAND_FILE       # X3 = 15
            echo "input 6 0" >> $COMMAND_FILE        # X6 = 0 (para probar flag Z)
            echo "input 8 -5" >> $COMMAND_FILE       # X8 = -5 (para probar flag N)
            echo "rdump" >> $COMMAND_FILE
            echo "run 5" >> $COMMAND_FILE            # Ejecuta todas las instrucciones
            echo "rdump" >> $COMMAND_FILE
        ;;
        test_adds_extended)
            echo "Prueba de ADDS EXTENDED REGISTER"
            echo "input 1 20" >> $COMMAND_FILE       # X1 = 20
            echo "input 2 30" >> $COMMAND_FILE       # X2 = 30
            echo "input 4 40" >> $COMMAND_FILE       # X4 = 40
            echo "input 6 50" >> $COMMAND_FILE       # X6 = 50
            echo "input 8 10" >> $COMMAND_FILE       # X8 = 10
            echo "input 9 -10" >> $COMMAND_FILE      # X9 = -10 (para probar flag Z)
            echo "input 11 5" >> $COMMAND_FILE       # X11 = 5
            echo "input 12 -20" >> $COMMAND_FILE     # X12 = -20 (para probar flag N)
            echo "rdump" >> $COMMAND_FILE
            echo "run 5" >> $COMMAND_FILE            # ejecuta todas las instrucciones
            echo "rdump" >> $COMMAND_FILE
        ;;
        test_subs_immediate)
            echo "Prueba de SUBS IMMEDIATE"
            echo "input 1 15" >> $COMMAND_FILE       # X1 = 15
            echo "input 3 40960" >> $COMMAND_FILE    # X3 = 40960 (10 << 12)
            echo "input 5 7" >> $COMMAND_FILE        # X5 = 7 (para probar flag Z)
            echo "input 7 5" >> $COMMAND_FILE        # X7 = 5 (para probar flag N)
            echo "rdump" >> $COMMAND_FILE
            echo "run 1" >> $COMMAND_FILE            # Ejecuta primera instrucción
            echo "rdump" >> $COMMAND_FILE            # X0 debe ser 10, N=0, Z=0
            echo "run 1" >> $COMMAND_FILE            # Ejecuta segunda instrucción
            echo "rdump" >> $COMMAND_FILE            # X2 debe ser X3 - 40960
            echo "run 1" >> $COMMAND_FILE            # Ejecuta tercera instrucción
            echo "rdump" >> $COMMAND_FILE            # X4 debe ser 0, Z=1
            echo "run 1" >> $COMMAND_FILE            # Ejecuta cuarta instrucción
            echo "rdump" >> $COMMAND_FILE            # X6 debe ser negativo, N=1
            echo "run 1" >> $COMMAND_FILE            # Ejecuta HLT
            echo "rdump" >> $COMMAND_FILE            # Estado final
        ;;
        test_subs_extended)
            echo "Prueba de SUBS EXTENDED REGISTER"
            echo "input 1 25" >> $COMMAND_FILE       # X1 = 25
            echo "input 2 10" >> $COMMAND_FILE       # X2 = 10
            echo "input 4 20" >> $COMMAND_FILE       # X4 = 20
            echo "input 5 20" >> $COMMAND_FILE       # X5 = 20 (para obtener Z=1)
            echo "input 7 15" >> $COMMAND_FILE       # X7 = 15
            echo "input 8 30" >> $COMMAND_FILE       # X8 = 30 (para obtener N=1)
            echo "input 10 -5" >> $COMMAND_FILE      # X10 = -5
            echo "input 11 10" >> $COMMAND_FILE      # X11 = 10
            echo "rdump" >> $COMMAND_FILE
            echo "run 1" >> $COMMAND_FILE            # Ejecuta primera instrucción
            echo "rdump" >> $COMMAND_FILE            # X0 debe ser 15, N=0, Z=0
            echo "run 1" >> $COMMAND_FILE            # Ejecuta segunda instrucción
            echo "rdump" >> $COMMAND_FILE            # X3 debe ser 0, Z=1
            echo "run 1" >> $COMMAND_FILE            # Ejecuta tercera instrucción
            echo "rdump" >> $COMMAND_FILE            # X6 debe ser negativo, N=1
            echo "run 1" >> $COMMAND_FILE            # Ejecuta cuarta instrucción
            echo "rdump" >> $COMMAND_FILE            # X9 debe ser -15
            echo "run 1" >> $COMMAND_FILE            # Ejecuta HLT
            echo "rdump" >> $COMMAND_FILE            # Estado final
        ;;
        test_cmp)
            echo "Prueba de CMP"
            echo "input 0 2" >> $COMMAND_FILE       # X0 = 2
            echo "input 1 5" >> $COMMAND_FILE       # X1 = 5
            echo "input 2 2" >> $COMMAND_FILE       # X2 = 2
            echo "run 1"
            echo "rdump" >> $COMMAND_FILE            # Estado inicial
            echo "run 1" >> $COMMAND_FILE            # Ejecuta CMP x0 x1
            echo "rdump" >> $COMMAND_FILE            # X0 = 0, N=1, Z=0
            echo "run 1" >> $COMMAND_FILE            # Ejecuta CMP x1 x0
            echo "rdump" >> $COMMAND_FILE            # X1 = 0, N=0, Z=0
            echo "run 1" >> $COMMAND_FILE            # Ejecuta CMP x0 x2
            echo "rdump" >> $COMMAND_FILE            # X2 = 0, N=0, Z=1

        ;;
        test_orr_shifted_register)
            echo "Prueba de ORR"
            echo "run 2" >> $COMMAND_FILE            # Ejecuta ORR x0 x1
            echo "rdump" >> $COMMAND_FILE            # Estado inicial
            echo "run 1" >> $COMMAND_FILE            # Ejecuta ORR x0 x1
            echo "rdump" >> $COMMAND_FILE            # X0 = 7 (3 | 6)
        ;;
        test_b)
            echo "Prueba de B (Branch)"
            echo "input 0 0" >> $COMMAND_FILE       # X0 = 0
            echo "input 1 5" >> $COMMAND_FILE       # X1 = 5
            echo "input 2 0" >> $COMMAND_FILE       # X2 = 0
            echo "input 3 0" >> $COMMAND_FILE       # X3 = 0
            echo "input 4 0" >> $COMMAND_FILE       # X4 = 0
            echo "rdump" >> $COMMAND_FILE           # Mostrar estado inicial

            # Ejecutamos 2 instrucciones: adds + branch
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE           # Verifica el salto

            # Ejecutamos 2 instrucciones más: debería estar en forward_jump
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE

            # Ejecutamos hasta el final
            echo "run 10" >> $COMMAND_FILE          # Suficiente para llegar al HLT
            echo "rdump" >> $COMMAND_FILE
        ;;
        test_br)
            echo "Prueba de BR (Branch Register)"

            # Configurar registros iniciales
            echo "input 0 0" >> $COMMAND_FILE           # X0 = 0

            # Esto es clave: establece X1 con la dirección del destino del salto
            # Calculamos la dirección: posición inicial (0x00400000) + 16 bytes (4 instrucciones)
            echo "input 1 0x00400010" >> $COMMAND_FILE  # Dirección donde está "adds x4, x4, 1"

            echo "input 2 0" >> $COMMAND_FILE           # X2 = 0
            echo "input 3 0" >> $COMMAND_FILE           # X3 = 0
            echo "input 4 0" >> $COMMAND_FILE           # X4 = 0

            echo "rdump" >> $COMMAND_FILE               # Mostrar estado inicial

            # Ejecutamos la primera instrucción (adds x0, x0, 5)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Verificamos que X0 = 5

            # Ejecutamos la instrucción BR
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Verificamos PC después del salto

            # Ejecutamos la instrucción destino (adds x4, x4, 1)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Verificamos que X4 = 1 y que X2, X3 siguen = 0

            # Ejecutamos hasta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_bcond)
            echo "Prueba de B.cond (Branch Conditional)"

            for i in {10..23}; do
                echo "input $i 0" >> $COMMAND_FILE  # Inicializa x10-x23 a 0
            done
            echo "rdump" >> $COMMAND_FILE      

            # Ejecutar hasta después de BEQ
            echo "run 5" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x11=1, x10=0

            # Ejecutar hasta después de BNE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x13=1, x12=0

            # Ejecutar hasta después de BGT
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x15=1, x14=0

            # Ejecutar hasta después de BLT
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x17=1, x16=0

            # Ejecutar hasta después de BGE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x19=1, x18=0

            # Ejecutar hasta después de primer BLE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x21=1, x20=0

            # Ejecutar hasta después de segundo BLE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verifica x23=1, x22=0

            # Ejecutar hasta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Estado final
            ;;
        test_stur)
            echo "Prueba de STUR con operaciones previas de MOVZ y LSL"
            
            # No inicializamos X0 o X1 ya que los valores se establecen con MOVZ en el test
            
            echo "rdump" >> $COMMAND_FILE              # Estado inicial
            
            # Ejecuta el primer MOVZ (x0 = 0x1000)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 0x1000
            
            # Ejecuta LSL (x0 = 0x10000000)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 0x10000000
            
            # Ejecuta segundo MOVZ (x1 = 0x20)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X1 = 0x20
            
            # Ejecuta STUR (almacena X1 en dirección [X0+0xf])
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Verificar registros
            
            # Verifica memoria para comprobar que el valor fue almacenado correctamente
            echo "mdump 0x10000000 0x10000020" >> $COMMAND_FILE
            
            # Ejecutar HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Estado final
            
            # Verifica memoria una vez más después de completar la ejecución
            echo "mdump 0x10000000 0x10000020" >> $COMMAND_FILE
            ;;
        test_halt)
            echo "Prueba de HLT"

            # Inicializa registros
            echo "input 0 0" >> $COMMAND_FILE  # X0 = 0
            echo "input 1 0" >> $COMMAND_FILE  # X1 = 0
            echo "input 2 0" >> $COMMAND_FILE  # X2 = 0
            echo "input 3 0" >> $COMMAND_FILE  # X3 = 0
            echo "rdump" >> $COMMAND_FILE     # Estado inicial

            # Ejecuta las dos primeras instrucciones
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE     # X0 = 5, X1 = 10

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE     # Estado después de HLT

            # Intenta ejecutar más instrucciones (no deberían ejecutarse)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE     # X2 y X3 deberían seguir siendo 0
            ;;
        test_ands_shifted_register)
            echo "Prueba de ANDS"

            # Inicializa registros para AND
            echo "input 1 0xFF00" >> $COMMAND_FILE     # X1 = 0xFF00
            echo "input 2 0x0FF0" >> $COMMAND_FILE     # X2 = 0x0FF0

            # Para probar flag Z (resultado 0)
            echo "input 4 0xABCD" >> $COMMAND_FILE     # X4 = 0xABCD
            echo "input 5 0" >> $COMMAND_FILE          # X5 = 0

            # Para probar flag N (resultado negativo)
            echo "input 7 0x8000000000000000" >> $COMMAND_FILE  # X7 bit más significativo = 1
            echo "input 8 0x8000000000000001" >> $COMMAND_FILE  # X8 bit más significativo = 1

            # Test con todos los bits en 1
            echo "input 10 0xFFFFFFFFFFFFFFFF" >> $COMMAND_FILE # X10 = todos 1s
            echo "input 11 0xFFFFFFFFFFFFFFFF" >> $COMMAND_FILE # X11 = todos 1s

            echo "rdump" >> $COMMAND_FILE              # Estado inicial

            # Ejecuta primera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 0x0F00, N=0, Z=0

            # Ejecuta segunda instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X3 = 0, Z=1

            # Ejecuta tercera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X6 tiene bit más significativo = 1, N=1

            # Ejecuta cuarta instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X9 = todos 1s

            # Ejecutar HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Estado final
            ;;
        test_eor_shifted_register)
            echo "Prueba de EOR"

            # Inicializa registros para XOR
            echo "input 1 0xAAAA" >> $COMMAND_FILE     # X1 = 0xAAAA (alternado 1010...)
            echo "input 2 0x5555" >> $COMMAND_FILE     # X2 = 0x5555 (alternado 0101...)

            # Para obtener resultado 0 (valores iguales)
            echo "input 4 0xBEEF" >> $COMMAND_FILE     # X4 = 0xBEEF
            echo "input 5 0xBEEF" >> $COMMAND_FILE     # X5 = 0xBEEF

            # Para obtener todos 1s (valores complementarios)
            echo "input 7 0xAAAA" >> $COMMAND_FILE     # X7 = 0xAAAA
            echo "input 8 0x5555" >> $COMMAND_FILE     # X8 = 0x5555

            # XOR con cero
            echo "input 10 0xDEAD" >> $COMMAND_FILE    # X10 = 0xDEAD
            echo "input 11 0" >> $COMMAND_FILE         # X11 = 0

            echo "rdump" >> $COMMAND_FILE              # Estado inicial

            # Ejecuta primera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 0xFFFF (todos 1s)

            # Ejecuta segunda instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X3 = 0

            # Ejecuta tercera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X6 = 0xFFFF (todos 1s)

            # Ejecuta cuarta instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X9 = 0xDEAD

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Estado final
            ;;
        test_movz)
            echo "Prueba de MOVZ"

            echo "rdump" >> $COMMAND_FILE              # Estado inicial

            # Ejecuta primera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 0

            # Ejecuta segunda instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X1 = 10

            # Ejecuta tercera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X2 = 0xFFFF (65535)

            # Ejecuta cuarta instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X3 = 0xABCD (43981)

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Estado final
            ;;
        test_lsl)
            echo "Prueba de LSL"

            # Inicializa registros para LSL
            echo "input 1 5" >> $COMMAND_FILE          # X1 = 5
            echo "input 3 0xFF" >> $COMMAND_FILE       # X3 = 0xFF (255)
            echo "input 5 0xABCD" >> $COMMAND_FILE     # X5 = 0xABCD
            echo "input 7 1" >> $COMMAND_FILE          # X7 = 1

            echo "rdump" >> $COMMAND_FILE              # Estado inicial

            # Ejecuta primera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 20 (5 << 2)

            # Ejecuta segunda instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X2 = 0xFF00 (255 << 8)

            # Ejecuta tercera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X4 = 0xABCD0000 (0xABCD << 16)

            # Ejecuta cuarta instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X6 = 16 (1 << 4)

            # Ejecutar HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Estado final
            ;;
        test_lsr)
            echo "Prueba de LSR"

            # Inicializa registros para LSR
            echo "input 1 20" >> $COMMAND_FILE         # X1 = 20
            echo "input 3 0xFF00" >> $COMMAND_FILE     # X3 = 0xFF00
            echo "input 5 0xABCD0000" >> $COMMAND_FILE # X5 = 0xABCD0000
            echo "input 7 0x100" >> $COMMAND_FILE      # X7 = 0x100 (256)

            echo "rdump" >> $COMMAND_FILE              # Estado inicial

            # Ejecuta primera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X0 = 5 (20 >> 2)

            # Ejecuta segunda instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X2 = 0xFF (0xFF00 >> 8)

            # Ejecuta tercera instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X4 = 0xABCD (0xABCD0000 >> 16)

            # Ejecuta cuarta instrucción
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # X6 = 0x10 (0x100 >> 4)

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE              # Estado final
            ;;
        test_ldur)
            echo "Prueba de LDUR"

            # Inicializa registros
            echo "input 1 0x10001000" >> $COMMAND_FILE  # X1 = dirección base
            echo "input 2 0xABCD" >> $COMMAND_FILE      # X2 = valor para guardar
            echo "input 3 0xDEF0" >> $COMMAND_FILE      # X3 = segundo valor

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta las primeras 3 instrucciones para preparar la memoria
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE
            echo "mdump 0x10000FF8 0x10001010" >> $COMMAND_FILE  # Ver contenido de memoria

            # Ejecuta la primera LDUR
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X4 debe ser igual a X2 (0xABCD)

            # Ejecuta la segunda LDUR
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X5 debe ser igual a X3 (0xDEF0)

            # Ejecuta la tercera LDUR (con offset negativo)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X6 depende del contenido en X1-8

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_mul)
            echo "Prueba de MUL"

            # Inicializar registros
            # No inicializamos acá porque los valores se cargan con MOVZ en el test

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta hasta el primer MUL (carga X1 y X2 primero)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X0 = 35 (5 * 7)

            # Ejecuta hasta el segundo MUL (carga X3 y X4 primero)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X5 = 131070 (65535 * 2)

            # Ejecuta hasta el tercer MUL (carga X6 y X7 primero)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X8 = 0 (42 * 0)

            # Ejecuta hasta el cuarto MUL (carga X9 y X10 primero)
            echo "run 4" >> $COMMAND_FILE               # +1 para el SUB
            echo "rdump" >> $COMMAND_FILE               # X11 = -15 (-5 * 3)

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_sturb)
            echo "Prueba de STURB"

            # Inicializa registros
            echo "input 1 0x10001000" >> $COMMAND_FILE  # X1 = dirección base
            echo "input 2 0xABCD" >> $COMMAND_FILE      # X2 = valor para guardar (solo se guardará 0xCD)
            echo "input 3 0xFF" >> $COMMAND_FILE        # X3 = valor para guardar (0xFF)

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta las 3 operaciones STURB
            echo "run 3" >> $COMMAND_FILE
            echo "mdump 0x10000FF8 0x10001010" >> $COMMAND_FILE  # Ver contenido de memoria

            # Ejecuta las 3 operaciones LDUR para verificar
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X4, X5, X6 deben contener los valores guardados

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_sturh)
            echo "Prueba de STURH"

            # Inicializa registros
            echo "input 1 0x10001000" >> $COMMAND_FILE  # X1 = dirección base
            echo "input 2 0xABCD" >> $COMMAND_FILE      # X2 = valor para guardar (se guardará 0xABCD)
            echo "input 3 0xFFFF" >> $COMMAND_FILE      # X3 = valor para guardar (0xFFFF)

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta las 3 operaciones STURH
            echo "run 3" >> $COMMAND_FILE
            echo "mdump 0x10000FF8 0x10001010" >> $COMMAND_FILE  # Ver contenido de memoria

            # Ejecuta las 3 operaciones LDUR para verificar
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X4, X5, X6 deben contener los valores guardados

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_ldurb)
            echo "Prueba de LDURB"

            # Inicializa registros
            echo "input 1 0x10001000" >> $COMMAND_FILE  # X1 = dirección base
            echo "input 2 0xCD" >> $COMMAND_FILE        # X2 = 0xCD (valor de 8 bits)
            echo "input 3 0xFF" >> $COMMAND_FILE        # X3 = 0xFF (valor máximo de 8 bits)
            echo "input 4 0xAB" >> $COMMAND_FILE        # X4 = 0xAB (otro valor de 8 bits)

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta las operaciones STURB para preparar la memoria
            echo "run 3" >> $COMMAND_FILE
            echo "mdump 0x10000FF8 0x10001010" >> $COMMAND_FILE  # contenido de memoria

            # Ejecuta la primera LDURB
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X5 debe ser 0xCD

            # Ejecuta la segunda LDURB
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X6 debe ser 0xFF

            # Ejecuta la tercera LDURB
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X7 debe ser 0xAB

            # Ejecutar HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_ldurh)
            echo "Prueba de LDURH"

            # Inicializa registros
            echo "input 1 0x10001000" >> $COMMAND_FILE  # X1 = dirección base
            echo "input 2 0xABCD" >> $COMMAND_FILE      # X2 = 0xABCD (valor de 16 bits)
            echo "input 3 0xFFFF" >> $COMMAND_FILE      # X3 = 0xFFFF (valor máximo de 16 bits)
            echo "input 4 0x1234" >> $COMMAND_FILE      # X4 = 0x1234 (otro valor de 16 bits)

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta las operaciones STURH para preparar la memoria
            echo "run 3" >> $COMMAND_FILE
            echo "mdump 0x10000FF8 0x10001010" >> $COMMAND_FILE  # Ver contenido de memoria

            # Ejecuta la primera LDURH
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X5 debe ser 0xABCD

            # Ejecuta la segunda LDURH
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X6 debe ser 0xFFFF

            # Ejecuta la tercera LDURH
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X7 debe ser 0x1234

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_add_immediate)
            echo "Prueba de ADD IMMEDIATE"

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta hasta primer ADD (después de cargar X1)
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X0 = 15

            # Ejecuta hasta segundo ADD (después de cargar X3)
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X2 = 40975

            # Ejecuta hasta tercer ADD (después de cargar X5)
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X4 = 65536

            # Ejecuta hasta cuarto ADD (después de SUB con X7)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X6 = 5

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_add_extended_register)
            echo "Prueba de ADD EXTENDED REGISTER"

            echo "rdump" >> $COMMAND_FILE               # Estado inicial

            # Ejecuta hasta primer ADD (después de cargar X1 y X2)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X0 = 50

            # Ejecuta hasta segundo ADD (después de cargar X4 y X5)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X3 = 40

            # Ejecuta hasta tercer ADD (después de cargar X7 y X8)
            echo "run 3" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X6 = 131070

            # Ejecuta hasta cuarto ADD (después de SUB con X11)
            echo "run 5" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # X9 = -15

            # Ejecuta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_cbz)
            echo "Prueba de CBZ (compara y branchea si es cero)"

            echo "input 1 0" >> $COMMAND_FILE      # X1 = 0 (brachea)
            echo "input 3 5" >> $COMMAND_FILE      # X3 = 5 (no brancha)
            echo "input 6 10" >> $COMMAND_FILE     # X6 = 10
            echo "input 7 10" >> $COMMAND_FILE     # X7 = 10 (para subs test)
            echo "input 12 65535" >> $COMMAND_FILE # X12 = 0xFFFF (no brancha)

            echo "rdump" >> $COMMAND_FILE         # estado inicial

            # primero CBZ (debería branchear)
            echo "run 3" >> $COMMAND_FILE         # movz + cbz + movz (después de branch)
            echo "rdump" >> $COMMAND_FILE         # X2 should be 2, X10 deberia ser 0 (skippea)

            # segundo CBZ (no debería branchear)
            echo "run 3" >> $COMMAND_FILE         # movz + cbz + movz (ejecutado)
            echo "rdump" >> $COMMAND_FILE         # X4 deberia ser 4, deberia ser 5

            # tercero CBZ (debería branchear)
            echo "run 4" >> $COMMAND_FILE         # movz + movz + subs + cbz
            echo "rdump" >> $COMMAND_FILE         # X8 deberia ser 0, Z=1
            echo "run 1" >> $COMMAND_FILE         # movz después brancha
            echo "rdump" >> $COMMAND_FILE         # X9 debería ser 9, X11 debería ser 0 (skippea)

            # cuarto CBZ (no debería branchear)
            echo "run 3" >> $COMMAND_FILE         # movz + cbz + movz
            echo "rdump" >> $COMMAND_FILE         # X13 debria ser 13, X14 deberia ser 14
            
            # HALT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE         # Estado final
            ;;

        test_cbnz)
            echo "Prueba de CBNZ (compara y branchea si no es cero)"

            echo "input 1 0" >> $COMMAND_FILE      # X1 = 0 (no branchea)
            echo "input 4 5" >> $COMMAND_FILE      # X4 = 5 (branchea)
            echo "input 6 15" >> $COMMAND_FILE     # X6 = 15
            echo "input 7 10" >> $COMMAND_FILE     # X7 = 10 (para subs test)

            echo "rdump" >> $COMMAND_FILE         # estado inicial

            # Ejecuta primer CBNZ (no debería branch)
            echo "run 3" >> $COMMAND_FILE         # movz + cbnz + movz 
            echo "rdump" >> $COMMAND_FILE         # X2 deberia ser 2, X3 deberia ser 3

            # Ejecuta segundo CBNZ (debería branch)
            echo "run 3" >> $COMMAND_FILE         # movz + cbnz + movz (después brancha)
            echo "rdump" >> $COMMAND_FILE         # X5 deberia ser 5, X10 deberia ser 0 (skippea)

            # Ejecuta tercer CBNZ (debería branch)
            echo "run 4" >> $COMMAND_FILE         # movz + movz + subs + cbnz
            echo "rdump" >> $COMMAND_FILE         # X8 deberia ser 5, Z=0
            echo "run 1" >> $COMMAND_FILE         # movz despues brancha
            echo "rdump" >> $COMMAND_FILE         # X9 deberia ser 9, X11 deberia ser 0 (skippea)

            # Ejecuta cuarto CBNZ (no debería branch)
            echo "run 3" >> $COMMAND_FILE         # movz + subs + cbnz
            echo "rdump" >> $COMMAND_FILE         # X12 deberia ser 0, Z=1
            echo "run 2" >> $COMMAND_FILE         # movz + movz
            echo "rdump" >> $COMMAND_FILE         # X13 debería ser 13, X14 debería ser 14

            # Ejecuta quinto CBNZ (debería branch)
            echo "run 4" >> $COMMAND_FILE         # movz + movz + subs + cbnz
            echo "rdump" >> $COMMAND_FILE         # X17 deberia ser -5, N=1, Z=0
            echo "run 1" >> $COMMAND_FILE         # movz después brancha
            echo "rdump" >> $COMMAND_FILE         # X18 debería ser 18, X19 debería ser 0 (skippea)

            # Execute HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE         # Estado final
            ;; 
        *)
    esac

    echo "quit" >> $COMMAND_FILE

    # Ejecuta el simulador de referencia
    $REF_SIM "$test_file" < $COMMAND_FILE > "$TEMP_DIR/ref_out.txt" 2>/dev/null
    # Ejecuta mi simulador
    $MY_SIM "$test_file" < $COMMAND_FILE > "$TEMP_DIR/my_out.txt" 2>/dev/null

    # Compara las salidas
    if diff -q "$TEMP_DIR/ref_out.txt" "$TEMP_DIR/my_out.txt" > /dev/null; then
        echo -e "${GREEN}✅ Test passed for $test_name${NC}"
        return 0
    else
        echo -e "${RED}❌ Test failed for $test_name${NC}"
        echo "Differences:"
        diff "$TEMP_DIR/ref_out.txt" "$TEMP_DIR/my_out.txt" | head -n 20
        return 1
    fi
}

# Función para ejecutar todos los tests
run_all_tests() {
    local total=0
    local passed=0

    for test_file in $TEST_DIR/*.x; do
        if [ -f "$test_file" ]; then
            total=$((total + 1))
            run_test "$test_file"
            if [ $? -eq 0 ]; then
                passed=$((passed + 1))
            fi
            echo "---------------------------------"
        fi
    done

    echo -e "${BLUE}Test summary: $passed out of $total tests passed${NC}"

    # Limpia archivos temporales
    if [ $passed -eq $total ]; then
        rm -rf $TEMP_DIR
    fi
}

# Ejecutar un test específico si se proporciona como argumento
if [ "$#" -eq 1 ]; then
    if [ -f "$TEST_DIR/$1.x" ]; then
        run_test "$TEST_DIR/$1.x"
    else
        echo "Test file $TEST_DIR/$1.x not found"
    fi
else
    # De lo contrario, ejecutar todos los tests
    run_all_tests
fi