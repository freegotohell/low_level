global main
extern access1

section .data
c dd 0000fefeh      ;(little-endian): FE FE 00 00, (DEC): 65278
s dw 0101h      ; (little-endian): 01 01 
;s db 1,1,0,0,0,0,0,0

section .text
main:

    mov rcx, [c]
    mov rdx, s

    sub rsp, 40         ; 32 shadow + выравнивание
    call access1
    add rsp, 40

    xor eax, eax
    ret
