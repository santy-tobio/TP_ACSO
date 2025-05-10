#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'

def run_command(cmd, capture_output=True):
    """Ejecuta un comando y retorna su resultado"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=capture_output, text=True)
        return result
    except Exception as e:
        print(f"{Colors.RED}Error ejecutando: {cmd}{Colors.RESET}")
        print(f"Error: {e}")
        return None

def check_executable():
    """Verifica que el ejecutable exista"""
    if not os.path.exists('./diskimageaccess'):
        print(f"{Colors.RED}El ejecutable 'diskimageaccess' no existe. Por favor, ejecuta 'make' primero.{Colors.RESET}")
        return False
    return True

def test_disk(disk_name, options='-ip'):
    """Ejecuta tests para un disco específico"""
    disk_path = f"./samples/testdisks/{disk_name}"
    gold_file = f"./samples/testdisks/{disk_name}.gold"
    output_file = f"./test_output_{disk_name}.txt"
    
    # Verificar que el disco existe
    if not os.path.exists(disk_path):
        print(f"{Colors.RED}  ❌ Disco {disk_name} no encontrado{Colors.RESET}")
        return False
    
    # Ejecutar el test
    cmd = f"./diskimageaccess {options} {disk_path} > {output_file}"
    print(f"  Ejecutando: {cmd}")
    result = run_command(cmd)
    
    if result and result.returncode != 0:
        print(f"{Colors.RED}  ❌ Error al ejecutar diskimageaccess{Colors.RESET}")
        return False
    
    # Comparar con el archivo gold
    if os.path.exists(gold_file):
        cmd = f"diff {output_file} {gold_file}"
        result = run_command(cmd)
        
        if result and result.returncode == 0:
            print(f"{Colors.GREEN}  ✅ Test pasado correctamente{Colors.RESET}")
            return True
        else:
            print(f"{Colors.RED}  ❌ Test falló - Diferencias encontradas:{Colors.RESET}")
            print(result.stdout)
            return False
    else:
        print(f"{Colors.YELLOW}  ⚠️  Archivo gold no encontrado para {disk_name}{Colors.RESET}")
        return False

def run_valgrind_tests():
    """Ejecuta los tests con valgrind"""
    print(f"\n{Colors.YELLOW}Ejecutando tests con valgrind...{Colors.RESET}")
    
    disks = [
        "basicDiskImage",
        "depthFileDiskImage", 
        "dirFnameSizeDiskImage"
    ]
    
    for disk in disks:
        print(f"\nTesting {disk} con valgrind...")
        
        # Test solo inodos
        cmd = f"valgrind ./diskimageaccess -qi samples/testdisks/{disk}"
        print(f"  {cmd}")
        result = run_command(cmd, capture_output=False)
        
        # Test solo paths
        cmd = f"valgrind ./diskimageaccess -qp samples/testdisks/{disk}"
        print(f"  {cmd}")
        result = run_command(cmd, capture_output=False)

def main():
    print(f"🧪 {Colors.YELLOW}Script de Automatización de Tests para TP3 FileSystem{Colors.RESET}\n")
    
    # Verificar que el ejecutable exista
    if not check_executable():
        return 1
    
    # Tests básicos
    print(f"\n{Colors.YELLOW}1. Ejecutando tests básicos...{Colors.RESET}")
    
    test_results = []
    disks = [
        "basicDiskImage",
        "depthFileDiskImage",
        "dirFnameSizeDiskImage"
    ]
    
    for disk in disks:
        print(f"\nTesting {disk}...")
        result = test_disk(disk)
        test_results.append((disk, result))
    
    # Tests de valgrind se ejecutan automáticamente
    run_valgrind_tests()
    
    # Resumen de resultados
    print(f"\n{Colors.YELLOW}📊 Resumen de Resultados:{Colors.RESET}")
    for disk, result in test_results:
        status = f"{Colors.GREEN}✅ PASADO{Colors.RESET}" if result else f"{Colors.RED}❌ FALLÓ{Colors.RESET}"
        print(f"  {disk}: {status}")
    
    # Limpiar archivos temporales
    for disk in disks:
        temp_file = f"./test_output_{disk}.txt"
        if os.path.exists(temp_file):
            os.remove(temp_file)
    
    # Determinar código de salida
    all_passed = all(result for _, result in test_results)
    return 0 if all_passed else 1

if __name__ == "__main__":
    print("Uso: python3 test_runner.py")
    print("  Ejecuta tests básicos y valgrind automáticamente")
    print()
    sys.exit(main())