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