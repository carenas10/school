all: dnsq.o

dnsq.o: dnsq.c
	gcc -Wall dnsq.c udpTools.c DieWithError.c -o dnsq

clean:
	rm -f *.o
	rm -f dnsq
	find . -type f -name '*~' -delete
