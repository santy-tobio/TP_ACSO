#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>


int main(int argc, char **argv)
{	
	int start, pid, n;
	int buffer[1];

	if (argc != 4){ printf("Uso: anillo <n> <c> <s> \n"); exit(0);}
	    
	// Los argumentos siempre van desde argv[1] hasta argv[argc-1]

	n = atoi(argv[1]); // cantidad de procesos hijos
	buffer[0] = atoi(argv[2]); // mensaje inicial , casteamos a entero desde char
	start = atoi(argv[3]); // numero del proceso que envía el mensaje inicial

	if (n <= 0) {printf("Error: n debe ser mayor que 0\n"); exit(1);}
	if (start < 0 || start >= n) {printf("Error: start debe estar entre 0 y %d\n", n-1);exit(1);}

    printf("Se crearán %i procesos, se enviará el caracter %i desde proceso %i \n"
		, n, buffer[0], start);
    
	int pipes[n][2];
	for (int i = 0; i < n; i++) {
		if (pipe(pipes[i]) < 0) { 
			perror("Error al crear el pipe");
			exit(1);
		}
		printf("Pipe %d creado: read_fd=%d, write_fd=%d\n", 
			i, pipes[i][0], pipes[i][1]);
	}

	for (int i = 0; i < n; i++){

		pid = fork();

		if (pid == 0) { 

			// cerramos los pipes que no usa este hijo
			for (int j=0; j < n; j++) {
				if (j != i) {close(pipes[j][0]);} // todos los pipes de lectura excepto el propio 
				if (j != (i+1)%n) {close(pipes[j][1]);}  // todos los pipes de escritura excepto el siguiente
			}

			int valor;
			read(pipes[i][0], &valor, sizeof(valor)); 
			// esto funciona porque read bloquea hasta que hay datos disponibles
			valor++; 
			write(pipes[(i+1)%n][1], &valor, sizeof(valor)); 
			exit(0); 
		}
		
		else if (pid < 0) {
			perror("Error al crear el proceso hijo");
			exit(1);
		}
	}

	// no cerramos los pipes del proceso a los 
	// hijos porque con el exit() se cierran automáticamente
	write(pipes[start][1], buffer, sizeof(int));
	close(pipes[start][1]);  // cerramos el pipe cuando escribe el padre
	wait(NULL); // sin el wait a cualquier hijo tenemos una race condition
	int resultado;
	read(pipes[start][0], &resultado, sizeof(resultado));
	printf("Resultado final: %d\n", resultado);
	return 0;
}
