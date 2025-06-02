#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMANDS 200
#define MAX_COMMAND_LENGTH 256
#define MAX_ARGS 256


int main() {

    char command[256];
    char *commands[MAX_COMMANDS];
    int command_count;

    while (1) 
    {
        command_count = 0; // reiniciamos el contador para cada iteración del while
        printf("Shell> ");
        
        /*Reads a line of input from the user from the standard input (stdin) and stores it in the variable command */
        fgets(command, sizeof(command), stdin);
        
        /* Removes the newline character (\n) from the end of the string stored in command, if present. 
           This is done by replacing the newline character with the null character ('\0').
           The strcspn() function returns the length of the initial segment of command that consists of 
           characters not in the string specified in the second argument ("\n" in this case). */
        command[strcspn(command, "\n")] = '\0';

        if (strcmp(command, "exit") == 0) {break;}
        if (strlen(command) == 0) {continue;}

        /* Tokenizes the command string using the pipe character (|) as a delimiter using the strtok() function. 
           Each resulting token is stored in the commands[] array. 
           The strtok() function breaks the command string into tokens (substrings) separated by the pipe character |. 
           In each iteration of the while loop, strtok() returns the next token found in command. 
           The tokens are stored in the commands[] array, and command_count is incremented to keep track of the number of tokens found. */
        char *token = strtok(command, "|");
        while (token != NULL) 
        {
            commands[command_count++] = token;
            token = strtok(NULL, "|");
        }

        /*You should start programming from here... */

        //! primero hacemos los pipes para comunicar los procesos (comandos)
        int pipes[command_count - 1][2]; 
        for (int i = 0; i < command_count - 1; i++) 
        {
            if (pipe(pipes[i]) < 0) 
            {
                perror("Error al crear el pipe");
                exit(1);
            }
        }
        // el comando i escribe en el pipe i+1[1] y lee del pipe i[0]
        // cerramos los pipes que no usa cada hijo
        
        for (int i = 0; i < command_count; i++) 
        {
            //printf("Command %d: %s\n", i, commands[i]);
            // primero parseamos los comandos
            char *cmd_args[256]; 
            int arg_count = 0;
            
            // copiamos los comandos porque strtok modifica la cadena original
            char command_copy[256];
            strcpy(command_copy, commands[i]);          

            char *token = strtok(command_copy, " ");
            while (token != NULL) 
            {
                cmd_args[arg_count++] = token;
                token = strtok(NULL, " ");
            }
            cmd_args[arg_count] = NULL; // marcamos el final

            pid_t pid = fork();

            if (pid == 0) 
            {
                // siempre leemos del pipe anterior y escribimos en este
                // excepto el primer y último comando
                // redireccionamos la entrada y salida estándar a estos pipes
                if (i > 0) {dup2(pipes[i-1][0], STDIN_FILENO); }
                if (i < command_count-1) {dup2(pipes[i][1], STDOUT_FILENO);}
                
                // cerramos todos los pipes que no usa este hijo
                for (int j = 0; j < command_count-1; j++) 
                {
                    // los primero chequeos de los if's son para atajar casos bordes
                    if (i == 0 || j != i-1) {close(pipes[j][0]);}
                    if (i == command_count-1 || j != i) {close(pipes[j][1]);}
                }
                
                execvp(cmd_args[0], cmd_args);
                perror("execvp"); // si execvp anda, no debería llegar acá
                exit(1);
            }

            else if (pid < 0) 
            {
                perror("fork falló");
                exit(1);
            }    
    }
    // cerramos todos los pipes de los hijos en el padre
    for (int i = 0; i < command_count-1; i++) 
    {
        close(pipes[i][0]);
        close(pipes[i][1]);
    }

    // esperamos a todos los hijos 
    for (int i = 0; i < command_count; i++) 
    {
        wait(NULL);
    }

    }
    return 0;
}
