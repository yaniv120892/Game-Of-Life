	global WorldWidth
	global WorldLength
	global sizeOfBoard
	global generations
	global numberOfCors
	global printFrequency
	global has_Debug
	global system_call
	global main
	global cors
	global state
	
	extern init_co
	extern start_co
	extern end_co
	extern resume
	extern scheduler
	extern printer
	extern cell
	extern curr

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
	pushad
    cmp byte[has_Debug], 0
    je %%EndCheckToPrintDebug
	printDebug %1, %2
	%%EndCheckToPrintDebug:
	popad
%endmacro

section .rodata
	StartProgram:
        DB "Start running program" , 0
	EndProgram:
        DB "Existing main function, bye bye" , 0
	allocteError:
        DB "Alloctaion failed" , 0
	allocateWorked:
        DB "Alloctaion worked", 0
	succsededMessage:
        DB "somthing worked" , 0
	openedFile:
        DB "Opened file successfully" , 0
	readFile:
        DB "Read file successfully" , 0
	failedToOpenFile:
        DB "Failed to open file" , 0
	parsingBorad:
        DB "Parsing the board" , 0
	enteredParsingLoop:
        DB "Entered parsing loop!" , 0
	formatDecimal: 
		DB "num: %d" , 10, 0
	newLine:
        DB 10 , 0
    Init_Scheduler:
        DB "After init scheduler" , 0
    Init_Printer:
        DB "After init printer" , 0
    After_Init_Cores:
        DB "After init all cores" , 0
    After_Start_Scheduler:
        DB "After start scheduler" , 0
    StartCalc:
        DB "Starting to calculate the cell" , 0
	UpdatingCell:
        DB "Updating the cell" , 0
	UpdatingCellLength equ 17
    StartCalcLength equ 30
    readFileLength equ 23
    openedFileLength equ 25
    enteredParsingLoopLength equ 22
    parsingBoradLength equ 18
    failedToOpenFileLength equ 20
    After_Start_Scheduler_Length equ 22
    After_Init_Cores_Length equ 21
    Init_Printer_Length equ 19
    Init_Scheduler_Length equ 21
	allocateWorkedLength equ 18
	allocteErrorLength equ 18
	succsededMessageLength equ 16
	EndProgramLength equ 32
	StartProgramLength equ 22
	SYS_OPEN equ 5
	SYS_READ equ 3
	SYS_WRITE equ 4
	SYS_EXIT equ 1
	READ_ONLY equ 0
	STDERR equ 2
	STDOUT equ 1
	STDIN equ 0
	SCHEDULERNumber equ 0
	PRINTER equ 1
	maxcors:        equ 100*102 + 2         ; maximum number of co-routines

section .bss
	inputFileName RESB 4 ; the name of the input file
	inputFile  RESB 4	 ; an opening to the input file
	WorldWidth RESB 4	 ; the width of the world
	WorldLength RESB 4	 ; the length of the world
	sizeOfBoard RESB 4	 ; the size of the board
	generations RESB 4	 ; the number of generations
	printFrequency RESB 4	 ; the frequency to print
	wordlength RESB 4		 ; the length of a word
	state   resd maxcors			 ; the array containing cell 1,...,cell last
	cors   resd maxcors            ; simply an array with co-routine stack tops

section .data
	has_Debug DD 0;
	ten DD 10
	numberOfCors DD 0 ;


section .text 

;--------------------------------------------Main--------------------------------------------
main:
	startFunc
	
	CheckToPrintDebug StartProgram,StartProgramLength
	
	mov ecx	,dword [ebp + 4 + 1*4]	; ecx <-- argc
	mov ebx, dword [ebp + 4 + 2*4] ; argv[]
	mov edx, 1		       ; arg index
	cmp ecx, 7
	jne debugIsNotOn

	mov eax ,dword[ebx+edx*4]  ; entering debug if exists
    inc edx			; next arg
    cmp byte[eax+0], '-'
    jne debugIsNotOn
    cmp byte[eax+1] , 'd'
    jne debugIsNotOn 
	mov byte[has_Debug], 1
	
	debugIsNotOn:
	
	mov eax ,dword[ebx+edx*4]  ; entering the name of the file
    inc edx			; next arg
	mov dword[inputFileName],eax
	
	mov eax ,dword[ebx+edx*4]  ; entering the length of the matrix  
    inc edx			; next arg	
	push eax
	call atoi
	add esp,4
	mov dword[WorldLength],eax
	
	mov eax ,dword[ebx+edx*4]  ; entering the width of the matrix
    inc edx			; next arg
	push eax
	call atoi
	add esp,4
	mov dword[WorldWidth],eax
	
	mov eax ,dword[ebx+edx*4]  ; entering the number of the generations
    inc edx			; next arg
	push eax
	call atoi
	add esp,4
	mov dword[generations],eax
	
	mov eax ,dword[ebx+edx*4]  ; entering the frequency to print
    inc edx			; next arg
	push eax
	call atoi
	add esp,4
	mov dword[printFrequency],eax
	
	CheckToPrintDebug StartProgram,StartProgramLength
	
	xor eax,eax
	mov eax,dword[WorldLength]
	mul dword[WorldWidth]
	mov dword[sizeOfBoard],eax
	add eax,2
	mov dword[numberOfCors],eax
	
	
	
	
;------------------------------------------Parse the board------------------------------------------
	CheckToPrintDebug parsingBorad,parsingBoradLength
	
	xor eax, eax
	push 0644
	push READ_ONLY
	push dword[inputFileName]
	push SYS_OPEN
	call system_call
	add esp,16
	
	cmp eax,0
	jnl fileOpened
	printString failedToOpenFile,failedToOpenFileLength
	jmp Exit_Program
	
fileOpened:
	mov [inputFile],eax
	
	push maxcors
	push state
	push dword[inputFile]
	push SYS_READ
	call system_call
	add esp,16

	cmp eax,0
	jnl succeededReadingFile
	printString failedToOpenFile,failedToOpenFileLength
	jmp Exit_Program

succeededReadingFile:	
	CheckToPrintDebug readFile,readFileLength
	
	xor ecx,ecx
	xor esi,esi
	mov ebx,dword[sizeOfBoard]
	add ebx,[WorldLength]
	dec ebx
	
	parsing_file_loop:	
	cmp ecx,ebx
	jg parsing_file_end_loop
	
	xor edx,edx
	mov dl,byte[state+esi]
	
	cmp dl,0xa
	jne notEnter
	inc esi
	jmp parsing_file_loop
	
	notEnter:
	cmp dl,' '
	jne cellIsAlive
	mov byte[state + ecx],'0'
	mov dl, byte[state + ecx]
	jmp end_Check_Status
	
	cellIsAlive:
	mov byte[state + ecx],'1'
	
	end_Check_Status:
	
	inc ecx
	inc esi
	jmp parsing_file_loop
	parsing_file_end_loop:
		
	
;-----------------------------init co-routine scheduler -----------------------------------------------
Init_Special_Cos:
	mov edx, scheduler
	xor ebx,ebx
	call init_co
	
CheckToPrintDebug Init_Scheduler,Init_Scheduler_Length
	
;-----------------------------init co-routine printer -----------------------------------------------
	
	mov edx, printer
	inc ebx
	call init_co
	
CheckToPrintDebug Init_Printer,Init_Printer_Length

;-----------------------------init co-routine cells -----------------------------------------------

Init_All_Cells:
	
	inc ebx
	mov edx,Calculate_Function
	call init_co
	cmp ebx, dword[numberOfCors]
	je Start_scheduler
	jmp Init_All_Cells
		

Calculate_Function:
	push ebx
	xor eax,eax
	xor edx,edx
	sub ebx,2
	mov eax,ebx
	div dword[WorldWidth]
	CheckToPrintDebug StartCalc,StartCalcLength
	push edx
	push eax
	call cell
	add esp,8
	pop ebx
	push ebx
	mov ebx,SCHEDULERNumber
	call resume
	pop ebx
	mov byte[state+ebx-2],al
	CheckToPrintDebug UpdatingCell,UpdatingCellLength
	mov ebx,SCHEDULERNumber
	call resume
	mov ebx,[curr]
	jmp Calculate_Function
	
		
;-----------------------------start co-routine scheduler -----------------------------------------------


Start_scheduler:

CheckToPrintDebug After_Init_Cores,After_Init_Cores_Length
    mov ebx, SCHEDULERNumber 
    call start_co
	
CheckToPrintDebug After_Start_Scheduler,After_Start_Scheduler_Length


	
;-----------------------------end program -----------------------------------------------

Exit_Program:
    CheckToPrintDebug EndProgram, EndProgramLength
	mov     ebx,0
    mov     eax,1
    int     0x80
    nop
	
system_call:
    startFunc
	
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
	
endFunc

atoi:
    startFunc
    push ecx
    push edx
    push ebx
    mov ecx, dword [ebp+8]  ; Get argument (pointer to string)
    xor eax,eax
    xor ebx,ebx
.atoi_loop:
    xor edx,edx
    cmp byte[ecx],0
    jz .atoi_end
    imul dword[ten]
    mov bl,byte[ecx]
    sub bl,'0'
    add eax,ebx
    inc ecx
    jmp .atoi_loop
.atoi_end:
    pop ebx                 ; Restore registers
    pop edx
    pop ecx
	
endFunc