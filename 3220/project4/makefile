CC=gcc

all:  notjustcats.c
	make notjustcats

notjustcats: notjustcats.c
	$(CC) -Wall notjustcats.c -o notjustcats

test: notjustcats
	./notjustcats random.img /test

pkg: notjustcats.c README makefile
	tar cvzf project4.tgz README makefile notjustcats.c

clean:
	rm -rf *.a
	rm -rf *.o
	find . -type f -name '*~' -delete
	rm -rf notjustcats
	rm -rf project4.tgz
	rm -rf test
