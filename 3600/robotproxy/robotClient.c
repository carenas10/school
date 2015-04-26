#include "robothdr.h"
#include <signal.h>

typedef struct {
	char *servName;
	unsigned short servPort;
	char *robotID;
	int L;
	short N;
} cmdArgs;

void getCmdLn(int argc, char *argv[], cmdArgs *args);
void navPolygon(int L, short N, char *robotID, int sock, struct sockaddr_in servAddr);
char *genMoveReq(int L, char *robotID, uint32_t reqID, int *reqLen);
char *genTurnReq(int angle, char *robotID, uint32_t reqID, int *reqLen);
char *genStopReq(char *robotID, uint32_t reqID, int *reqLen);
void genGetReq(char *robotID, uint32_t reqID, int *reqLen, char **req1, char **req2,
			char **req3, char ** req4);
void *sendRequest(int sock, struct sockaddr_in servAddr, char *request, int reqLen,
		int reqNum, int *totalBytes);
void *getResponse(int sock, struct sockaddr_in servAddr, int reqNum, int *totalBytes);
void printImage(char *response, FILE *imageOut, int totalBytes);
void timeout();

int main(int argc, char *argv[])
{
		/*********************************
		 * MATTHEW'S CLIENT CODE
		 *********************************/
	signal(SIGALRM, timeout);
	
	
	cmdArgs args;
	getCmdLn(argc, argv, &args);
    
    int sock;						/* Socket descriptor */
    struct sockaddr_in servAddr;	/* Server address */
    struct hostent *theHost;		/* Hostent from gethostbyname() */
    
    /* Create a datagram/UDP socket */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) DieWithError("socket() failed");

    /* Construct the server address structure */
    memset(&servAddr, 0, sizeof(servAddr));  				/* Zero out structure */
    servAddr.sin_family = AF_INET;                 		/* Internet addr family */
    servAddr.sin_addr.s_addr = inet_addr(args.servName);	/* Server IP address */
    servAddr.sin_port   = htons(args.servPort);       	/* Server port */

    /* If user gave a dotted decimal address, we need to resolve it  */
    if (servAddr.sin_addr.s_addr == -1) {
        theHost = gethostbyname(args.servName);
        servAddr.sin_addr.s_addr = *((unsigned long *) theHost->h_addr_list[0]);
    }
    
    navPolygon(args.L, args.N, args.robotID, sock, servAddr);
    navPolygon(args.L, args.N-1, args.robotID, sock, servAddr);   
    close(sock);
    exit(0);
	
	return 0;

}

void getCmdLn(int argc, char *argv[], cmdArgs *args) {

	if (argc != 6) DieWithError("Incorrect number of arguments.");
	
	args->servName = argv[1];
	args->servPort = atoi(argv[2]);
	args->robotID = argv[3];
	args->L = atoi(argv[4]);
	args->N = atoi(argv[5]);
}

void navPolygon(int L, short N, char *robotID, int sock, struct sockaddr_in servAddr) {
	double angle = 3.14 * (N-2) / N;
	uint32_t i;
	char *request, *imageReq, *GPSReq, *DGPSReq, *lasersReq;
	char *response;
	double velocity, moveTime, angVelocity, turnTime;
	int reqLen; // length of request
	int reqNum = 0;
	char fileName[32], imageName[32];
	int fileNum = 0;
	int imageNum = 0;
	int totalBytes;
	
	sprintf(fileName, "output%d.txt", fileNum++);
	FILE *fileOut = fopen(fileName, "w");
	
	sprintf(imageName, "image%d.jpg", imageNum++);
	FILE *imageOut = fopen(imageName, "w");
	
	// Get location data
	genGetReq(robotID, reqNum++, &reqLen, &imageReq, &GPSReq, &DGPSReq, &lasersReq);
	response = sendRequest(sock, servAddr, imageReq, reqLen, reqNum++, &totalBytes);
	printImage(response, imageOut, totalBytes);
	response = sendRequest(sock, servAddr, GPSReq, reqLen, reqNum++, &totalBytes);
	printf("%s\n", response + sizeof(uint32_t) * 3);
	fprintf(fileOut, "%s\n", response + sizeof(uint32_t) * 3);
	response = sendRequest(sock, servAddr, DGPSReq, reqLen, reqNum++, &totalBytes);
	printf("%s\n", response + sizeof(uint32_t) * 3);
	fprintf(fileOut, "%s\n", response + sizeof(uint32_t) * 3);
	response = sendRequest(sock, servAddr, lasersReq, reqLen, reqNum, &totalBytes);
	fprintf(fileOut, "%s\n", response + sizeof(uint32_t) * 3);
	
	fclose(fileOut);
	
	for (i=0; i<N; i++) {
	
		sprintf(fileName, "output%d", fileNum++);
		fileOut = fopen(fileName, "w");
	
		sprintf(imageName, "image%d.jpg", imageNum++);
		FILE *imageOut = fopen(imageName, "w");
	
		printf("i = %d\n", i);
		
		// go forward L units
		request = genMoveReq(L, robotID, reqNum++, &reqLen);
		sendRequest(sock, servAddr, request, reqLen, reqNum, &totalBytes);
		
		genGetReq(robotID, reqNum++, &reqLen, &imageReq, &GPSReq, &DGPSReq, &lasersReq);
		reqNum += 3;
		response = sendRequest(sock, servAddr, imageReq, reqLen, reqNum++, &totalBytes);
		printImage(response, imageOut, totalBytes);
		response = sendRequest(sock, servAddr, GPSReq, reqLen, reqNum++, &totalBytes);
		printf("%s\n", response + sizeof(uint32_t) * 3);
		fprintf(fileOut, "%s\n", response + sizeof(uint32_t) * 3);
		response = sendRequest(sock, servAddr, DGPSReq, reqLen, reqNum++, &totalBytes);
		printf("%s\n", response + sizeof(uint32_t) * 3);
		fprintf(fileOut, "%s\n", response + sizeof(uint32_t) * 3);
		response = sendRequest(sock, servAddr, lasersReq, reqLen, reqNum, &totalBytes);
		fprintf(fileOut, "%s\n", response + sizeof(uint32_t) * 3);
		
		
		// calculate movement time of robot from velocity
		velocity = 0.4;
		moveTime = L / velocity;
		usleep(moveTime * 1000000);
		
		// stop moving
		request = genStopReq(robotID, reqNum++, &reqLen);
		sendRequest(sock, servAddr, request, reqLen, reqNum, &totalBytes);
		
		// rotate angle radians
		request = genTurnReq(angle, robotID, reqNum++, &reqLen);
		sendRequest(sock, servAddr, request, reqLen, reqNum, &totalBytes);
		
		// calculate turning time of robot from angular velocity
		angVelocity = 0.2;
		turnTime = angle / angVelocity;
		usleep(turnTime * 1000000);
		
		// stop turning
		request = genStopReq(robotID, reqNum++, &reqLen);
		sendRequest(sock, servAddr, request, reqLen, reqNum, &totalBytes);
	
		fclose(fileOut);
	}
}

char *genMoveReq(int L, char *robotID, uint32_t reqID, int *reqLen) {
	// length of robotID + '/n' + requestID + space for request string
	*reqLen = strlen(robotID) + 1 + sizeof(uint32_t) + strlen("MOVE 0.4");
	char *reqStr = malloc(*reqLen);
	
	// copy data into reqStr
	uint32_t nReqID = htonl(reqID); // reqID i network byte order
	memcpy(reqStr, &nReqID, sizeof(uint32_t));
	strcpy(reqStr + sizeof(uint32_t), robotID);
	sprintf(reqStr+strlen(robotID)+1+sizeof(uint32_t), "MOVE 0.4");
	
	return reqStr;
}

char *genTurnReq(int angle, char *robotID, uint32_t reqID, int *reqLen) {
	// length of robotID + '/n' + requestID + space for request string
	*reqLen = strlen(robotID) + 1 + sizeof(uint32_t) + strlen("TURN 0.2");
	char *reqStr = (char *) malloc(*reqLen);
	
	// copy data into reqStr
	uint32_t nReqID = htonl(reqID); // reqID i network byte order
	memcpy(reqStr, &nReqID, sizeof(uint32_t));
	strcpy(reqStr + sizeof(uint32_t), robotID);
	sprintf(reqStr+strlen(robotID)+1+sizeof(uint32_t), "TURN 0.2");
	
	return reqStr;
}

char *genStopReq(char *robotID, uint32_t reqID, int *reqLen) {
	// length of robotID + '/n' + requestID + space for request string
	*reqLen = strlen(robotID) + 1 + sizeof(uint32_t) + strlen("STOP");
	char *reqStr = (char *) malloc(*reqLen);
	
	// copy data into reqStr
	uint32_t nReqID = htonl(reqID); // reqID i network byte order
	memcpy(reqStr, &nReqID, sizeof(uint32_t));
	strcpy(reqStr + sizeof(uint32_t), robotID);
	sprintf(reqStr+strlen(robotID)+1+sizeof(uint32_t), "STOP");
	
	return reqStr;
}

void genGetReq(char *robotID, uint32_t reqID, int *reqLen, char **req1, char **req2,
			char **req3, char ** req4) {
	// length of robotID + '/n' + requestID + space for request string
	*reqLen = strlen(robotID) + 1 + sizeof(uint32_t) + strlen("GET LASERS");
	*req1 = (char *) malloc(*reqLen);
	*req2 = (char *) malloc(*reqLen);
	*req3 = (char *) malloc(*reqLen);
	*req4 = (char *) malloc(*reqLen);
	
	// copy data into req1
	uint32_t nReqID = htonl(reqID); // reqID i network byte order
	memcpy(*req1, &nReqID, sizeof(uint32_t));
	strcpy(*req1 + sizeof(uint32_t), robotID);
	sprintf(*req1+strlen(robotID)+1+sizeof(uint32_t), "GET IMAGE");
	
	// copy data into req2
	reqID++;
	nReqID = htonl(reqID); // reqID i network byte order
	memcpy(*req2, &nReqID, sizeof(uint32_t));
	strcpy(*req2 + sizeof(uint32_t), robotID);
	sprintf(*req2+strlen(robotID)+1+sizeof(uint32_t), "GET GPS");
	
	// copy data into req3
	reqID++;
	nReqID = htonl(reqID); // reqID i network byte order
	memcpy(*req3, &nReqID, sizeof(uint32_t));
	strcpy(*req3 + sizeof(uint32_t), robotID);
	sprintf(*req3+strlen(robotID)+1+sizeof(uint32_t), "GET DGPS");
	
	// copy data into req4
	reqID++;
	nReqID = htonl(reqID); // reqID i network byte order
	memcpy(*req4, &nReqID, sizeof(uint32_t));
	strcpy(*req4 + sizeof(uint32_t), robotID);
	sprintf(*req4+strlen(robotID)+1+sizeof(uint32_t), "GET LASERS");
}

void *sendRequest(int sock, struct sockaddr_in servAddr, char *request, int reqLen,
		int reqNum, int *totalBytes) {
    if(sendto(sock, request, reqLen, 0, (struct sockaddr *) &servAddr,
    		sizeof(servAddr)) != reqLen){
        DieWithError("sendto() sent a different number of bytes than expected");
    }
    
    free(request);
    alarm(5);
	return getResponse(sock, servAddr, reqNum, totalBytes);
}

void *getResponse(int sock, struct sockaddr_in servAddr, int reqNum, int *totalBytes) {
	unsigned int servAddrSize = sizeof(servAddr);
	char *message = malloc(1000);
	int messageNum, numMessages;
	uint32_t *ptr;
	int i;
	
	*totalBytes= 0;
	
	/* Receive first message */
	*totalBytes += recvfrom(sock, message, 1000, 0, (struct sockaddr *) &servAddr, &servAddrSize);
	ptr = (uint32_t *) message;
	ptr++;
	numMessages = *ptr;
	numMessages = ntohl(numMessages);
	ptr++;
	messageNum = *ptr;
	messageNum = ntohl(messageNum);
	ptr++;
	
	// boolean array indicating which messages have been received
	char *msgsRecvd = calloc(numMessages, 1);
	msgsRecvd[messageNum] = 1;
	
	char *response = malloc(numMessages * 988);
	memcpy(response+(988*messageNum), ptr, 988);
	
	/* Receive rest of the messages in the response */
	for (i=1; i<numMessages; i++) {
		*totalBytes += recvfrom(sock, message, 1000, 0, (struct sockaddr *) &servAddr, &servAddrSize);
		ptr = (uint32_t *) message;
		ptr++;
		numMessages = *ptr;
		numMessages = ntohl(numMessages);
		ptr++;
		messageNum = *ptr;
		messageNum = ntohl(messageNum);
		ptr++;
		
		*totalBytes -= sizeof(uint32_t) * 3;
		
		/* Check if message received was a duplicate. If so, don't increment i
		 * on this loop. Appropriately set received boolean.
		 */
		if (msgsRecvd[messageNum] == 0) {
			msgsRecvd[messageNum] = 1;
			memcpy(response+(988*messageNum), ptr, 988);
		} else i--;
	}
	
	free(message);
	alarm(0);
	return response;
}

void timeout() {
	DieWithError("Timeout: no response received after 5 seconds.");
}

void printImage(char *response, FILE *imageOut, int totalBytes) {
	response += sizeof(uint32_t) * 3;
	
	fwrite(response, totalBytes, 1, imageOut);
}











