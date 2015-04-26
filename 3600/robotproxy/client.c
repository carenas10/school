/*********************************************************
*
* Module Name: UDP Echo client source 
*
* File Name:    UDPEchoClient1.c
*
* Summary:
*  This file contains the echo client code.
*
* Revisions:
*
*********************************************************/
#include "robothdr.h"
#include <signal.h>


void clientCNTCCode();

int main(int argc, char *argv[])
{
    int sock;                        /* Socket descriptor */
    struct sockaddr_in echoServAddr; /* Echo server address */
    struct sockaddr_in fromAddr;     /* Source address of echo */
    struct hostent *thehost;         /* Hostent from gethostbyname() */
    unsigned short echoServPort;     /* Echo server port */
    unsigned int fromSize;           /* In-out of address size for recvfrom() */
    char *servIP;                    /* IP address of server */
    int respStringLen;               /* Length of received response */

		int messagesRcvd = 0;						// how many messages we've received from UDCP server
		int numMessages;								// how many messages we should receive in total
		int numBytes = 0;
		int total = 0;

    signal (SIGINT, clientCNTCCode);

    servIP = argv[1];           				/* First arg: server IP address (dotted quad) */
    echoServPort = atoi(argv[2]);       /* Second arg: string to echo */
		char *robotId = argv[3];
		int length = atoi(argv[4]);
		int shape1 = atoi(argv[5]);
		int shape2 = shape1 - 1;

		float angle = 0;					// the angle to turn
		char command[30];

    /* Create a datagram/UDP socket */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
        printf("socket() failed");

    /* Construct the server address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));    /* Zero out structure */
    echoServAddr.sin_family = AF_INET;                 /* Internet addr family */
    echoServAddr.sin_addr.s_addr = inet_addr(servIP);  /* Server IP address */
    echoServAddr.sin_port   = htons(echoServPort);     /* Server port */

    /* If user gave a dotted decimal address, we need to resolve it  */
    if (echoServAddr.sin_addr.s_addr == -1) {
        thehost = gethostbyname(servIP);
            echoServAddr.sin_addr.s_addr = *((unsigned long *) thehost->h_addr_list[0]);
    }

		char *buffer = malloc(1000);

		// Construct UDCP request
		int reqLen = strlen(robotId) + 1 + sizeof(uint32_t) + 10;
		char *request = (char *) malloc(reqLen);
	
		// copy data into reqStr
		uint32_t nReqID = htonl(24); // reqID i network byte order
		memcpy(request, &nReqID, sizeof(uint32_t));
		strcpy(request + sizeof(uint32_t), robotId);

		angle = (3.14 / shape1) * (shape1 - 2);		// determine angle for first shape
		while (shape1 > 0) {
				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "MOVE %0.2f", (float)length);

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
		
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}

				printf("\n");

				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "STOP");

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}
				
				printf("\n");

				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "TURN %0.2f", angle);

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}

				printf("\n");

				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "STOP");

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}
				
				printf("\n");
				shape1--;
		}

		
		angle = (3.14 / shape2) * (shape2 - 2);		// determine angle for second shape
		while (shape2 > 0) {
				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "MOVE %0.2f", (float)length);

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
		
				sleep(1);
				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}

				printf("\n");

				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "STOP");

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}
				
				printf("\n");

				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "TURN %0.2f", angle);

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}

				printf("\n");

				sprintf(request + sizeof(uint32_t) + strlen(robotId) + 1, "STOP");

				/* Send the string to the server */ 
				if (sendto(sock, (char *)request, 1000, 0, (struct sockaddr *)
				           &echoServAddr, sizeof(echoServAddr)) != 1000)
				  printf("sendto() sent a different number of bytes than expected");
				sleep(1);

				/* Recv a response */
				printf("UDPEchoClient: And now wait for a response... \n");    
				fromSize = sizeof(fromAddr);
			 	numBytes = recvfrom(sock, buffer, 1000, 0, 
				     (struct sockaddr *) &fromAddr, &fromSize);
				total += numBytes;

				// get number of messages from first response
				numMessages = ntohl(((udcpResponse *)buffer)->numMessages);
				messagesRcvd++;
				buffer += sizeof(udcpResponse);
				printf("%s", buffer);		// print out raw data

				// get the rest of the messages
				while (messagesRcvd < numMessages) {
						numBytes = recvfrom(sock, buffer, 1000, 0, 
				     						(struct sockaddr *) &fromAddr, &fromSize);
						total += numBytes;
						buffer += sizeof(udcpResponse);
						printf("%s", buffer);
						messagesRcvd++;
				}
				
				printf("\n");
				shape2--;
		}
    
    close(sock);
    exit(0);
}

void clientCNTCCode() {

  printf("UDPEchoClient:  CNT-C Interrupt,  exiting....\n");
	exit(0);

}
