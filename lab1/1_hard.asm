%include "io64.inc"

section .bss
a: resd 65025

section .text
global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; [rbp-4] = n
    ; [rbp-8] = tmp
    ; [rbp-12] = d
    ; [rbp-16] = i
    ; [rbp-20] = j  
    ; [rbp-24] = k

    GET_DEC 4, [rbp-4]     ; n

    mov dword [rbp-16], 0  ; i
.cycle1_start:
    mov eax, [rbp-16]
    cmp eax, [rbp-4]
    jge .cycle1_end
    
    mov dword [rbp-20], 0  ; j
.cycle2_start:
    mov eax, [rbp-20]
    cmp eax, [rbp-4]       
    jge .cycle2_end
    
    ; a[i][j]
    mov eax, [rbp-16]      
    imul eax, 255
    add eax, [rbp-20]
    shl eax, 2

    GET_DEC 4, [a + rax]
    
    inc dword [rbp-20]     ; j
    jmp .cycle2_start
.cycle2_end:
    inc dword [rbp-16]     ; i
    jmp .cycle1_start
.cycle1_end:

    mov dword [rbp-24], 0  ; k
.cycle3_start:
    mov eax, [rbp-24]
    mov ebx, [rbp-4]
    dec ebx
    cmp eax, ebx
    jge .cycle3_end
    
    mov eax, [rbp-24]
    inc eax
    mov [rbp-16], eax      ; i = k+1
.cycle4_start:
    mov eax, [rbp-16]
    cmp eax, [rbp-4]
    jge .cycle4_end

    mov eax, [rbp-24]
    imul eax, 255
    add eax, [rbp-24]
    shl eax, 2             ; a[k][k]
    
    cmp dword [a + rax], 0
    jne .if1_end
    PRINT_STRING "not basis"
    jmp .end_program
.if1_end:
    ; tmp

    mov eax, [rbp-16]
    imul eax, 255
    add eax, [rbp-24]
    shl eax, 2
    mov ebx, [a + rax]     ; a[i][k]
    
    neg ebx

    mov eax, [rbp-24]      
    imul eax, 255
    add eax, [rbp-24]
    shl eax, 2
    mov ecx, [a + rax]     ; a[k][k]

    mov eax, ebx
    cdq
    idiv ecx               ; eax = tmp
    mov [rbp-8], eax

    mov dword [rbp-20], 0  ; j
.cycle5_start:
    mov eax, [rbp-20]
    cmp eax, [rbp-4]
    jge .cycle5_end

    mov eax, [rbp-24]
    imul eax, 255
    add eax, [rbp-20]
    shl eax, 2
    mov ebx, [a + rax]     ; a[k][j]
    
    mov eax, ebx
    imul eax, [rbp-8]      ; tmp
    mov ebx, eax

    mov eax, [rbp-16]
    imul eax, 255
    add eax, [rbp-20]
    shl eax, 2

    add [a + rax], ebx     ; a[i][j] += ebx
    
    inc dword [rbp-20]     ; j
    jmp .cycle5_start
.cycle5_end:

    inc dword [rbp-16]     ; i
    jmp .cycle4_start
.cycle4_end:

    inc dword [rbp-24]     ; k
    jmp .cycle3_start
.cycle3_end:

    mov dword [rbp-12], 1  ; d
    mov dword [rbp-16], 0  ; i
.cycle6_start:
    mov eax, [rbp-16]
    cmp eax, [rbp-4]
    jge .cycle6_end

    mov eax, [rbp-16]
    imul eax, 255
    add eax, [rbp-16]
    shl eax, 2
    
    mov ebx, [a + rax]     ; a[i][i]

    mov eax, [rbp-12]      ; d
    imul eax, ebx
    mov [rbp-12], eax
    
    inc dword [rbp-16]     ; i
    jmp .cycle6_start
.cycle6_end:
    mov eax, [rbp-12]      ; d
    cmp eax, 0
    jne .basis_true
    PRINT_STRING "not basis"
    jmp .if2_end
.basis_true:
    PRINT_STRING "basis"
.if2_end:

.end_program:
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret
