include Make.defines

PROGS =	 client1 server

OPTIONS = -DUNIX  -DUSE_SIGACTION -DANSI


COBJECTS =	DieWithError.o 
CSOURCES =	DieWithError.c 

CPLUSOBJECTS = 

COMMONSOURCES =

CPLUSSOURCES =

all:	${PROGS}


client1:	UDPEchoClient1.o $(CPLUSOBJECTS) $(COBJECTS) $(LIBS) $(COMMONSOURCES) $(SOURCES)
		${CC} ${LINKOPTIONS}  $@ UDPEchoClient1.o $(CPLUSOBJECTS) $(COBJECTS) $(LIBS) $(LINKFLAGS)


server:		UDPEchoServer.o $(CPLUSOBJECTS) $(COBJECTS)
		${CC} ${LINKOPTIONS} $@ UDPEchoServer.o $(CPLUSOBJECTS) $(COBJECTS) $(LIBS) $(LINKFLAGS)


.cc.o:	$(HEADERS)
	$(CPLUS) $(CPLUSFLAGS) $(OPTIONS) $<

.c.o:	$(HEADERS)
	$(CC) $(CFLAGS) $(OPTIONS) $<



backup:
	rm -f UDPEcho.tar.gz
	tar -cf UDPEcho.tar *
	gzip -f UDPEcho.tar

clean:
		rm -f ${PROGS} ${CLEANFILES}

depend:
		makedepend UDPEchoClient1.c UDPEchoServer.c  $(CFLAGS) $(HEADERS) $(SOURCES) $(COMMONSOURCES) $(CSOURCES)
#		mkdep $(CFLAGS) $(HEADERS) $(SOURCES) $(COMMONSOURCES) $(CSOURCES)

# DO NOT DELETE

UDPEchoClient1.o: UDPEcho.h /usr/include/stdio.h /usr/include/iso/stdio_iso.h
UDPEchoClient1.o: /usr/include/sys/feature_tests.h
UDPEchoClient1.o: /usr/include/sys/isa_defs.h /usr/include/sys/va_list.h
UDPEchoClient1.o: /usr/include/stdio_tag.h /usr/include/stdio_impl.h
UDPEchoClient1.o: /usr/include/stdlib.h /usr/include/iso/stdlib_iso.h
UDPEchoClient1.o: /usr/include/errno.h /usr/include/sys/errno.h
UDPEchoClient1.o: /usr/include/sys/types.h /usr/include/sys/machtypes.h
UDPEchoClient1.o: /usr/include/sys/int_types.h /usr/include/sys/select.h
UDPEchoClient1.o: /usr/include/sys/time.h /usr/include/sys/time.h
UDPEchoClient1.o: /usr/include/string.h /usr/include/iso/string_iso.h
UDPEchoClient1.o: /usr/include/netinet/in.h /usr/include/sys/stream.h
UDPEchoClient1.o: /usr/include/sys/vnode.h /usr/include/sys/t_lock.h
UDPEchoClient1.o: /usr/include/sys/machlock.h /usr/include/v7/sys/privregs.h
UDPEchoClient1.o: /usr/include/v7/sys/psr.h /usr/include/sys/fsr.h
UDPEchoClient1.o: /usr/include/sys/param.h /usr/include/sys/unistd.h
UDPEchoClient1.o: /usr/include/sys/mutex.h /usr/include/sys/rwlock.h
UDPEchoClient1.o: /usr/include/sys/semaphore.h /usr/include/sys/condvar.h
UDPEchoClient1.o: /usr/include/sys/rwstlock.h /usr/include/sys/ksynch.h
UDPEchoClient1.o: /usr/include/sys/time_impl.h /usr/include/sys/cred.h
UDPEchoClient1.o: /usr/include/sys/uio.h /usr/include/sys/resource.h
UDPEchoClient1.o: /usr/include/vm/seg_enum.h /usr/include/sys/poll.h
UDPEchoClient1.o: /usr/include/sys/strmdep.h /usr/include/sys/model.h
UDPEchoClient1.o: /usr/include/sys/strft.h /usr/include/sys/byteorder.h
UDPEchoClient1.o: /usr/include/sys/socket.h /usr/include/sys/netconfig.h
UDPEchoClient1.o: /usr/include/sys/un.h /usr/include/net/if_dl.h
UDPEchoClient1.o: /usr/include/arpa/inet.h /usr/include/netdb.h
UDPEchoClient1.o: /usr/include/unistd.h /usr/include/signal.h
UDPEchoClient1.o: /usr/include/iso/signal_iso.h
UDPEchoClient1.o: /usr/include/sys/iso/signal_iso.h /usr/include/sys/signal.h
UDPEchoServer.o: UDPEcho.h /usr/include/stdio.h /usr/include/iso/stdio_iso.h
UDPEchoServer.o: /usr/include/sys/feature_tests.h /usr/include/sys/isa_defs.h
UDPEchoServer.o: /usr/include/sys/va_list.h /usr/include/stdio_tag.h
UDPEchoServer.o: /usr/include/stdio_impl.h /usr/include/stdlib.h
UDPEchoServer.o: /usr/include/iso/stdlib_iso.h /usr/include/errno.h
UDPEchoServer.o: /usr/include/sys/errno.h /usr/include/sys/types.h
UDPEchoServer.o: /usr/include/sys/machtypes.h /usr/include/sys/int_types.h
UDPEchoServer.o: /usr/include/sys/select.h /usr/include/sys/time.h
UDPEchoServer.o: /usr/include/sys/time.h /usr/include/string.h
UDPEchoServer.o: /usr/include/iso/string_iso.h /usr/include/netinet/in.h
UDPEchoServer.o: /usr/include/sys/stream.h /usr/include/sys/vnode.h
UDPEchoServer.o: /usr/include/sys/t_lock.h /usr/include/sys/machlock.h
UDPEchoServer.o: /usr/include/v7/sys/privregs.h /usr/include/v7/sys/psr.h
UDPEchoServer.o: /usr/include/sys/fsr.h /usr/include/sys/param.h
UDPEchoServer.o: /usr/include/sys/unistd.h /usr/include/sys/mutex.h
UDPEchoServer.o: /usr/include/sys/rwlock.h /usr/include/sys/semaphore.h
UDPEchoServer.o: /usr/include/sys/condvar.h /usr/include/sys/rwstlock.h
UDPEchoServer.o: /usr/include/sys/ksynch.h /usr/include/sys/time_impl.h
UDPEchoServer.o: /usr/include/sys/cred.h /usr/include/sys/uio.h
UDPEchoServer.o: /usr/include/sys/resource.h /usr/include/vm/seg_enum.h
UDPEchoServer.o: /usr/include/sys/poll.h /usr/include/sys/strmdep.h
UDPEchoServer.o: /usr/include/sys/model.h /usr/include/sys/strft.h
UDPEchoServer.o: /usr/include/sys/byteorder.h /usr/include/sys/socket.h
UDPEchoServer.o: /usr/include/sys/netconfig.h /usr/include/sys/un.h
UDPEchoServer.o: /usr/include/net/if_dl.h /usr/include/arpa/inet.h
UDPEchoServer.o: /usr/include/netdb.h /usr/include/unistd.h
DieWithError.o: /usr/include/stdio.h /usr/include/iso/stdio_iso.h
DieWithError.o: /usr/include/sys/feature_tests.h /usr/include/sys/isa_defs.h
DieWithError.o: /usr/include/sys/va_list.h /usr/include/stdio_tag.h
DieWithError.o: /usr/include/stdio_impl.h /usr/include/stdlib.h
DieWithError.o: /usr/include/iso/stdlib_iso.h
