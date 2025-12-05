extern access1
global main

section .data
s_struc:
dd 0x58583336 ; 4 байта const
db 0 ; флаг
db 0, 0, 0, 0 ;  выравнивания по 4
d:
dd 0.0 ; float, который будет в [rcx+8]

section .text
main:
mov rbp,rsp
sub rsp,40
lea rcx, s_struc
mov rdx,0
movss xmm2,[d]
call access1
add rsp,40
ret


