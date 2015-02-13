CC=gcc
CFLAGS=-Wall -g

all: memory_shim leakcount sctracer

memory_shim: memory_shim.c
	$(CC) $(CFLAGS) -fPIC -shared -o memory_shim.so memory_shim.c -ldl

leakcount: leakcount.c
	$(CC) $(CFLAGS) -o leakcount leakcount.c

sctracer: sctracer.c
	$(CC) $(CFLAGS) -o sctracer sctracer.c

clean:
	rm memory_shim.so leakcount sctracer

test:
	$(CC) $(CFLAGS) -o test test.c
