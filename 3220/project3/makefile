CC=gcc

all:  allocator.c allocator.h
	make library

library: allocator.c allocator.h
	$(CC) -O2 -DNDEBUG -Wall -fPIC -shared allocator.c -o libmyalloc.so

test: allocator.c allocator.h test.c
	make library
	$(CC) -g -o test test.c

pkg: allocator.c allocator.h README makefile
	tar cvzf project3.tgz README makefile allocator.c allocator.h

clean:
	rm -rf *.a
	rm -rf *.o
	find . -type f -name '*~' -delete
	rm -rf test
	rm -rf project3.tgz
	rm -rf libmyalloc.so