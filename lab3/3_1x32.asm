extern malloc
extern free
extern printf
extern scanf

section .text
global main

fmt_n db "%d", 0
fmt_not_basis db "not basis", 10, 0
fmt_basis db "basis", 10, 0

main:
push ebp
mov ebp, esp
sub esp, 48  ; Увеличили стек для дополнительных переменных (ebp-28, ebp-32, ebp-36, ebp-40)

lea eax, [ebp-4]
push eax
push fmt_n
call scanf
add esp, 8

mov eax, [ebp-4]
cmp eax, 0
jle .end_program

mov ecx, eax
imul ecx, eax
imul ecx, 4
push ecx
call malloc
add esp, 4
mov esi, eax

test esi, esi
jz .end_program

; Инициализация детерминанта = 1
mov dword [ebp-12], 1
mov dword [ebp-28], 0  ; swap_sign = 0 (чётное число обменов)

; Ввод матрицы (цикл1 и цикл2 без изменений)
mov dword [ebp-16], 0
.cycle1_start:
mov eax, [ebp-16]
cmp eax, [ebp-4]
jge .cycle1_end

mov dword [ebp-20], 0
.cycle2_start:
mov eax, [ebp-20]
cmp eax, [ebp-4]
jge .cycle2_end

mov eax, [ebp-16]
imul eax, [ebp-4]
add eax, [ebp-20]
shl eax, 2

lea ebx, [esi + eax]

push ebx
push fmt_n
call scanf
add esp, 8

inc dword [ebp-20]
jmp .cycle2_start
.cycle2_end:

inc dword [ebp-16]
jmp .cycle1_start
.cycle1_end:

; Прямой ход Гаусса с обменом строк
mov dword [ebp-24], 0  ; k
.cycle3_start:
mov eax, [ebp-24]
mov ebx, [ebp-4]
dec ebx
cmp eax, ebx
jge .cycle3_end

; Проверка pivot a[k][k]
mov eax, [ebp-24]
imul eax, [ebp-4]
add eax, [ebp-24]
shl eax, 2
lea ebx, [esi + eax]
mov ecx, [ebx]
cmp ecx, 0
jne .pivot_nonzero

; Поиск строки для обмена (i от k+1 до n-1)
mov eax, [ebp-24]
inc eax
mov [ebp-16], eax  ; i = k+1
.search_row_start:
mov eax, [ebp-16]
cmp eax, [ebp-4]
jge .no_swap  ; Нет ненулевого элемента, матрица вырожденная

mov eax, [ebp-16]
imul eax, [ebp-4]
add eax, [ebp-24]  ; a[i][k]
shl eax, 2
lea ebx, [esi + eax]
mov edx, [ebx]
test edx, edx
jnz .found_row

inc dword [ebp-16]
jmp .search_row_start

.found_row:
; Обмен строк k и i
mov eax, [ebp-24]
mov [ebp-32], eax  ; row1 = k
mov eax, [ebp-16]
mov [ebp-36], eax  ; row2 = i

mov dword [ebp-40], 0  ; j = 0
.swap_loop:
mov eax, [ebp-40]
cmp eax, [ebp-4]
jge .swap_done

; Вычислить адреса a[row1][j] и a[row2][j]
mov eax, [ebp-32]
imul eax, [ebp-4]
add eax, [ebp-40]
shl eax, 2
lea ebx, [esi + eax]  ; addr1
mov ecx, [ebx]

mov eax, [ebp-36]
imul eax, [ebp-4]
add eax, [ebp-40]
shl eax, 2
lea edx, [esi + eax]  ; addr2
mov edi, [edx]

; Обмен: a[row1][j] = old a[row2][j], a[row2][j] = old a[row1][j]
mov [ebx], edi
mov [edx], ecx

inc dword [ebp-40]
jmp .swap_loop
.swap_done:

; Изменить знак детерминанта
mov eax, [ebp-12]
neg eax
mov [ebp-12], eax

jmp .after_pivot_check

.pivot_nonzero:
.no_swap:
; Умножить det на текущий pivot
mov eax, [ebp-12]
imul eax, ecx
mov [ebp-12], eax

.after_pivot_check:

; Элиминация для строк i = k+1 to n-1
mov eax, [ebp-24]
inc eax
mov [ebp-16], eax  ; i = k+1
.cycle4_start:
mov eax, [ebp-16]
cmp eax, [ebp-4]
jge .cycle4_end

; a[i][k]
mov eax, [ebp-16]
imul eax, [ebp-4]
add eax, [ebp-24]
shl eax, 2
lea edx, [esi + eax]
mov ebx, [edx]  ; ebx = a[i][k]
test ebx, ebx
jz .skip_elim  ; Если a[i][k]==0, пропустить

; pivot = a[k][k]
mov eax, [ebp-24]
imul eax, [ebp-4]
add eax, [ebp-24]
shl eax, 2
lea edx, [esi + eax]
mov ecx, [edx]  ; ecx = pivot

; factor = -a[i][k] / pivot
mov eax, ebx
neg eax
cdq
idiv ecx
mov [ebp-8], eax  ; factor в ebp-8

; Для j = 0 to n-1: a[i][j] += factor * a[k][j]
mov dword [ebp-20], 0  ; j=0
.cycle5_start:
mov eax, [ebp-20]
cmp eax, [ebp-4]
jge .cycle5_end

; a[i][j]
mov eax, [ebp-16]
imul eax, [ebp-4]
add eax, [ebp-20]
shl eax, 2
lea edx, [esi + eax]

; a[k][j]
mov eax, [ebp-24]
imul eax, [ebp-4]
add eax, [ebp-20]
shl eax, 2
lea ebx, [esi + eax]
mov edi, [ebx]  ; a[k][j]
mov eax, [ebp-8]
imul eax, edi
add [edx], eax

inc dword [ebp-20]
jmp .cycle5_start
.cycle5_end:

.skip_elim:

inc dword [ebp-16]
jmp .cycle4_start
.cycle4_end:

inc dword [ebp-24]
jmp .cycle3_start
.cycle3_end:

; Проверка детерминанта
mov eax, [ebp-12]
test eax, eax
je .basis_true

push fmt_not_basis
call printf
add esp, 4
jmp .cleanup

.basis_true:
push fmt_basis
call printf
add esp, 4

.cleanup:
push esi
call free
add esp, 4

.end_program:
mov esp, ebp
pop ebp
mov eax, 0
ret
