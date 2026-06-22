# Makefile for disc-log

all: disc-log

disc-log: disc-log.asm
	nasm -g -f elf64 -l disc-log.lst disc-log.asm
	gcc -g -m64 -no-pie -o disc-log disc-log.o

clean:
	rm disc-log.o
