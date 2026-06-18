# Makefile for log

all: log

log: log.asm
	nasm -g -f elf64 -l log.lst log.asm
	gcc -g -m64 -no-pie -o log log.o

clean:
	rm log.o
