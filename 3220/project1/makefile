CC=gcc
CFLAGS=-Wall -g

all: memory_shim leakcount

memory_shim: memory_shim.c
	$(CC) $(CFLAGS) -fPIC -shared -o memory_shim.so memory_shim.c -ldl

leakcount: leakcount.c
	$(CC) $(CFLAGS) -o leakcount leakcount.c

clean:
	rm memory_shim.so leakcount