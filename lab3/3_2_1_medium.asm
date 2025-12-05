section .data
vals:
    dd -10
    dd 0.0

section .text
extern access3
global main
main:
    mov rbp, rsp
    sub rsp, 40
    
    mov ecx,  1; a1
    mov rdx, vals
    mov r8d, 0 ; a3
    
    call access3
    
    add rsp, 40

    xor rax, rax
    ret