/*	-------- JACKSON DAWKINS --------
*	jacksodExam2.c (Simple file transfer client/server)
*	Last-Modified: 4/7/2015
*	For Dr. Remy, CPSC 3600
*/

#include <stdio.h>
#include <sys/socket.h> //for socket
#include <arpa/inet.h> 	//for sockaddr_in
#include <netdb.h> 		//for gethostbyname
#include <stdlib.h> 	//for atoi and exit
#include <string.h>     // for memset
#include <unistd.h>     //for close
#include <stdbool.h>	//for startswith()
#include <fcntl.h>		//for stat
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>		//for printing date
#include <signal.h>

#define MAXPENDING 5    //max number of clients. use this? 
#define SVRRCVBUFSIZE 10000   // Size of receiver's receive buffer
#define MAXBUF 100000000
#define DEBUG 0

void DieWithError(char *errorMessage);  // Error handling function
bool clientSend(char *serverName,int serverPort, char *fileName);
bool serverRecv(int serverPort, char *fileName);
char *nextFileName(char *fileName);
void userCNTCCode();

//------------------------ GLOBALS ------------------------
int transfers;
char *globalError;

/*------------------------ INPUT PARAMETERS ------------------------
*
* 	CLIENT:		./jacksodExam2 <0> <SERVER NAME> <SERVER PORT> <FILENAME TO XFER>
*	** CLIENT IS SENDER
*
* 	SERVER: 	./jacksodExam2 <1> <SERVER PORT> <FILENAME TO CREATE>
*	** SERVER IS RECEIVER
*/

int main(int argc, char *argv[])
{
	transfers = 0;
	globalError = malloc(1000);
	signal(SIGINT, userCNTCCode); //handler for Ctrl-C signal

	//check structure of input
	if(argc > 5 || argc < 4){
		fprintf(stderr, "Client Usage: %s <0> <svr name> <svr port> <file to xfr>\n", argv[0]);
		fprintf(stderr, "Server Usage: %s <1> <svr port> <file to create>\n", argv[0]);
		exit(0); 
	}

	char *serverName = NULL;
	char *fileName = NULL;
	int serverPort = -1;


	//check client/server
	if(strcmp(argv[1],"0") == 0){ //CLIENT -- SENDING
		//parse client input
		serverName = argv[2];
		serverPort = atoi(argv[3]);
		fileName = argv[4];
		if(clientSend(serverName,serverPort,fileName)){//successful send
			printf("Success! Sent: %s\n",fileName);
		} else {
			printf("Failed to send: %s\n",fileName);
			printf("Error: %s",globalError);
		}
	} else if (strcmp(argv[1],"1") == 0){ //SERVER -- RECEIVING
		//parse server input
		serverPort = atoi(argv[2]);
		fileName = argv[3];
		bool status = false;
		while(1){
			status = serverRecv(serverPort,fileName);
			if(status) transfers++; //success
			else printf("Error: %s\n",globalError);
		}
		//serverRecv(serverPort,fileName);
	} else {
		fprintf(stderr, "Client Usage: %s <0> <svr name> <svr port> <file to xfr>\n", argv[0]);
		fprintf(stderr, "Server Usage: %s <1> <svr port> <file to create>\n", argv[0]);
		exit(0); 	
	}

return 0;
}

//sending function used by client. Main calls this once.
bool clientSend(char *serverName,int servPort, char *fileName){
    //------------------------ TCP VARS ------------------------
    int sock;                           // Socket ID 

    struct sockaddr_in servAddr;        // HTTP server address 
    char *servIP = malloc(sizeof(char)*100);	// HTTP Server IP address (dotted quad) 
    
    struct hostent *thehost;            // gethostbyname() results IN BINARY 
    struct hostent *host;				// for name -> IP
    struct in_addr **listOfDNSResults;	// for name -> IP results

    //char sendMsg[MAXBUF];               // String to send to server (FILE TO SEND)
    unsigned int sendMsgLen;            // Length of string to send 

    //char recvBuffer[CLTRCVBUFSIZE];     // Buffer for data to recv 

	//------------------------ RESOLVE HOSTNAME ------------------------
    if ((host = gethostbyname(serverName)) == NULL) {
		if (DEBUG) printf("gethostbyname() failed\n"); //DieWithError("gethostbyname");
		else strcpy(globalError,"gethostbyname() failed\n");
		return false;
    }
    
    listOfDNSResults = (struct in_addr **) host->h_addr_list;

    if(listOfDNSResults[0] != NULL)
        strcpy(servIP, inet_ntoa(*listOfDNSResults[0])); //set servIP here
    else {
    	if (DEBUG) printf("gethostbyname failed\n"); //DieWithError("gethostbyname");
		else strcpy(globalError,"gethostbyname() failed\n");
    	return false;
    }
    	
    if(DEBUG) printf("servName -> IP: %s\n",servIP);

	//------------------------ SET UP TCP ------------------------
    // create TCP socket - SOCK_STREAM: stream paradigm, IPPROTO_TCP: tcp
    if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
    	if (DEBUG) printf("socket() failed\n"); //DieWithError("socket() failed");
		else strcpy(globalError,"socket() failed\n");
        return false;
    }

    // set up server address structure 
    memset(&servAddr, 0, sizeof(servAddr));         // Zero out structure 
    servAddr.sin_family      = AF_INET;             // Internet address family 
    servAddr.sin_addr.s_addr = inet_addr(servIP);   // Server IP address 
    servAddr.sin_port        = htons(servPort);     // Server port 

   // If user gave a dotted decimal address resolve to binary
    if (servAddr.sin_addr.s_addr == -1) {
        thehost = gethostbyname(servIP);
            servAddr.sin_addr.s_addr = *((unsigned long *) thehost->h_addr_list[0]);
    }

    // Establish the connection to the HTTP server 
    if (connect(sock, (struct sockaddr *) &servAddr, sizeof(servAddr)) < 0){
    	if (DEBUG) printf("connect() failed\n");
		else strcpy(globalError,"connect() failed\n");
        //DieWithError("connect() failed");
    	return false;
    }
        
    //------------------------ FILE OPS ------------------------
    //try opening the file to send
    int fd = open(fileName, O_RDWR);
	if(fd == -1){
 		if (DEBUG) printf("file not opened. Breaking\n");
		else strcpy(globalError,"file unable to open. failed\n");
 		return false; 
 	}

 	//open this way to read easily
 	FILE *fp = NULL;
 	fp = fopen(fileName,"r");
 	if(fp == NULL){ //error opening file
 		if (DEBUG) printf("file not opened(2). Breaking\n");
		else strcpy(globalError,"file unable to open. failed\n");
 		return false;
 	}

	//find file info	 	
 	struct stat fileStat;
	fstat(fd, &fileStat);
	int fileSize = fileStat.st_size;

    sendMsgLen = fileSize;   	// Determine input length 
    //char sendBuffer[fileSize]; 	//buffer to fill with file to send.
	char *sendBuffer = malloc(fileSize);
    fread(sendBuffer,fileSize,1,fp); //fill
    if(DEBUG) printf("%s\n",sendBuffer);

    //------------------------ SEND FILE ------------------------
	if (send(sock, sendBuffer, sendMsgLen, 0) != sendMsgLen){
		if (DEBUG) printf("send() failed\n"); //DieWithError("send() failed");
		else strcpy(globalError,"send() failed\n");
		return false;
	}
        
    //------------------------ CLEANUP ------------------------
    close(sock);    // Close client socket
	return true;

}//clientSend


//receiving function used by server. Main calls this repeatedly.
bool serverRecv(int servPort, char *fileName){
	//------------------------ set up TCP ------------------------
    int servSock;               	// Socket ID for server (RECEIVER)
    int clntSock;              		// Socket ID for client (SENDER)
    struct sockaddr_in servAddr; 	// Local address
    struct sockaddr_in clntAddr; 	// Client address
    unsigned int clntLen;        	// Length of client address data structure

    // Create socket for incoming connections
    if ((servSock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
    	if (DEBUG) printf("socket() failed\n");
		else strcpy(globalError,"socket() failed\n");
        return false;
        //DieWithError("socket() failed");
    }
        
    // Construct local address structure
    memset(&servAddr, 0, sizeof(servAddr));   // Zero out structure
    servAddr.sin_family = AF_INET;                // Internet address family
    servAddr.sin_addr.s_addr = htonl(INADDR_ANY); // Any incoming interface
    servAddr.sin_port = htons(servPort);      // Local port

    // Bind to the local address
    if (bind(servSock, (struct sockaddr *) &servAddr, sizeof(servAddr)) < 0){
		if (DEBUG) printf("bind() failed\n");
		else strcpy(globalError,"bind() failed\n");
		return false;
    }

    // Mark the socket so it will listen for incoming connections
    if (listen(servSock, MAXPENDING) < 0){
    	if (DEBUG) printf("listen() failed\n");	
		else strcpy(globalError,"listen() failed\n");
    	return false;
    }

	while(1){

		clntLen = sizeof(clntAddr); // Set the size of the in-out parameter
	
		// Wait for a client to connect
		if ((clntSock = accept(servSock, (struct sockaddr *) &clntAddr, &clntLen)) < 0) {
			if (DEBUG) printf("accept() failed\n");
			else strcpy(globalError,"accept() failed\n");
			return false;
		}

		//------------------------ FILE OPS ------------------------
	   	//open a file write location if filname was set in input parsing...
	   	
		//get the next valid name of the file.
		char *newName = malloc(1000);
			strcpy(newName,fileName);
	   	newName = nextFileName(newName);

	   	FILE *fp = NULL;
		if(newName != NULL) fp = fopen(newName, "w");
		if(fp == NULL){
			if(DEBUG) printf("file: %s open failed\n",newName);
			else strcpy(globalError,"file failed to open\n");
			return false;
		}

		//------------------------ RECEIVE FROM CLIENT ------------------------
		// servSock is connected to a client!
		char recvBuffer[SVRRCVBUFSIZE]; //request incoming
		//int recvMsgSize;
		int bytesRcvd, totalBytesRcvd;
			bytesRcvd = 0;
			totalBytesRcvd = 0;

		while (1) { //begin receiving file.
		    /* Receive up to the buffer size (minus 1 to leave space for
		       a null terminator) bytes from the sender */
		    if ((bytesRcvd = recv(clntSock, recvBuffer, SVRRCVBUFSIZE - 1, 0)) <= 0){
		    	if(DEBUG) printf("bytesRcvd: %d\n",bytesRcvd);
		    	if(DEBUG) printf("----- done receiving -----\n");
				transfers++;
		        break; //done receiving
		    }
		    
		    totalBytesRcvd += bytesRcvd;   // Keep tally of total bytes 
		    recvBuffer[bytesRcvd] = '\0';  // Terminate the string! 

		    if(DEBUG) printf("%s\n",recvBuffer);
		    //if(fp != NULL) fprintf(fp,"%s",recvBuffer); //print to file if open
			if(fp != NULL) fwrite(&recvBuffer,bytesRcvd,1,fp); //print to file if open
		    else return false;
		}//while receiving 
	}//while 1
    //------------------------ CLEANUP ------------------------
    close(servSock);
	return true;

} //serverRecv

//------------------------ OTHER FUNCTIONS ------------------------

//handles user pressing ctrl-c by printout output and exiting.
void userCNTCCode() {
    printf("\nTerminated by CTRL-C.\nTransfers: %d\n",transfers);
    exit(0);
}

void DieWithError(char *errorMessage) {
    perror(errorMessage);
    exit(1);
}

//checks if a file exists by trying to open it.
bool fileExists(char *fileName){
   	FILE *fp = NULL;
   	fp = fopen(fileName,"r");
   	if(fp != NULL){
   		fclose(fp);
   		return true;
   	} else return false;
}

//uses fileExists to find the next incremented filename available
char *nextFileName(char *fileName){

	if (!fileExists(fileName)) return fileName;

	//file exists. Create new name and test.
	int num = 0;
	char *newName = malloc(1000);

	char *fileBase = malloc(1000);
	char *fileExt = malloc(10);
	char *token; //process request piece-by piece

   	// FIRST TOKEN. should be file (no ext)
   	token = strtok(fileName,".");
	if (token!=NULL) strcpy(fileBase,token); //set base

	token = strtok(NULL,".");
	if(token!=NULL) strcpy(fileExt,token); //set ext

	sprintf(newName,"%s.%s",fileBase,fileExt);

	while(fileExists(newName)){
		sprintf(newName, "%s%d.%s",fileBase,num,fileExt);
		num++;
	}

	return newName;
}
