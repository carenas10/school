all: client.o server.o

client.o: vgClient.c
	gcc -Wall vgClient.c -o client

server.o: vgServer.c
	gcc -Wall vgServer.c -o server

clean:
	rm -f *o
	rm -f client
	rm -f server
