CC=gcc
CFLAGS=-Wall -g

all: memory_shim

memory_shim: memory_shim.c
	$(CC) $(CFLAGS) -fPIC -shared -o memory_shim.so memory_shim.c -ldl