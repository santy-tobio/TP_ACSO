#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define READ_END 0
#define WRITE_END 1

void parse_args(int argc, char **argv, int *n, int *message, int *start) {
    if (argc != 4) { 
        printf("Uso: anillo <n> <c> <s> \n"); 
        exit(0);
    }
    
    // Los argumentos siempre van desde argv[1] hasta argv[argc-1]
    *n = atoi(argv[1]);       // cantidad de procesos hijos
    *message = atoi(argv[2]); // mensaje inicial, casteamos a entero desde char
    *start = atoi(argv[3]);   // numero del proceso que envía el mensaje inicial

    if (*n <= 0) {
        printf("Error: n debe ser mayor que 0\n");
        exit(1);
    }
    if (*start < 0 || *start >= *n) {
        printf("Error: start debe estar entre 0 y %d\n", *n - 1);
        exit(1);
    }
}

void create_pipes(int pipes[][2], int n) {
    for (int i = 0; i < n; i++) {
        if (pipe(pipes[i]) < 0) { 
            perror("Error al crear el pipe");
            exit(1);
        }
        printf("Pipe %d creado: read_fd=%d, write_fd=%d\n", 
               i, pipes[i][READ_END], pipes[i][WRITE_END]);
    }
}

void child_process(int pipes[][2], int n, int child_id) {
    // cerramos los pipes que no usa este hijo
    for (int j = 0; j < n; j++) {
        if (j != child_id) {
            close(pipes[j][READ_END]); // todos los pipes de lectura excepto el propio 
        }
        if (j != (child_id + 1) % n) {
            close(pipes[j][WRITE_END]); // todos los pipes de escritura excepto el siguiente
        }
    }

    int valor;
    read(pipes[child_id][READ_END], &valor, sizeof(valor)); 
    // esto funciona porque read bloquea hasta que hay datos disponibles
    valor++;
    write(pipes[(child_id + 1) % n][WRITE_END], &valor, sizeof(valor)); 
    exit(0); 
}

void parent_process(int pipes[][2], int start, int *buffer) {
    // no cerramos los pipes del proceso a los 
    // hijos porque con el exit() se cierran automáticamente
    write(pipes[start][WRITE_END], buffer, sizeof(int));
    close(pipes[start][WRITE_END]); // cerramos el pipe cuando escribe el padre
    wait(NULL); // sin el wait a cualquier hijo tenemos una race condition
    
    int resultado;
    read(pipes[start][READ_END], &resultado, sizeof(resultado));
    printf("Resultado final: %d\n", resultado);
}

int main(int argc, char **argv) {
    int start, pid, n;
    int buffer[1];
    parse_args(argc, argv, &n, &buffer[0], &start);

    printf("Se crearán %i procesos, se enviará el caracter %i desde proceso %i \n",
           n, buffer[0], start);
    
    int pipes[n][2];
    create_pipes(pipes, n);

    for (int i = 0; i < n; i++) {
        pid = fork();
        if (pid == 0) {
            child_process(pipes, n, i);
        } else if (pid < 0) {
            perror("Error al crear el proceso hijo");
            exit(1);
        }
    }
    
    parent_process(pipes, start, buffer);
    
    return 0;
}