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


;;; This is a simplified co-routines implementation:
;;; CORS contains just stack tops, and we always work
;;; with co-routine indexes.
global init_co
global start_co
global resume 
global stacksz
global stacks
global end_co
global curr

extern WorldLength
extern WorldWidth
extern printf
extern sizeOfBoard
extern cors

  
  
stacksz:        equ 16*1024     ; per-co-routine stack size

section .bss

stacks: resb maxcors * stacksz  ; co-routine stacks
curr:   resd 1                  ; current co-routine
origsp: resd 1                  ; original stack top
tmp:    resd 1                  ; temporary value

section .rodata
    format1:  DB     "%d", 10, 0		
    endLine: DB    10,0
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
	maxcors:        equ 100*100 + 2         ; maximum number of co-routines


section .text


init_co:
        push eax               ; save eax (on callers stack)
        push edx
        mov edx,0
        mov eax,stacksz
        imul ebx	       ; eax = co-routines stack offset in stacks
        pop edx
        add eax, stacks + stacksz ; eax = top of (empty) co-routines stack
        mov [cors + ebx*4], eax ; store co-routines stack top
        pop eax                 ; restore eax (from callers stack)

        mov [tmp], esp          ; save callers stack top
        mov esp, [cors + ebx*4] ; esp = co-routines stack top

        push edx                ; save return address to co-routine stack
        pushf                   ; save flags
        pusha                   ; save all registers
        mov [cors + ebx*4], esp ; update co-routines stack top

        mov esp, [tmp]          ; restore callers stack top
        ret                 

start_co:
        pusha                   ; save all registers (restored in "end_co")
        mov [origsp], esp       ; save callers stack top
        mov [curr], ebx         ; store current co-routine index
        jmp resume.cont         ; perform state-restoring part of "resume"

        ;; can be called or jumped to

     

        ;; ebx = co-routine index to switch to
resume:                         ; "call resume" pushed return address
    pushf                   ; save flags to source co-routine stack
    pusha                   ; save all registers
    xchg ebx, [curr]        ; ebx = current co-routine index
    mov [cors + ebx*4], esp ; update current co-routines stack top
    mov ebx, [curr]         ; ebx = destination co-routine index
.cont:
    mov esp, [cors + ebx*4] ; get destination co-routines stack top
    popa                    ; restore all registers
    popf                    ; restore flags
    ret                     ; jump to saved return address
        
end_co:
    mov esp, [origsp]       ; restore stack top of whoever called "start_co"
	popa                    ; restore all registers
	ret                     ; return to caller of "start_co"