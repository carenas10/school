all: simhttp.o simget.o

simhttp.o: simhttp.c
	gcc -Wall simhttp.c -o simhttp

simget.o: simget.c
	gcc -Wall simget.c -o simget

clean:
	rm -f *.o
	rm -f simget simhttp
	find . -type f -name '*~' -delete

