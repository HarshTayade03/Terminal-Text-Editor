CC = gcc
mem: mem.c
	$(CC) mem.c -o mem -Wall -Wextra -pedantic -std=c99