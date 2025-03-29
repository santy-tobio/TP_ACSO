#!/bin/bash

cd src
make clean  # Siempre limpia primero
make

cd ..

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
REF_SIM="./ref_sim_x86"
MY_SIM="./src/sim"
TEST_DIR="./inputs"
TEMP_DIR="./temp_test"

# Crear directorio temporal si no existe
mkdir -p $TEMP_DIR

# Función para ejecutar y comparar un solo test
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .x)
    
    echo -e "${BLUE}Testing $test_name...${NC}"
    
    # Crear archivo de comandos para el simulador
    COMMAND_FILE="$TEMP_DIR/commands.txt"
    echo "rdump" > $COMMAND_FILE  # Estado inicial
    
    # Añadir comandos específicos según la instrucción que se está probando
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
        test_orr) 
            echo "Prueba de ORR"
        ;;
        test_b) 
            echo "Prueba de B (Branch)"
            # Configurar registros iniciales
            echo "input 0 0" >> $COMMAND_FILE       # X0 = 0
            echo "input 1 5" >> $COMMAND_FILE       # X1 = 5
            echo "input 2 0" >> $COMMAND_FILE       # X2 = 0
            echo "input 3 0" >> $COMMAND_FILE       # X3 = 0
            echo "input 4 0" >> $COMMAND_FILE       # X4 = 0
            echo "rdump" >> $COMMAND_FILE           # Mostrar estado inicial

            # Ejecutamos 2 instrucciones: adds + branch
            echo "run 2" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE           # Verificar el salto

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
            
            # Esto es clave: establecer X1 con la dirección del destino del salto
            # Calculamos la dirección: posición inicial (0x00400000) + 16 bytes (4 instrucciones)
            echo "input 1 0x00400010" >> $COMMAND_FILE  # Dirección donde está "adds x4, x4, 1"
            
            echo "input 2 0" >> $COMMAND_FILE           # X2 = 0
            echo "input 3 0" >> $COMMAND_FILE           # X3 = 0
            echo "input 4 0" >> $COMMAND_FILE           # X4 = 0
            
            echo "rdump" >> $COMMAND_FILE               # Mostrar estado inicial
            
            # Ejecutamos la primera instrucción (adds x0, x0, 5)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Verificar que X0 = 5
            
            # Ejecutamos la instrucción BR
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Verificar PC después del salto
            
            # Ejecutamos la instrucción destino (adds x4, x4, 1)
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Verificar que X4 = 1 y que X2, X3 siguen = 0
            
            # Ejecutamos hasta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE               # Estado final
            ;;
        test_bcond)
            echo "Prueba de B.cond (Branch Conditional)"
            
            # Inicializar registros
            for i in {10..23}; do
                echo "input $i 0" >> $COMMAND_FILE  # Inicializar x10-x23 a 0
            done
            echo "rdump" >> $COMMAND_FILE          # Estado inicial
            
            # Ejecutar hasta después de BEQ
            echo "run 5" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x11=1, x10=0
            
            # Ejecutar hasta después de BNE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x13=1, x12=0
            
            # Ejecutar hasta después de BGT
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x15=1, x14=0
            
            # Ejecutar hasta después de BLT
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x17=1, x16=0
            
            # Ejecutar hasta después de BGE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x19=1, x18=0
            
            # Ejecutar hasta después de primer BLE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x21=1, x20=0
            
            # Ejecutar hasta después de segundo BLE
            echo "run 4" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Verificar x23=1, x22=0
            
            # Ejecutar hasta HLT
            echo "run 1" >> $COMMAND_FILE
            echo "rdump" >> $COMMAND_FILE          # Estado final
            ;;
        *)
        # Caso genérico para otras instrucciones
        echo "input 0 1" >> $COMMAND_FILE
        echo "input 1 2" >> $COMMAND_FILE
        echo "input 2 3" >> $COMMAND_FILE
        echo "rdump" >> $COMMAND_FILE
        echo "run 1" >> $COMMAND_FILE
        echo "rdump" >> $COMMAND_FILE
        echo "run 1" >> $COMMAND_FILE
        echo "rdump" >> $COMMAND_FILE
        ;;
    esac
    
    echo "quit" >> $COMMAND_FILE

    # Ejecutar el simulador de referencia
    $REF_SIM "$test_file" < $COMMAND_FILE > "$TEMP_DIR/ref_out.txt" 2>/dev/null
    
    # Ejecutar mi simulador
    $MY_SIM "$test_file" < $COMMAND_FILE > "$TEMP_DIR/my_out.txt" 2>/dev/null
    
    # Comparar las salidas
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
    
    # Limpiar archivos temporales
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