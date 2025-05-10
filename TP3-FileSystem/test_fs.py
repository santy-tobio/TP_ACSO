#!/usr/bin/env python3

import subprocess
import os
import sys
import argparse

# Colores ANSI para salida en terminal
class Colors:
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'  # No Color

def print_color(text, color):
    """Imprime texto con color en la terminal"""
    print(color + text + Colors.NC)

def compile_project():
    """Compila el proyecto"""
    print_color("Compilando el proyecto...", Colors.YELLOW)
    process = subprocess.run(["make"], capture_output=True, text=True)
    
    if process.returncode != 0:
        print_color("Error al compilar:", Colors.RED)
        print(process.stderr)
        sys.exit(1)
    print_color("Compilación exitosa", Colors.GREEN)

def test_function(function_name, save_files=False):
    """Prueba una función específica del proyecto"""
    disk_images = ["basicDiskImage", "depthFileDiskImage", "dirFnameSizeDiskImage"]
    
    function_map = {
        "inode": {"option": "i", "message": "Funciones de inodo (inode_iget, inode_indexlookup)"},
        "file": {"option": "i", "message": "Funciones de archivo (file_getblock)"},
        "directory": {"option": "p", "message": "Funciones de directorio (directory_findname)"},
        "pathname": {"option": "p", "message": "Funciones de ruta (pathname_lookup)"}
    }
    
    if function_name not in function_map:
        print_color(f"Función '{function_name}' no reconocida", Colors.RED)
        print_color(f"Opciones válidas: {', '.join(function_map.keys())}", Colors.YELLOW)
        return
    
    print_color(f"\n=== Probando {function_map[function_name]['message']} ===\n", Colors.BLUE)
    
    for disk in disk_images:
        disk_path = f"samples/testdisks/{disk}"
        print_color(f"Probando con {disk}:", Colors.YELLOW)
        
        option = function_map[function_name]["option"]
        gold_file = f"samples/testdisks/{disk}.gold"
        
        # Ejecutar el programa con la opción correcta (corregido)
        process = subprocess.run(
            ["./diskimageaccess", "-q", f"-{option}", disk_path],
            capture_output=True, text=True
        )
        
        if process.returncode != 0:
            print_color("✗ Error al ejecutar la prueba", Colors.RED)
            print(process.stderr)
            continue
            
        print_color("✓ Ejecución exitosa", Colors.GREEN)
        
        # Comparar con el archivo gold
        if os.path.exists(gold_file):
            # Crear un archivo temporal con la salida actual
            with open(".temp_output.txt", "w") as f:
                f.write(process.stdout)
            
            # Comparar con el archivo gold
            diff_process = subprocess.run(
                ["diff", ".temp_output.txt", gold_file], 
                capture_output=True, text=True
            )
            
            if diff_process.returncode == 0:
                print_color("✓ Resultado correcto (coincide con el esperado)", Colors.GREEN)
            else:
                print_color("✗ Hay diferencias con el resultado esperado", Colors.RED)
                
                # Mostrar un resumen de las diferencias
                if diff_process.stdout:
                    print_color("\nResumen de diferencias:", Colors.WHITE)
                    diff_lines = diff_process.stdout.splitlines()
                    # Mostrar solo las primeras 10 líneas de diferencias para no saturar la terminal
                    for i, line in enumerate(diff_lines[:10]):
                        if line.startswith('<'):
                            print(Colors.RED + line + Colors.NC)
                        elif line.startswith('>'):
                            print(Colors.GREEN + line + Colors.NC)
                        else:
                            print(line)
                    
                    if len(diff_lines) > 10:
                        print_color(f"... y {len(diff_lines) - 10} líneas más", Colors.YELLOW)
                
                # Guardar las diferencias si se solicita
                if save_files:
                    diff_file = f"{function_name}_{disk}_diff.txt"
                    with open(diff_file, "w") as f:
                        f.write(diff_process.stdout)
                    print_color(f"Diferencias guardadas en {diff_file}", Colors.YELLOW)
            
            # Eliminar el archivo temporal
            os.remove(".temp_output.txt")
        else:
            print_color(f"⚠ No se encontró archivo gold para comparar: {gold_file}", Colors.RED)
        
        print()  # Línea en blanco para separar resultados

def main():
    parser = argparse.ArgumentParser(description='Prueba las funciones del filesystem')
    parser.add_argument('function', choices=['inode', 'file', 'directory', 'pathname', 'all'],
                        help='Función a probar (inode, file, directory, pathname, all)')
    parser.add_argument('--save', action='store_true', 
                        help='Guardar archivos de diferencias')
    
    args = parser.parse_args()
    
    compile_project()
    
    if args.function == 'all':
        for func in ['inode', 'file', 'directory', 'pathname']:
            test_function(func, args.save)
    else:
        test_function(args.function, args.save)
    
    print_color("\nPruebas completadas.", Colors.GREEN)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        # Si no se proporcionan argumentos, mostrar ayuda
        print_color("Uso: ./test_fs.py [función] [--save]", Colors.YELLOW)
        print_color("\nFunciones disponibles:", Colors.WHITE)
        print("  inode     - Prueba las funciones de inodos (inode_iget, inode_indexlookup)")
        print("  file      - Prueba las funciones de archivo (file_getblock)")
        print("  directory - Prueba las funciones de directorio (directory_findname)")
        print("  pathname  - Prueba las funciones de ruta (pathname_lookup)")
        print("  all       - Prueba todas las funciones")
        print_color("\nOpciones:", Colors.WHITE)
        print("  --save    - Guarda los archivos de diferencias para análisis posterior")
        sys.exit(0)
    
    main()