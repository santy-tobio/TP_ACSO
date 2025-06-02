#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMANDS 200
#define MAX_ARGS 256
#define MAX_CMD_LEN 256
#define READ_END 0
#define WRITE_END 1

void create_command_pipes(int pipes[][2], int pipe_count) {
    for (int i = 0; i < pipe_count; i++) {
        if (pipe(pipes[i]) < 0) {
            perror("Error al crear el pipe");
            exit(1);
        }
    }
}

void parse_command_args(char *command_copy, char *cmd_args[], int *arg_count) {
    *arg_count = 0;
    
    char *token = strtok(command_copy, " ");
    while (token != NULL) {
        cmd_args[(*arg_count)++] = token;
        token = strtok(NULL, " ");
    }
    cmd_args[*arg_count] = NULL;
}

void execute_command(int pipes[][2], int command_count, int cmd_index, char *cmd_args[]) {
    // siempre leemos del pipe anterior y escribimos en este
    // excepto el primer y último comando
    // redireccionamos la entrada y salida estándar a estos pipes
    if (cmd_index > 0) {
        dup2(pipes[cmd_index - 1][READ_END], STDIN_FILENO);
        close(pipes[cmd_index - 1][READ_END]);
    }
    if (cmd_index < command_count - 1) {
        dup2(pipes[cmd_index][WRITE_END], STDOUT_FILENO);
        close(pipes[cmd_index][WRITE_END]);
    }
    
    // cerramos todos los pipes que no usa este hijo
    for (int j = 0; j < command_count - 1; j++) {
        // los primero chequeos de los if's son para atajar casos bordes
        if (cmd_index == 0 || j != cmd_index - 1) {
            close(pipes[j][READ_END]);
        }
        if (cmd_index == command_count - 1 || j != cmd_index) {
            close(pipes[j][WRITE_END]);
        }
    }
    
    execvp(cmd_args[0], cmd_args);
    perror("execvp"); // si execvp anda, no debería llegar acá
    exit(1);
}

void parent_cleanup(int pipes[][2], int command_count) {
    // cerramos todos los pipes de los hijos en el padre
    for (int i = 0; i < command_count - 1; i++) {
        close(pipes[i][READ_END]);
        close(pipes[i][WRITE_END]);
    }

    // esperamos a todos los hijos
    for (int i = 0; i < command_count; i++) {
        wait(NULL);
    }
}

int main() {
    char command[256];
    char *commands[MAX_COMMANDS];
    int command_count;

    while (1) {
        command_count = 0; // reiniciamos el contador para cada iteración del while
        printf("Shell> ");
        
        /* Reads a line of input from the user from the standard input (stdin) and stores it in the variable command */
        fgets(command, sizeof(command), stdin);
        
        /* Removes the newline character (\n) from the end of the string stored in command, if present.
           This is done by replacing the newline character with the null character ('\0').
           The strcspn() function returns the length of the initial segment of command that consists of
           characters not in the string specified in the second argument ("\n" in this case). */
        command[strcspn(command, "\n")] = '\0';

        if (strcmp(command, "exit") == 0) {
            break;
        }
        if (strlen(command) == 0) {
            continue;
        }

        /* Tokenizes the command string using the pipe character (|) as a delimiter using the strtok() function.
           Each resulting token is stored in the commands[] array.
           The strtok() function breaks the command string into tokens (substrings) separated by the pipe character |.
           In each iteration of the while loop, strtok() returns the next token found in command.
           The tokens are stored in the commands[] array, and command_count is incremented to keep track of the number of tokens found. */
        char *token = strtok(command, "|");
        while (token != NULL) {
            commands[command_count++] = token;
            token = strtok(NULL, "|");
        }

        /* You should start programming from here... */

        int pipes[command_count - 1][2];
        create_command_pipes(pipes, command_count - 1);
        
        for (int i = 0; i < command_count; i++) {
            char *cmd_args[MAX_ARGS];
            int arg_count = 0;
            char command_copy[MAX_CMD_LEN];
            strcpy(command_copy, commands[i]);
            parse_command_args(command_copy, cmd_args, &arg_count);
            
            pid_t pid = fork();

            if (pid == 0) {
                execute_command(pipes, command_count, i, cmd_args);
            } else if (pid < 0) {
                perror("fork falló");
                exit(1);
            }
        }
        
        parent_cleanup(pipes, command_count);
    }
    
    return 0;
}