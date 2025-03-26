#!/bin/bash
# run_tests.sh

# Compilar el simulador y tests
make clean
make sim
make test

# Ejecutar pruebas individuales
./test_sim

# Ejecutar tests con archivos de entrada
for test_file in inputs/*.x; do
    echo "Testing $test_file"
    ./sim $test_file > /dev/null
    
    # Comparar resultado con el de referencia
    ./ref_sim $test_file > ref_out.txt
    ./sim $test_file > my_out.txt
    diff ref_out.txt my_out.txt
    
    if [ $? -eq 0 ]; then
        echo "✅ Paso el test"
    else
        echo "❌ Fallo el test"
    fi
done