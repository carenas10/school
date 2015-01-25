all: client.o server.o

client.o: vgClient.c
	gcc -Wall vgClient.c DieWithError.c -o client

server.o: vgServer.c
	gcc -Wall vgServer.c DieWithError.c -o server

clean:
	rm -f *o
	rm -f client
	rm -f server
