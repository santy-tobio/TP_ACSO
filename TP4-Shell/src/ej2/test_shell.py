#!/usr/bin/env python3

import os
import subprocess
import tempfile
import time
from typing import List, Tuple

class ShellTester:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.total = 0
        self.test_file = "test_data.txt"
        
        # Colores para output
        self.GREEN = '\033[92m'
        self.RED = '\033[91m'
        self.YELLOW = '\033[93m'
        self.BLUE = '\033[94m'
        self.RESET = '\033[0m'
        
    def setup(self):
        """Compilar el shell y crear archivos de prueba"""
        print(f"{self.BLUE}🔨 Compilando shell...{self.RESET}")
        
        # Compilar
        result = subprocess.run(['make'], capture_output=True, text=True)
        if result.returncode != 0:
            print(f"{self.RED}❌ Error compilando: {result.stderr}{self.RESET}")
            return False
            
        if not os.path.exists('./shell'):
            print(f"{self.RED}❌ No se generó el binario 'shell'{self.RESET}")
            return False
            
        # Crear archivo de prueba con contenido fijo
        with open(self.test_file, 'w') as f:
            f.write("archivo.txt\n")
            f.write("imagen.png\n") 
            f.write("documento.zip\n")
            f.write("video.mp4\n")
            f.write("codigo.c\n")
            f.write("script.sh\n")
            
        print(f"{self.GREEN}✅ Compilación exitosa{self.RESET}")
        return True
        
    def cleanup(self):
        """Limpiar archivos temporales"""
        subprocess.run(['make', 'clean'], capture_output=True)
        if os.path.exists(self.test_file):
            os.remove(self.test_file)
            
    def run_shell_command(self, command: str, timeout: int = 3) -> Tuple[str, str, int]:
        """Ejecutar comando en nuestro shell - versión simplificada"""
        try:
            # Crear input completo de una vez
            shell_input = f"{command}\nexit\n"
            
            result = subprocess.run(
                ['./shell'],
                input=shell_input,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            # Limpiar output del shell
            lines = result.stdout.split('\n')
            clean_lines = []
            
            for line in lines:
                # Saltar líneas del shell
                if line.strip().startswith('Shell>'):
                    continue
                if line.strip() == '':
                    continue
                    
                clean_lines.append(line)
                        
            clean_stdout = '\n'.join(clean_lines).strip()
                
            return clean_stdout, result.stderr, result.returncode
            
        except subprocess.TimeoutExpired:
            return "", "TIMEOUT", -1
            
    def run_bash_command(self, command: str) -> Tuple[str, str, int]:
        """Ejecutar comando en bash para comparar"""
        try:
            result = subprocess.run(
                ['bash', '-c', command],
                capture_output=True,
                text=True,
                timeout=3
            )
            stdout = result.stdout.strip()
            return stdout, result.stderr, result.returncode
        except subprocess.TimeoutExpired:
            return "", "TIMEOUT", -1
            
    def test_command(self, command: str, description: str, should_fail: bool = False):
        """Probar un comando específico"""
        self.total += 1
        print(f"\n{self.YELLOW}📋 Test {self.total}: {description}{self.RESET}")
        print(f"   {self.BLUE}Comando:{self.RESET} {command}")
        
        # Ejecutar en nuestro shell
        shell_out, shell_err, shell_code = self.run_shell_command(command)
        
        if should_fail:
            # Para comandos que deberían fallar
            if shell_err or shell_code != 0:
                print(f"   {self.GREEN}✅ OK - Error detectado correctamente{self.RESET}")
                self.passed += 1
            else:
                print(f"   {self.RED}❌ FALLO - Debería haber fallado{self.RESET}")
                self.failed += 1
        else:
            # Ejecutar en bash para comparar
            bash_out, bash_err, bash_code = self.run_bash_command(command)
            
            if shell_out == bash_out:
                print(f"   {self.GREEN}✅ OK - Salida correcta{self.RESET}")
                self.passed += 1
            else:
                print(f"   {self.RED}❌ FALLO - Salida incorrecta{self.RESET}")
                print(f"   {self.BLUE}Esperado:{self.RESET}")
                for line in bash_out.split('\n')[:3]:
                    print(f"     '{line}'")
                print(f"   {self.BLUE}Obtenido:{self.RESET}")  
                for line in shell_out.split('\n')[:3]:
                    print(f"     '{line}'")
                self.failed += 1
                
    def run_basic_tests(self):
        """Tests básicos que no dependen del contenido del directorio"""
        print(f"{self.BLUE}🚀 Iniciando tests básicos{self.RESET}")
        
        # Tests con echo (predecibles)
        self.test_command("echo hello", "Echo simple")
        self.test_command("echo hello world", "Echo múltiples palabras")
        self.test_command("echo", "Echo sin argumentos")
        
        # Tests con archivo de datos fijo
        self.test_command(f"cat {self.test_file}", "Cat archivo fijo")
        self.test_command(f"cat {self.test_file} | wc -l", "Cat + wc líneas")
        self.test_command(f"cat {self.test_file} | grep .txt", "Cat + grep .txt")
        self.test_command(f"cat {self.test_file} | grep .c", "Cat + grep .c")
        
        # Tests con pipes
        self.test_command("echo hello | wc -l", "Echo + wc")
        self.test_command("echo -e 'a\\nb\\nc' | wc -l", "Echo multilinea + wc")
        
        # Pipelines largos
        self.test_command("echo hello | cat | cat | cat", "Pipeline 4 procesos")
        self.test_command(f"cat {self.test_file} | head -3 | tail -1", "Pipeline head + tail")
        
        # Tests de error
        self.test_command("nonexistentcommand", "Comando inexistente", should_fail=True)
        self.test_command("cat /nonexistent/file", "Archivo inexistente", should_fail=True)
        
    def run_directory_tests(self):
        """Tests que pueden depender del directorio - solo verificar que no crasheen"""
        print(f"\n{self.BLUE}🚀 Tests de directorio (verificación básica){self.RESET}")
        
        # Para estos, solo verificamos que no crasheen
        commands = [
            "ls",
            "ls -l", 
            "ls | wc -l",
            "ls | head -3"
        ]
        
        for cmd in commands:
            self.total += 1
            print(f"\n{self.YELLOW}📋 Test {self.total}: {cmd} (verificación de funcionamiento){self.RESET}")
            
            shell_out, shell_err, shell_code = self.run_shell_command(cmd)
            
            # Solo verificar que no crashee y que produzca alguna salida
            if shell_out or shell_code == 0:
                print(f"   {self.GREEN}✅ OK - Comando ejecutado sin crash{self.RESET}")
                self.passed += 1
            else:
                print(f"   {self.RED}❌ FALLO - Comando crasheó{self.RESET}")
                print(f"   Error: {shell_err}")
                self.failed += 1
                
    def print_summary(self):
        """Imprimir resumen final"""
        print(f"\n{self.BLUE}{'='*50}{self.RESET}")
        print(f"{self.YELLOW}RESUMEN FINAL{self.RESET}")
        print(f"Total tests: {self.total}")
        print(f"{self.GREEN}Exitosos: {self.passed}{self.RESET}")
        print(f"{self.RED}Fallidos: {self.failed}{self.RESET}")
        
        if self.failed == 0:
            print(f"{self.GREEN}🎉 ¡Todos los tests pasaron!{self.RESET}")
        else:
            print(f"{self.RED}💥 {self.failed} tests fallaron{self.RESET}")
            
        print(f"{self.BLUE}{'='*50}{self.RESET}")

def main():
    tester = ShellTester()
    
    if not tester.setup():
        return 1
        
    try:
        tester.run_basic_tests()
        tester.run_directory_tests()
        tester.print_summary()
    finally:
        tester.cleanup()
        
    return 0 if tester.failed == 0 else 1

if __name__ == "__main__":
    exit(main())