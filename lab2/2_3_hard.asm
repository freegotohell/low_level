; 2^(tg(x) - b) = a
; x = arctg(b + log_2(a)) + pi*n, n = 0

%include "io64.inc"

section .rodata
a: dd 2.0
b: dd 1.0

section .bss
x: resd 1

section .text
global main
main:
    fld1                   ; st0 = 1
    fld dword [a]
    fyl2x                  ; log2(a)
    fadd dword [b]
    fld1
    fpatan                 ; atan( (log2(a)+b) / 1)
    fstp dword [x]
    PRINT_HEX 4, [x]
    ret