/*
*   File: vg.h
*   Author: Jackson Dawkins
*   Last Modified: 3.3.2015
*
*   Summary: contains function declarations and includes for udpsend.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <string.h>     /* for memset() */
#include <netinet/in.h> /* for in_addr */
#include <sys/socket.h> /* for socket(), connect(), sendto(), and recvfrom() */
#include <arpa/inet.h>  /* for sockaddr_in and inet_addr() */
#include <netdb.h>      /* for getHostByName() */
#include <stdlib.h>     /* for atoi() and exit() */
#include <unistd.h>     /* for close() */
#include <time.h>       /* used by rand */
#include <signal.h>     /* for kill handling */

char* sendMSG(char* server,int port, char message[],int messageLen);

void DieWithError(char *errorMessage);  /* External error handling function */

