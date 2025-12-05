%include "io64.inc"

section .rodata
zero: dd 0.0
n: dd 3
v1: dd 0.0, 3.0, 4.0, 0.0
v2: dd 1.0, 2.0, 8.0, 0.0

section .bss
res: resd 1

section .text
global main
main:
    mov rbp, rsp

    mov eax, [n]
    mov edx, 0
    
    MOVSS xmm0, [zero]; v1
    MOVSS xmm1, [zero]; v2
    MOVSS xmm2, [zero]; temp
    MOVSS xmm3, [zero]; temp
    MOVSS xmm4, [zero]; ||v1||
    MOVSS xmm5, [zero]; ||v2||
    MOVSS xmm6, [zero]; temp
    MOVSS xmm7, [zero]; temp
    
    movups xmm0, [v1]
    movups xmm1, [v2]
    
    movups xmm2, xmm0; v1
    mulps xmm2, xmm2
    
    haddps xmm2, xmm2
    haddps xmm2, xmm2 
    extractps [res], xmm2, 0; extract [0]
    movss xmm4, [res]
    sqrtss xmm4, xmm4
    
    movups xmm3, xmm1; v2
    mulps xmm3, xmm3
    
    haddps xmm3, xmm3
    haddps xmm3, xmm3
    extractps [res], xmm3, 0
    movss xmm5, [res]
    sqrtss xmm5,xmm5
    
    movups xmm6, xmm0
    mulps xmm6, xmm1; v1 * v2
    haddps xmm6, xmm6
    haddps xmm6, xmm6
    extractps [res], xmm6, 0
    movss xmm7,[res]
    
    divss xmm7, xmm5; / ||v2||
    
    divss xmm7, xmm4
    MOVSS [res], xmm7
    PRINT_HEX 4, [res]
    
    ret