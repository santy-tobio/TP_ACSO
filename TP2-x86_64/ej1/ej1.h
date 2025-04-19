#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>

#define USE_ASM_IMPL 0
// en 1 se usa la implementacion en asm,
// en 0 se usa la de C

/** Lista **/
typedef struct string_proc_list_t {
	struct string_proc_node_t* first;
	struct string_proc_node_t* last;
} string_proc_list;

/** Nodo **/
typedef struct string_proc_node_t {
	struct string_proc_node_t* next;
	struct string_proc_node_t* previous;
	uint8_t type;
	char* hash;
} string_proc_node;
       
/** Funciones a implementar:  **/

// inicializa la estructura de la lista y la retorna
string_proc_list* string_proc_list_create(void);
string_proc_list* string_proc_list_create_asm(void);

/**
inicializa un nodo con el tipo y el hash dado
el nodo tinee que apuntar al hash (no hay que copiarlo)
**/
string_proc_node* string_proc_node_create(uint8_t type, char* hash);
string_proc_node* string_proc_node_create_asm(uint8_t type, char* hash);


/**
agrega un nodo a la lista, con su tipo y su hash
el nodo tiene que apuntar al hash (no hay que copiarlo)
**/
void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash);
void string_proc_list_add_node_asm(string_proc_list* list, uint8_t type, char* hash);


/**
genera un nuevo hash concatenando el pasado por parametro a 
los hashes de los nodos de la lista cuyos tipos coindicen
con el tipo pasado por parametro.
 */
char* string_proc_list_concat(string_proc_list* list, uint8_t type, char* hash);
char* string_proc_list_concat_asm(string_proc_list* list, uint8_t type, char* hash);

/** Funciones Auxiliares:**/

/**
 * Libera la memoria de la lista y sus nodos.
*/
void string_proc_list_destroy(string_proc_list* list);

/**
 * Libera la memoria del nodo.
*/
void string_proc_node_destroy(string_proc_node* node);

/**
 * 	Concatena dos strings a y b. 
 *  Retorna el resultado en uno nuevo, creado via malloc.
*/
char* str_concat(char* a, char* b);

/**
 *  Imprime la lista list en el archivo file.
*/
void string_proc_list_print(string_proc_list* list, FILE* file);
