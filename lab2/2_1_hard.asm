%include "io64.inc"

section .rodata
    x: dd 1.0
    c1: dd 1.0

section .text
global main

main:
    mov rbp, rsp

    mov rax, 35           ; точность (35 итераций)
;xmm0 - сумма
;xmm1 - икс в степени
;xmm2 - факториал
;xmm3 - дробь
;xmm4 - текущее n для факториала
;eax  - метка выхода, когда ноль
    movss xmm0, [c1]
    movss xmm1, [x]
    movss xmm2, [c1]
    movss xmm4, [c1]
    
cycle:
    dec rax
    jz end
    
    ;x^n / n!
    movss xmm3, xmm1
    divss xmm3, xmm2
    addss xmm0, xmm3

    ; inc степень икс
    mulss xmm1, [x]
        
    ; inc факториал
    addss xmm4, [c1]
    mulss xmm2, xmm4
    
    jmp cycle

end:
    
    xor eax, eax
    ret
