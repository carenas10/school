#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>     /* for memset() */
#include <netinet/in.h> /* for in_addr */
#include <sys/socket.h> /* for socket(), connect(), sendto(), and recvfrom() */
#include <arpa/inet.h>  /* for sockaddr_in and inet_addr() */
#include <netdb.h>      /* for getHostByName() */
#include <stdlib.h>     /* for atoi() and exit() */
#include <unistd.h>     /* for close() */

#define MSG_SIZE 1000

typedef struct {
		uint32_t id;
		char *robotId;
		char *command;
} udcpRequest;

typedef struct {
		uint32_t id;
		uint32_t numMessages;
		uint32_t seqNumber;
} udcpResponse;

void DieWithError(char *errorMessage);  /* External error handling function */
