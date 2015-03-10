CC=gcc
CFLAGS=-Wall -g

all: mythreads.c mythreads.h
	make library

library: mythreads.c mythreads.h
	$(CC) -g -c mythreads.c
	ar -cvr libmythreads.a mythreads.o

test: cooperative_test.c
	make library
	$(CC) $(CFLAGS) -o test cooperative_test.c libmythreads.a
	clear
	./test

ptest: preemptive_test.c
	make library
	$(CC) $(CFLAGS) -o test preemptive_test.c libmythreads.a
	clear
	./test

clean:
	rm -rf *.a
	rm -rf *.o
	find . -type f -name '*~' -delete
	rm -rf test
