;;; template.asm
;;; A template for writing x86/64
;;;
;;; Programmers: Dvir Margalit and Elior Hadad, 2026

section .data
fmt_ld:
    db "%Lf", 0
fmt_result:
	db `log_{%Lf}(%Lf) = %Lf\n\0`
fmt_usage:
	db `Usage:\n		<program> <base> <number> <epsilon>\n\0`

section .bss
	a:       resb 16
	b:       resb 16
	epsilon: resb 16
	result:  resb 16

extern sscanf, printf, fprintf, stderr, stdout, exit
global main
section .text

log:
	;start activation frame
	push rbp
	mov rbp, rsp

	.log_1:				; a > b
		fld tword [rsi]		; load b
		fld tword [rdi]		; load a
		fcomip st0, st1
		fstp st0
		jbe .log_2			; if a <= b, jump to log_2
		xchg rdi, rsi		; swap a and b
		call log
		fld1
		fdivp st0, st1 		; st0 = 1 / log_b(a)
		jmp .log_done
		
	.log_2:				; b/a < 1 + /epsilon
		fld tword [rsi]		; load b
		fld tword [rdi]		; load a
		fdivrp st0, st1		; st0 = b/a
		fld1
		fld tword [rdx]		; load epsilon
		fadd st0, st1
		fstp st1
		fcomip st0, st1	    ; st0 = b/a
		jbe .log_3			; if b/a <= 1 + epsilon, jump to log_3
		fstp st0
		fld1
		jmp .log_done

	.log_3:				; else
		fstp tword [rsi]	; store b = b/a in memory
		call log			; st0 = log_a(b/a)
		fld1
		fadd st0, st1
		fstp st1

	.log_done:
		mov rsp, rbp
		pop rbp
		ret

main:
		;start activation frame
		push rbp
		mov rbp, rsp
		sub rsp, 48 		; allocate space for local variables

	.input_proccess:
		cmp rdi, 4					; check_size_argv
		jne .usage
		
		mov r12, rsi		; parse base
		mov rsi, fmt_ld
		
		mov rdi, [r12 + 8]	; argv[1]
		xor rax, rax
		call sscanf
		cmp rax, 1
		jne .usage
		
		mov rdi, [r12 + 16]	; argv[2]
		xor rax, rax
		call sscanf
		cmp rax, 1
		jne .usage

		mov rdi, [r12 + 24]	; argv[3]
		xor rax, rax
		call sscanf
		cmp rax, 1
		jne .usage

	.body:
		lea rdi, [rel a]
		lea rsi, [rel b]
		lea rdx, [rel epsilon]
		call log
		fstp tword [result]
		jmp .frac

	.usage:
		lea rsi, [rel fmt_usage]
		mov rdi, qword [stderr]
		mov rbx, 1
		jmp .print_and_exit
	.frac:
		lea rsi, [rel fmt_result]
		mov rdi, qword [stdout]
		mov rbx, 0
	.print_and_exit:
		xor rax, rax
		call fprintf
		mov rdi, rbx

		;end of activation frame
		mov rsp, rbp
		pop rbp

		call exit
		
section .note.GNU-stack noalloc noexec
