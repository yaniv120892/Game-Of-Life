
all: ass3

# Tool invocations
ass3: ass3.o coroutines.o printer.o scheduler.o cell.o
	gcc -m32 -Wall -g ass3.o coroutines.o printer.o scheduler.o cell.o -o ass3

# Depends on the source and header files
ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o

coroutines.o: coroutines.s
	nasm -f elf coroutines.s -o coroutines.o

printer.o: printer.s
	nasm -f elf printer.s -o printer.o

scheduler.o: scheduler.s
	nasm -f elf scheduler.s -o scheduler.o

cell.o: cell.c
	gcc -m32 -Wall -ansi -fno-stack-protector -c cell.c -o cell.o


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3
