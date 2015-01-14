include Make.defines
PROGS =	 client1 server

OPTIONS = -DUNIX  -DUSE_SIGACTION -DANSI

DEPS = UDPEcho.h
SERVERSRC = UDPEchoServer.c DieWithError.c
SERVEROBJS = $(SERVERSRC:.c=.o)

CLIENTSRC = UDPEchoClient1.c DieWithError.c
CLIENTOBJS = $(CLIENTSRC:.c=.o)

all: $(PROGS)

client1: $(CLIENTOBJS) $(LIBS)
	${CC} ${LINKOPTIONS} $@ $(CLIENTOBJS) $(LIBS) $(LINKFLAGS)

server: $(SERVEROBJS)
	${CC} ${LINKOPTIONS} $@ $(SERVEROBJS) $(LIBS) $(LINKFLAGS)

depend:
	makedepend UDPEchoClient1.c UDPEchoServer.c  $(CFLAGS) $(DEPS)

backup:
	rm -f UDPEcho.tar.gz
	tar -cf UDPEcho.tar *.c *.h readme.txt Makefile Make.defines Makefile.orig
	gzip -f UDPEcho.tar

clean:
		rm -f ${PROGS} $(CLEANFILES)
