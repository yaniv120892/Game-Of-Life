global printer
extern printf
extern resume
extern WorldWidth
extern WorldLength
extern sizeOfBoard
extern state
extern system_call

print1: DB "1",0
print0: DB "0",0
newLine: DB 10,0

	 
%macro printNumber1 0
	push 1
	push print1
	push STDOUT
	push SYS_WRITE
	call system_call
	add esp,16
%endmacro

%macro printNumber0 0
	push 1
	push print0
	push STDOUT
	push SYS_WRITE
	call system_call
	add esp,16
%endmacro

%macro printNewLine 0
	push 1
	push newLine
	push STDOUT
	push SYS_WRITE
	call system_call
	add esp,16
%endmacro

%macro printNumberdl 0
	pushad
	mov ecx,edx
	mov edx,1   		; Print Byte
	push ecx      		; store on stack
	mov ecx,esp      	; load address
	mov eax,4    		; Output To Console
	mov ebx,1			; File Descriptor - Standardout
	int 0x80  		    ; Call the Kernel
	pop ecx 		    ; clean up stack
	popad
%endmacro
		

SYS_WRITE:      equ   4
STDOUT:         equ   1


section .rodata

new_line: db 10,0



section .text

printer:
	
    xor eax,eax           ; eax = i (Length)
    xor ebx,ebx
    xor ecx,ecx           ; ecx = j (Width)
    xor edx,edx
    xor esi,esi
    
    printLengthLoop:
        cmp eax,dword[WorldLength]
        jge finishedPrintLoop
        
        printWidthLoop:
            cmp ecx,dword[WorldWidth]
            jge jumpLine
            push eax
            push ecx
            mov ebx,dword[WorldWidth]
            mul ebx
            add eax,ecx
            mov dl,byte[state+eax]      ; dl = array [i][j]
            printNumberdl
			
            endInnerLoop:
            pop ecx
            pop eax
            inc ecx
            jmp printWidthLoop
            
            
    jumpLine:
        push eax
        printNewLine
        pop eax
        inc eax
        xor ecx,ecx
        jmp printLengthLoop
        
finishedPrintLoop:
    
	mov ebx,0
    call resume             ; resume scheduler
    jmp printer
