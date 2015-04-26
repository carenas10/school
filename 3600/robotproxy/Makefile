CC=gcc
CFLAGS=-Wall -g
PROGS =	 robotServer robotClient

SERVERSRC = robotServer.c DieWithError.c
SERVEROBJS = $(SERVERSRC:.c=.o)

CLIENTSRC = robotClient.c DieWithError.c
CLIENTOBJS = $(CLIENTSRC:.c=.o)

all: $(PROGS)

robotClient: robotClient.o
	${CC} ${CFLAGS} -o robotClient robotClient.c DieWithError.c

robotServer: $(SERVEROBJS)
	${CC} ${CFLAGS} -o robotServer robotServer.c DieWithError.c

clean:
	find . -type f -name '*~' -delete
	rm -f *.o client server a.out
	rm -f ${PROGS} $(CLEANFILES)
