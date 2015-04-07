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

#define MAXPENDING 5    //max number of clients. use this? 
#define SVRRCVBUFSIZE 10000   // Size of receiver's receive buffer
//#define CLTRCVBUFSIZE 4096   // Size of sender's receive buffer 
#define MAXBUF 100000
#define DEBUG 1

void DieWithError(char *errorMessage);  // Error handling function
bool clientSend(char *serverName,int serverPort, char *fileName);
bool serverRecv(int serverPort, char *fileName);

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
		clientSend(serverName,serverPort,fileName);
	} else if (strcmp(argv[1],"1") == 0){ //SERVER -- RECEIVING
		//parse server input
		serverPort = atoi(argv[2]);
		fileName = argv[3];
		//while(1) serverRecv(serverPort,fileName);
		serverRecv(serverPort,fileName);
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
		return false;
    }
    
    listOfDNSResults = (struct in_addr **) host->h_addr_list;

    if(listOfDNSResults[0] != NULL)
        strcpy(servIP, inet_ntoa(*listOfDNSResults[0])); //set servIP here
    else {
    	if (DEBUG) printf("gethostbyname failed\n"); //DieWithError("gethostbyname");
    	return false;
    }
    	
    if(DEBUG) printf("servName -> IP: %s\n",servIP);

	//------------------------ SET UP TCP ------------------------
    // create TCP socket - SOCK_STREAM: stream paradigm, IPPROTO_TCP: tcp
    if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
    	if (DEBUG) printf("socket() failed\n"); //DieWithError("socket() failed");
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
        //DieWithError("connect() failed");
    	return false;
    }
        
    //------------------------ FILE OPS ------------------------
    //try opening the file to send
    int fd = open(fileName, O_RDWR);
	if(fd == -1){
 		if (DEBUG) printf("file not opened. Breaking\n");
 		return false; 
 	}

 	//open this way to read easily
 	FILE *fp = NULL;
 	fp = fopen(fileName,"r");
 	if(fp == NULL){ //error opening file
 		if (DEBUG) printf("file not opened(2). Breaking\n");
 		return false;
 	}

	//find file info	 	
 	struct stat fileStat;
	fstat(fd, &fileStat);
	int fileSize = fileStat.st_size;

    sendMsgLen = fileSize;   	// Determine input length 
    char sendBuffer[fileSize]; 	//buffer to fill with file to send.
    fread(sendBuffer,fileSize,1,fp); //fill
    if(DEBUG) printf("%s\n",sendBuffer);

    //------------------------ SEND FILE ------------------------
	if (send(sock, sendBuffer, sendMsgLen, 0) != sendMsgLen){
			if (DEBUG) printf("send() failed\n"); //DieWithError("send() failed");
			return false;
	}
        
    //------------------------ CLEANUP ------------------------
    close(sock);    // Close client socket
	return true;

}//clientSend












//receiving function used by server. Main calls this repeatedly.
bool serverRecv(int servPort, char *fileName){
	//------------------------ set up TCP ------------------------
    int servSock;               	// Socket ID for server
    int clntSock;              		// Socket ID for client
    struct sockaddr_in servAddr; 	// Local address
    struct sockaddr_in clntAddr; 	// Client address
    unsigned int clntLen;        	// Length of client address data structure

    // Create socket for incoming connections
    if ((servSock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
    	if (DEBUG) printf("socket() failed\n");
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
		return false;
    }

    // Mark the socket so it will listen for incoming connections
    if (listen(servSock, MAXPENDING) < 0){
    	if (DEBUG) printf("listen() failed\n");
    	return false;
    }

    clntLen = sizeof(clntAddr); // Set the size of the in-out parameter

	// Wait for a client to connect
	if ((clntSock = accept(servSock, (struct sockaddr *) &clntAddr, &clntLen)) < 0) {
	    if (DEBUG) printf("accept() failed\n");
	    return false;
	}

    //------------------------ FILE OPS ------------------------
   	//open a file write location if filname was set in input parsing...
   	FILE *fp = NULL;
   	//char* append = "1";
    if(fileName != NULL) fp = fopen(fileName, "w");
    if(fp == NULL){
    	if(DEBUG) printf("file open failed\n");
    	return false;
    }
    //TODO -- CHECK FOR EXISTING FILE

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
        if ((bytesRcvd = recv(servSock, recvBuffer, SVRRCVBUFSIZE - 1, 0)) <= 0){
        	if(DEBUG) printf("----- done receiving -----\n");
            break; //done receiving
        }
        
        totalBytesRcvd += bytesRcvd;   // Keep tally of total bytes 
        recvBuffer[bytesRcvd] = '\0';  // Terminate the string! 

        if(DEBUG) printf("%s\n",recvBuffer);
        if(fp != NULL) fprintf(fp,"%s",recvBuffer); //print to file if open
        else return false;
    }//while receiving 

    //------------------------ CLEANUP ------------------------
    close(servSock);
	return true;

} //serverRecv

void DieWithError(char *errorMessage) {
    perror(errorMessage);
    exit(1);
}