CC=gcc
CFLAGS=-Wall -g

all: mythreads.c mythreads.h
	make library

library: mythreads.c mythreads.h
	$(CC) -g -c mythreads.c
	ar -cvq libmythreads.a mythreads.o

clean:
	rm *.a
	rm *.o
	find . -type f -name '*~' -delete