#include "robothdr.h"


void DieWithError(char *errorMessage);  /* External error handling function */

void CNTCCode();
int main(int argc, char *argv[])
{
		/***********************
		 * VARIABLES
		 ***********************/
		int udcpSock;
		int tcpSock;
		struct sockaddr_in udcpServAddr;		// Local address
		struct sockaddr_in robotServAddr;		// Robot address
		struct sockaddr_in udcpClntAddr;		// UDCP client address
		struct hostent *thehost;         		// Hostent from gethostbyname()
		unsigned int cliAddrLen;
		int recvMsgSize;                 		// Size of received message
		
		unsigned short servPort = atoi(argv[1]);			// UDCP port for middleware
		char  *robotHost = argv[2];										// host name of robot to resolve
		char *robotIP = malloc(16);										// holds the IP we resolve to
		char *robotID = argv[3];											// ID of robot
		int imageID = atoi(argv[4]);									// image ID number
		char url[2000];																// the URL for the HTTP request

		int numMessages = 0;													// number of UDP messages to send back to client
		int messageIdx = 0;														// sequence number for sending messages back to client
		int messagesSent = 0;													// indicates number of messages we have sent to the client
		int total = 0;																// keeps a count of how many bytes received and then sent


		signal (SIGINT, CNTCCode);

		udcpRequest *request = malloc(1000);								// holds the REAL request message from UDCP client
		udcpResponse *response = malloc(1000);		// response header to send back to client

		// Construct local address structure
    memset(&udcpServAddr, 0, sizeof(udcpServAddr));   // Zero out structure
    udcpServAddr.sin_family = AF_INET;                // Internet address family
    udcpServAddr.sin_addr.s_addr = htonl(INADDR_ANY); // Any incoming interface
    udcpServAddr.sin_port = htons(servPort);      // Local port

		/***********************
		 * SET UP SOCKETS
		 ***********************/

		// Set up the UDCP(client) socket
    if ((udcpSock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)		// for UDCP
        DieWithError("UDCP socket() failed");

		// Bind the UDCP socket to the local address
    if (bind(udcpSock, (struct sockaddr *) &udcpServAddr, sizeof(udcpServAddr)) < 0)
        DieWithError("bind() failed");

    // Construct the server address structure
    memset(&robotServAddr, 0, sizeof(robotServAddr));    /* Zero out structure */
    robotServAddr.sin_family = AF_INET;                 /* Internet addr family */
    robotServAddr.sin_addr.s_addr = inet_addr(robotHost);  /* Server IP address */

    // If user gave a dotted decimal address, we need to resolve it
    if (robotServAddr.sin_addr.s_addr == -1) {
        if ((thehost = gethostbyname(robotHost)) == NULL)
						DieWithError("Couldn't get IP");
				if (inet_ntop(AF_INET, (void *)thehost->h_addr_list[0], robotIP, 16) == NULL)
						DieWithError("Couldn't resolve host");
        robotServAddr.sin_addr.s_addr = *((unsigned long *) thehost->h_addr_list[0]);
    }

		char *cmd;				// used for parsing client request
		char *data;				// used for parsing client request
		char *velocity;		// used for parsing client request
		char *buffer = malloc(1000);	// used to receive http response
		char *sendBuffer = malloc(1000);	// contains the message we send to the client during each "send"

		// Deal with clients (one at a time)
		for (;;) {

				/***************************************
				 * TIMOTHY'S CODE
				 * -receive UDCP message from client
				 * -send HTTP GET request to robot
				 ***************************************/
				// Set the size of the in-out parameter
        cliAddrLen = sizeof(udcpClntAddr);

        // Block until receive message from a client
        if ((recvMsgSize = recvfrom(udcpSock, request, MSG_SIZE, 0,
            (struct sockaddr *) &udcpClntAddr, &cliAddrLen)) < 0)
            DieWithError("recvfrom() failed");

				// Create a TCP socket
				if ((tcpSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
				    DieWithError("socket() failed");

				// Parse the UDCP command
				char *get = (char *)request;
				get += sizeof(uint32_t);
				//printf("%s\n", get);
				int sizeID = strlen(get);
				get += sizeID + 1;		// add one for the null byte
				cmd = strtok(get, " ");				// Get the command first (GET, MOVE, TURN, STOP)
				//printf("%s\n", cmd);

				if (strcmp(cmd, "GET") == 0) {
						data = strtok(NULL, " ");

						if (strcmp(data, "IMAGE") == 0) {
								robotServAddr.sin_port   = htons(8081);     // set port depending on request
								sprintf(url, "/snapshot?topic=/robot_%d/image?width=600?height=500", imageID);

						} else if (strcmp(data, "GPS") == 0) {
								robotServAddr.sin_port   = htons(8082);     // set port depending on request
								sprintf(url, "/state?id=%s", robotID);

						} else if (strcmp(data, "DGPS") == 0) {
								robotServAddr.sin_port   = htons(8084);     // set port depending on request
								sprintf(url, "/state?id=%s", robotID);

						} else if (strcmp(data, "LASERS") == 0) {
								robotServAddr.sin_port   = htons(8083);     // set port depending on request
								sprintf(url, "/state?id=%s", robotID);

						}
				} else if (strcmp(cmd, "MOVE") == 0) {
						robotServAddr.sin_port   = htons(8082);     // set port depending on request

						velocity = strtok(NULL, " ");
						sprintf(url, "/twist?id=%s&lx=%f", robotID, atof(velocity));

				} else if (strcmp(cmd, "TURN") == 0) {
						robotServAddr.sin_port   = htons(8082);     // set port depending on request

						velocity = strtok(NULL, " ");
						sprintf(url, "/twist?id=%s&az=%f", robotID, atof(velocity));

				} else if (strcmp(cmd, "STOP") == 0) {
						robotServAddr.sin_port   = htons(8082);     // set port depending on request
						sprintf(url, "/twist?id=%s&lx=0", robotID);

				}
			
				//Establish connection to server
				if (connect(tcpSock, (struct sockaddr *) &robotServAddr, sizeof(robotServAddr)) < 0)
						DieWithError("connect() failed");

				// Create HTTP request
				char query[1000];
				sprintf(query, "GET %s HTTP/1.1\r\nUser-Agent: %s\r\nAccept: */*\r\nHost: %s\r\nConnection: close\r\n\r\n", 
								url, "robotProxy", robotIP);

				// Send request
				ssize_t numBytes = send(tcpSock, query, strlen(query), 0);
				if (numBytes < 0)
						DieWithError("send() failed");
				else if (numBytes != strlen(query))
						DieWithError("send() sent unexpected number of bytes");



				/***************************************
				 * JAKE'S CODE
				 * -receive response from robot
				 * -construct UDCP message; send to client
				 ***************************************/
				char *message = malloc(1000);
				while ((numBytes = recv(tcpSock, buffer, 1000, 0)) > 0) {
						total += numBytes;

						//printf("%s", buffer);
						message = realloc(message, total);
						memcpy(message + total - numBytes, buffer, numBytes);

						if (numBytes < 0)
								DieWithError("recv() failed");
						else if (numBytes == 0)
								DieWithError("recv(): connection closed prematurely");

						bzero(buffer, 1000);
				}

				//printf("\n");
				// determine how many messages we need to send to client
				numMessages = total / 1000;
				if (total % 1000 != 0)
						numMessages++;

				// extract the HTTP header from the message
				message = strstr(message, "\r\n\r\n") + 4;

				// send UDCP response back to client
				while (total > 0) {
						response->id = request->id;
						response->numMessages = htonl(numMessages);
						response->seqNumber = htonl(messageIdx);

						// put the raw message data into sendBuffer
						sendBuffer = (char *)response;
						sendBuffer += sizeof(udcpResponse);
						strncpy(sendBuffer, message, 1000 - sizeof(udcpResponse));
						message += (1000 - sizeof(udcpResponse));

						//printf("%s\n", sendBuffer);

						sendBuffer -= sizeof(udcpResponse);

						// last packet, don't send all 1000 bytes
						if (total < 1000) {
								// send back to client
								if ((numBytes = sendto(udcpSock, sendBuffer, total, 0, 
								     (struct sockaddr *) &udcpClntAddr, sizeof(udcpClntAddr))) < 0)
								    DieWithError("sendto() sent a different number of bytes than expected");
								total = 0;
						}

						else {
								// send back to client
								if ((numBytes = sendto(udcpSock, sendBuffer, 1000, 0, 
								     (struct sockaddr *) &udcpClntAddr, sizeof(udcpClntAddr))) < 0)
								    DieWithError("sendto() sent a different number of bytes than expected");
								total -= 1000;
						}
						
						messagesSent++;
						messageIdx++;

				}

				// reset all these variables
				numMessages = 0;
				messagesSent = 0;
				messageIdx = 0;


				// socket has to be closed each iteration because 
				// port can change depending on the request
				close(tcpSock);
		}

}


void CNTCCode() {

  printf("CNT-C Interrupt,  exiting....\n");
	exit(0);

}
