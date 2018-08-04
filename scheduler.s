global scheduler
extern resume
extern has_Debug
extern generations 
extern printFrequency
extern WorldLength
extern WorldWidth
extern end_co
extern numberOfCors
extern system_call

%macro startFunc 0
	push ebp
	mov ebp,esp
%endmacro

%macro endFunc 0
	mov esp,ebp
	pop ebp
	ret
%endmacro

%macro printString 2
	push %2
	push %1
	push STDOUT
	push SYS_WRITE
	call system_call
	add esp,16
	
	push 1
	push newLine
	push STDOUT
	push SYS_WRITE
	call system_call
	add esp,16
%endmacro

%macro printDebug 2
	push %2
	push %1
	push STDERR
	push SYS_WRITE
	call system_call
	add esp,16
	
	push 1
	push newLine
	push STDERR
	push SYS_WRITE
	call system_call
	add esp,16
%endmacro

%macro CheckToPrintDebug 2
    cmp byte[has_Debug], 0
    je %%EndCheckToPrintDebug
	printDebug %1, %2
	%%EndCheckToPrintDebug:
%endmacro


section .rodata
        format1:  DB     "%d", 10, 0		
        format_String:  DB     "%s", 10, 0		
        endLine: DB    10,0
        init_co_Msg : DB "Initialize co-routine" , 0
        After_One_Iteration: DB "Finish One Iteration" , 0
        newLine: DB 10 , 0
        Start_Scheduler: DB "Start Scheduler" , 0
        Start_Scheduler_Length equ 16
	SYS_OPEN equ 5
	SYS_READ equ 3
	SYS_WRITE equ 4
	SYS_EXIT equ 1
	READ_ONLY equ 0
	STDERR equ 2
	STDOUT equ 1
	STDIN equ 0
	SCHEDULER equ 0
	PRINTER equ 1
section .text

scheduler:
	xor eax,eax
    mov ecx, [generations] 
    mov edx, [printFrequency]
	
	
main_loop:
        mov ebx, 2
        cmp ecx,0
		je finishScheduler
		
calculateScheduler:
        call resume
		dec edx
        inc ebx
		
		checkToPrint:
		cmp edx,0
		jg checkGen
		
		push ebx
		mov ebx,1
		call resume
		pop ebx
		
		mov edx,[printFrequency]

checkGen:
        cmp ebx,[numberOfCors] ;maybe need to fix
        jne calculateScheduler
		
		
		cmp eax,1
		jne inTheMiddle
        dec ecx
		xor eax,eax
		jmp main_loop
		
		inTheMiddle:
		
		mov eax,1
		jmp main_loop
        

finishScheduler:
		
		mov ebx,1			; call printer for the last time
		call resume
		
        call end_co            ; stop co-routines

      