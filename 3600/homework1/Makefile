all: valueGuesser.o valueServer.o

valueGuesser.o: vgClient.c
	gcc -Wall vgClient.c DieWithError.c -o valueGuesser

valueServer.o: vgServer.c
	gcc -Wall vgServer.c DieWithError.c -o valueServer

clean:
	rm -f *o
	rm -f valueGuesser
	rm -f valueServer
