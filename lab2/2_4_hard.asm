;th(4 / 2) = (e^2 - e^-2) / (e^2 + e^-2)
%include "io64.inc"

section .rodata
a: dd 4.0
x: dd 2.0  
y: dd 0.5

section .text
global main
main:
    fld dword [a]
    fld dword [x] 
    fdiv
    ;e^(a / x)
    fldl2e             ; log2(e)
    fmul
    fld st0
    frndint
    fsub st1, st0      ; разность в st1
    fxch
    f2xm1              ; 2^дробная - 1
    fld1
    fadd
    fscale
    fstp st1

    fld st0
    fld1
    fdivr              ; 1 / st1
    
    fld st0            ; st2 = e^arg, st1 = e^(-arg), st0 = e^(-arg)
    fld st2            ; st3 = e^arg, st2 = e^(-arg), st1 = e^(-arg), st0 = e^arg
    
    fadd st0, st1
    fxch st3
    fsub st0, st2
    
    fdiv st0, st3
    

    fld dword [y]
    fcomip
    jnb false          ; >=

    PRINT_DEC 4, 1
    jmp end
    
false:
    PRINT_DEC 4, 0
    
end:
    fstp st0
    xor rax, rax
    ret