;;; template.asm
;;; A template for writing x86/64
;;;
;;; Programmers: Dvir Margalit and Elior Hadad, 2026

section .data
fmt_ld:
    db "%Lf", 0
fmt_result:
	db `log_{%.0Lf}(%.0Lf) = %.18Lf\n\0`
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
	sub rsp, 32

	.log_1:					; a > b
		fld tword [rsi]		; load b
		fld tword [rdi]		; load a
		fcomip st0, st1
		fstp st0
		jbe .log_2			; if a <= b, jump to log_2
		xchg rdi, rsi		; swap a and b
		call log
		fld1
		fdivrp st1 			; st0 = 1 / log_b(a)
		jmp .log_done
		
	.log_2:					; b/a < 1 + /epsilon
		fld tword [rsi]		; load b
		fld tword [rdi]		; load a
		fdivp st1			; st0 = b/a
		fld1
		fld tword [rdx]		; load epsilon
		fadd st0, st1
		fstp st1
		fcomip st0, st1	    ; st0 = b/a
		jbe .log_3			; if b/a <= 1 + epsilon, jump to log_3
		fstp st0
		fld1
		jmp .log_done

	.log_3:					; else
		fstp tword [rbp-16]	; store b = b/a in memory
		lea rsi, [rbp-16]	; load address of b/a
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
		push r12
		sub rsp, 8 
		sub rsp, 64 		; allocate space for local variables

	.input_proccess:
		cmp rdi, 4					; check_size_argv
		jne .usage
		mov r12, rsi		; parse base
		
		lea rsi, [rel fmt_ld]
		mov rdi, [r12 + 8]	; argv[1]
		lea rdx, [rel a]
		xor rax, rax
		call sscanf
		cmp rax, 1
		jne .usage
		
		lea rsi, [rel fmt_ld]
		mov rdi, [r12 + 16]	; argv[2]
		lea rdx, [rel b]
		xor rax, rax
		call sscanf
		cmp rax, 1
		jne .usage

		lea rsi, [rel fmt_ld]
		mov rdi, [r12 + 24]	; argv[3]
		lea rdx, [rel epsilon]
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
		
		fld tword [a]
		fstp tword [rsp]

		fld tword [b]
		fstp tword [rsp + 16]

		fld tword [result]
		fstp tword [rsp + 32]

		jmp .res

	.usage:
		lea rsi, [rel fmt_usage]
		mov rdi, qword [stderr]
		mov rbx, 1
		jmp .print_and_exit
	.res:
		lea rsi, [rel fmt_result]
		mov rdi, qword [stdout]
		xor rbx, rbx
	.print_and_exit:
		xor rax, rax
		call fprintf
		mov rdi, rbx

		;end of activation frame
		add rsp, 8
    	pop r12
		mov rsp, rbp
		pop rbp
		call exit
		
section .note.GNU-stack noalloc noexec
