%include "io64.inc"

section .rodata
zero: dd 0
n: dd 3
v1: dd 0, 3, 4
v2: dd 1, 2, 8

section .bss
res: resd 1

section .text
global main

main:
    mov rbp, rsp
    
    mov eax, [n]
    mov edx, 0
    
    MOVSS xmm0, [zero]; temp
    MOVSS xmm1, [zero]; ||v1||^2
    MOVSS xmm2, [zero]; temp
    MOVSS xmm3, [zero]; ||v2||^2
    MOVSS xmm4, [zero]; temp
    MOVSS xmm5, [zero]; scalar v1 v2
    MOVSS xmm6, [zero]; temp
    MOVSS xmm7, [zero]; temp
    
    cycle_start:
    cmp eax, edx; length, counter
    je cycle_end
    ;||v1||^2
    CVTSI2SS xmm0,[v1+edx*4]; int -> float
    
    MULSS xmm0,xmm0
    
    ADDSS xmm1, xmm0
  
    ;||v2||^2
    CVTSI2SS xmm2,[v2+edx*4]
    MULSS xmm2,xmm2
    ADDSS xmm3, xmm2
   
    ;v1 * v2
    CVTSI2SS xmm4,[v1+edx*4]
    CVTSI2SS xmm7,[v2+edx*4]
    MULSS xmm4,xmm7    
    ADDSS xmm5, xmm4
    
    add edx, 1
    jmp cycle_start
    
    cycle_end:
    MOVSS xmm6, xmm5
    MOVSS xmm7, xmm3 
    MULSS xmm7, xmm1
    SQRTSS xmm7,xmm7
    DIVSS xmm6, xmm7; scalar / sqrt(||v1||^2 * ||v2||^2)
    MOVSS [res], xmm6
    PRINT_HEX 4, [res]
    
    ret