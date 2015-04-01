CC=gcc

all:  allocator2.c
	make library

library: allocator2.c
	$(CC) -O2 -DNDEBUG -Wall -fPIC -shared allocator2.c -o libmyalloc.so

lib2: allocator2.c
	$(CC) -O2 -DNDEBUG -Wall -fPIC -shared allocator2.c -o libmyalloc.so

test: allocator.c test.c
	$(CC) -g -o test test.c allocator2.c

pkg: allocator2.c README makefile
	tar cvzf project3.tgz README makefile allocator2.c

clean:
	rm -rf *.a
	rm -rf *.o
	find . -type f -name '*~' -delete
	rm -rf test
	rm -rf project3.tgz
	rm -rf libmyalloc.so