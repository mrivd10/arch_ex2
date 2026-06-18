;;; template.asm
;;; A template for writing x86/64
;;;
;;; Programmers: Dvir Margalit and Tal Fein, 2026

section .data
fmt_frac:
	db `%d\n\0`
fmt_usage:
	db `Usage:\n		<program> <base> <number> <epsilon>\n\0`

extern printf, fprintf, stderr, stdout, exit
global main
section .text

parse_frac:
    push rbp
    mov  rbp, rsp

    xor rbx, rbx      	; numerator = 0
    mov rcx, 1      	; denominator = 1
	xor rdx, rdx		; sign = 0
	cmp byte [rdi], '-'	; check for negative sign
	jne .numerator_loop
	inc rdi				; move past sign
	inc rdx				; sign = 1

.numerator_loop:
	movzx rax, byte [rdi]	; load current char
	cmp rax, 0			; check for end of string
	je .check_sign
	cmp rax, '/'		; check for slash
	je .denominator
	cmp rax, '0'		; check for digit
	jl main.usage
	cmp rax, '9'
	jg main.usage
	sub rax, '0'		; convert char to digit
	imul rbx, 10		; numerator *= 10
	add rbx, rax 		; numerator += digit
	inc rdi				; move to next char
	jmp .numerator_loop

.denominator:
    xor rcx, rcx
	inc rdi					; move past slash
	cmp byte [rdi], 0				; check for end of string
	je main.usage

.denominator_loop:
	movzx rax, byte [rdi]	; load current char
	cmp rax, 0			; check for end of string
	je .check_sign
	cmp rax, '0'		; check for digit
	jl main.usage
	cmp rax, '9'
	jg main.usage
	sub rax, '0'		; convert char to digit
	imul rcx, 10		; denominator *= 10
	add rcx, rax 		; denominator += digit
	inc rdi				; move to next char
	jmp .denominator_loop

.check_sign:
    cmp rdx, 0
	je .done_parsing
	imul rbx, -1

.done_parsing:
	mov rsp, rbp
    pop rbp
    ret

main:
	push rbp
	mov rbp, rsp
	;start activation frame
	
	; check_size_argv
    cmp rdi, 4
    jne .usage

.input_proccess:
	mov rdi, [rsi + 8]	; argv[1]
	call parse_frac
	mov r8, rbx
	mov r9, rcx
	
	mov rdi, [rsi + 16]	; argv[2]
	call parse_frac
	mov r10, rbx
	mov r11, rcx

.common_divisor:
    imul r8, r11
    imul r10, r9
    add r8, r10     ; r8 numerator
    imul r9, r11    ; r9 = denominetor
    mov rsi, r8
    mov rdi, r9
    cmp r9, 0
    jnz .gcd

.check_leg:
    cmp r8, 0
    jz .NaN
    jl .neg_inf
    jmp .pos_inf

.gcd:                       ; inspierd by Oren
    .gcd_loop:
		cmp rsi, 0          ; while (b != 0)
		je .gcd_done

		mov rax, rdi        ; rax = a
		cqo
		idiv rsi             ; rax = a / b, rdx = a % b

		mov rdi, rsi        ; a = b
		mov rsi, rdx        ; b = a % b
		jmp .gcd_loop

	.gcd_done:
		mov rax, rdi        ; gcd result in rax
		cmp rax, 0
		jge .reduction
		neg rax


.reduction:
	mov rsi, rax            ; rsi = gcd
    mov rax, r8             ; rax = numerator
	cqo
	idiv rsi 
    mov r8, rax
    mov rax, r9         	; rax = denominator
	cqo
	idiv rsi 
    mov rcx, rax
	mov rdx, r8

.str_builder:
    cmp rcx, 1
    je .int
    jmp .frac

    ;end of activation frame
	mov rsp, rbp
	pop rbp
	ret

.usage:
	mov rsi, fmt_usage
    mov rdi, qword [stderr]
    mov rbx, 1
	jmp .print_and_exit
.frac:
    mov rsi, fmt_frac
	mov rdi, qword [stdout]
    mov rbx, 0
.print_and_exit:
	xor rax, rax
	call fprintf

	mov rdi, rbx
	call exit
	
section .note.GNU-stack noalloc noexec
