; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat
extern strlen
extern strcpy
extern strcat

string_proc_list_create_asm:

    push rbp                   
    mov rbp, rsp               
    
    mov rdi, 16             
    call malloc              
    
    test rax, rax              ; vemos si malloc falló
    jz .return                  
    
    mov QWORD [rax], 0         ; list->first = NULL
    mov QWORD [rax + 8], 0     ; list->last = NULL
    
.return:
    mov rsp, rbp              
    pop rbp                   
    ret                    


string_proc_node_create_asm:

    push rbp                    
    mov rbp, rsp               
    push r12                  
    push r13
    
    ; Guardar los parámetros
    movzx r12, dil             ; r12 = type (uint8_t está en el byte menos significativo de RDI)
    mov r13, rsi               ; r13 = hash (char*)
    
    mov rdi, 32                ; sizeof(string_proc_node) = 32 bytes (2 punteros + uint8_t + char*)
    call malloc                
    
    test rax, rax              
    jz .return                
    
    mov QWORD [rax], 0         ; node->next = NULL
    mov QWORD [rax + 8], 0     ; node->previous = NULL
    mov BYTE [rax + 16], r12b  ; node->type = type
    mov QWORD [rax + 24], r13  ; node->hash = hash
    
.return:
    pop r13                    
    pop r12
    mov rsp, rbp               
    pop rbp                    
    ret                        


string_proc_list_add_node_asm:

push rbp                    
    mov rbp, rsp               
    push rbx                  
    push r12
    push r13
    push r14
    
    mov rbx, rdi               ; rbx = list
    movzx r12, sil             ; r12 = type (extendiendo a 64 bits)
    mov r13, rdx               ; r13 = hash
    
    test rbx, rbx
    jz .done                   
    
    mov rdi, r12               ; pasamos type
    mov rsi, r13               ; pasamos hash
    call string_proc_node_create_asm  
    
    mov r14, rax               ; r14 = nuevo nodo
    test r14, r14              ; chequeamos si fallo
    jz .done                   
    
    mov rcx, [rbx]             ; rcx = list->first
    test rcx, rcx              ; es list->first NULL?
    jnz .not_empty             ; si no es NULL, la lista no está vacía

    mov [rbx], r14             ; list->first = node
    mov [rbx + 8], r14         ; list->last = node
    jmp .done                
    
.not_empty:
    
    mov rcx, [rbx + 8]         ; rcx = list->last
    
    mov [rcx], r14             ; list->last->next = node (next está en offset 0)
    mov [r14 + 8], rcx         ; node->previous = list->last (previous está en offset 8)
    mov [rbx + 8], r14        
    
.done:
    pop r14                    
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp              
    pop rbp                    
    ret                        

string_proc_list_concat_asm:

    push rbp                   
    mov rbp, rsp              
    push rbx                  
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16                ; reservamos espacio para variables locales 
    
    mov rbx, rdi               ; rbx = list
    movzx r12, sil             ; r12 = type (extendiendo a 64 bits)
    mov r13, rdx               ; r13 = hash
    

    test rbx, rbx
    jz .error                  ; si list es NULL
    test r13, r13
    jz .error                  ; si hash es NULL
    
    ; Calcular la longitud total
    mov r14, 0                 ; r14 = longitud total = 0
    mov r15, [rbx]             ; r15 = current_node = list->first
    
.length_loop:
    test r15, r15              ; es NULL current_node?               
    jz .alloc_memory           
    
    
    movzx eax, BYTE [r15 + 16] ; eax = current_node->type
    cmp eax, r12d              ; comparamos types
    jne .next_node             ; si no coincide, siguiente
    
    mov rdi, [r15 + 24]        ; rdi = current_node->hash
    test rdi, rdi
    jz .next_node              ; si es NULL, siguiente nodo

    call strlen                ; rax = strlen(current_node->hash)
    add r14, rax               ; r14 += longitud del hash
    
.next_node:
    mov r15, [r15]             ; r15 = current_node->next
    jmp .length_loop           ; repetimos el bucle
    
.alloc_memory:
    ; calculamos longitud total (hash dado + todos los hashes de nodos + nul-terminator)
    mov rdi, r13               ; rdi = hash
    call strlen                ; rax = strlen(hash)
    add r14, rax               ; r14 += strlen(hash)
    inc r14                    ; r14 += 1 (para el nul-terminator)
    
    mov rdi, r14               ; rdi = longitud total
    call malloc                ; rax = malloc(longitud total)
    test rax, rax              
    jz .error               
    
    mov [rbp - 8], rax         ; guardamos new_hash como variable local
    
    mov rdi, rax               ; rdi = new_hash
    mov rsi, r13               ; rsi = hash
    call strcpy                ; strcpy(new_hash, hash)
    
    ; iteramos sobre la lista para contcatenar los hashes
    mov r15, [rbx]             ; r15 = current_node = list->first
    
.concat_loop:
    test r15, r15              
    jz .done                  
    
    movzx eax, BYTE [r15 + 16] ; eax = current_node->type
    cmp eax, r12d              
    jne .next_concat           ; si no coincide, siguiente nodo
    
    mov rsi, [r15 + 24]        ; rsi = current_node->hash
    test rsi, rsi
    jz .next_concat            ; si es NULL, siguiente nodo
    
    ; Concatenar el hash
    mov rdi, [rbp - 8]         ; rdi = new_hash
    call strcat                ; strcat(new_hash, current_node->hash)
    
.next_concat:
    mov r15, [r15]             ; r15 = current_node->next
    jmp .concat_loop           ; repetimos el bucle
    
.done:
    mov rax, [rbp - 8]         ; rax = new_hash (valor de retorno)
    jmp .cleanup
    
.error:
    mov rax, 0                 ; rax = NULL (valor de retorno en caso de error)
    
.cleanup:
    add rsp, 16                ; liberamos espacio de varibales locales
    pop r15                    ; restauramos registros called-saved
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp              
    pop rbp                  
    ret                        

