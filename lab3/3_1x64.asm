extern malloc
extern free
extern printf
extern scanf

section .rodata
fmt_read_int db "%d", 0
fmt_print_str db "%s", 0
msg_not_basis db "not basis", 10, 0
msg_basis db "basis", 10, 0

section .text
global main

main:
push rbp
mov rbp, rsp
sub rsp, 96          ; больше места для scale [rbp-36]

; [rbp-4] n
; [rbp-8] tmp_factor  
; [rbp-12] det
; [rbp-16] i
; [rbp-20] j
; [rbp-24] k
; [rbp-32] matrix_ptr
; [rbp-36] scale

; Чтение n
lea rcx, [fmt_read_int]
lea rdx, [rbp-4]
sub rsp, 32
call scanf
add rsp, 32

; Выделение памяти
mov eax, [rbp-4]
imul eax, eax
shl eax, 2
mov rcx, rax
sub rsp, 32
call malloc
add rsp, 32
mov [rbp-32], rax

; read
mov dword [rbp-16], 0
.read_loop_i:
mov eax, [rbp-16]
cmp eax, [rbp-4]
jge .read_loop_i_end

mov dword [rbp-20], 0
.read_loop_j:
mov eax, [rbp-20]
cmp eax, [rbp-4]
jge .read_loop_j_end

; offset = (i*n + j)*4
mov eax, [rbp-16]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-20]
movsxd rax, eax
shl rax, 2
add rax, [rbp-32]

lea rcx, [fmt_read_int]
mov rdx, rax
sub rsp, 32
call scanf
add rsp, 32

inc dword [rbp-20]
jmp .read_loop_j
.read_loop_j_end:
inc dword [rbp-16]
jmp .read_loop_i
.read_loop_i_end:

; Гаусс
mov dword [rbp-12], 1 ; det = 1
mov dword [rbp-36], 1 ; scale = 1
mov dword [rbp-24], 0 ; k = 0

.gauss_k_loop:
mov eax, [rbp-24]
cmp eax, [rbp-4]
jge .gauss_k_end

; pivot = a[k][k]
mov eax, [rbp-24]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-24]
movsxd rcx, eax
shl rcx, 2
add rcx, [rbp-32]
mov eax, [rcx]       ; pivot
test eax, eax
jnz .pivot_ok

; Поиск ненулевого pivot
mov eax, [rbp-24]
inc eax
mov [rbp-16], eax
.find_nonzero:
mov eax, [rbp-16]
cmp eax, [rbp-4]
jge .no_pivot_found

mov eax, [rbp-16]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-24]
movsxd rcx, eax
shl rcx, 2
add rcx, [rbp-32]
cmp dword [rcx], 0
jne .swap_rows

inc dword [rbp-16]
jmp .find_nonzero

.swap_rows:
mov dword [rbp-20], 0
.swap_loop:
mov eax, [rbp-20]
cmp eax, [rbp-4]
jge .swap_done

; a[k][j]
mov eax, [rbp-24]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-20]
movsxd r10, eax
shl r10, 2
add r10, [rbp-32]
mov r11d, [r10]

; a[i][j]
mov eax, [rbp-16]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-20]
movsxd r8, eax
shl r8, 2
add r8, [rbp-32]
mov r9d, [r8]

; обмен
mov [r10], r9d
mov [r8], r11d

inc dword [rbp-20]
jmp .swap_loop
.swap_done:
neg dword [rbp-12]   ; смена знака det
jmp .pivot_ok

.no_pivot_found:
mov dword [rbp-12], 0
jmp .gauss_k_end

.pivot_ok:
; det *= pivot, scale *= pivot
mov ebx, [rbp-12]
imul ebx, eax
mov [rbp-12], ebx

mov edx, [rbp-36]
imul edx, eax
mov [rbp-36], edx

; исключение i > k
mov eax, [rbp-24]
inc eax
mov [rbp-16], eax
.elim_i_loop:
mov eax, [rbp-16]
cmp eax, [rbp-4]
jge .elim_i_end

; factor = a[i][k]
mov eax, [rbp-16]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-24]
movsxd rcx, eax
shl rcx, 2
add rcx, [rbp-32]
mov eax, [rcx]
mov [rbp-8], eax     ; сохранить factor

; обнулить a[i][k]
mov dword [rcx], 0

; j = k+1
mov eax, [rbp-24]
inc eax
mov [rbp-20], eax
.elim_j_loop:
mov eax, [rbp-20]
cmp eax, [rbp-4]
jge .elim_j_end

; a[k][j]
mov eax, [rbp-24]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-20]
movsxd r10, eax
shl r10, 2
add r10, [rbp-32]
mov ebx, [r10]

; a[i][j]
mov eax, [rbp-16]
mov edx, [rbp-4]
imul eax, edx
add eax, [rbp-20]
movsxd r11, eax
shl r11, 2
add r11, [rbp-32]
mov ecx, [r11]

; pivot * a[i][j] - factor * a[k][j]
mov edx, eax         ; pivot в edx
imul ecx, edx        ; pivot * a[i][j]
imul ebx, [rbp-8]    ; factor * a[k][j]
sub ecx, ebx
mov [r11], ecx

inc dword [rbp-20]
jmp .elim_j_loop
.elim_j_end:
inc dword [rbp-16]
jmp .elim_i_loop
.elim_i_end:

inc dword [rbp-24]
jmp .gauss_k_loop
.gauss_k_end:

; det /= scale
mov eax, [rbp-12]
mov ecx, [rbp-36]
cdq
idiv ecx
mov [rbp-12], eax

; out
cmp dword [rbp-12], 0
je .not_basis

lea rcx, [fmt_print_str]
lea rdx, [msg_basis]
sub rsp, 32
call printf
add rsp, 32
jmp .end_program

.not_basis:
lea rcx, [fmt_print_str]
lea rdx, [msg_not_basis]
sub rsp, 32
call printf
add rsp, 32

.end_program:
mov rcx, [rbp-32]
test rcx, rcx
jz .no_free
sub rsp, 32
call free
add rsp, 32
.no_free:

mov rsp, rbp
pop rbp
xor eax, eax
ret
