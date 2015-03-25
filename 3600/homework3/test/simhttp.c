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
#define RCVBUFSIZE 4096   // Size of receive buffer

#define DEBUG 0

void DieWithError(char *errorMessage);
bool startsWith(const char *str, const char *pre);
bool parseRequest (char *rcvBuffer, char *method, char *requestFile, char *httpVers);
void printOutput(char *method, char *path, int status);
void prepend(char* str, const char* toPrepend);
char* getContentType(char *path);

int main(int argc, char *argv[]){

	unsigned short servPort = 8080; //default port
	char *localDirectory; //user provided

	//------------------------ parse input ------------------------
	//impossible number of input args
	if(argc > 4){
		fprintf(stderr, "Usage: %s [-p port] [directory]\n", argv[0]);
		exit(0);
	}

	if(argc == 3 && strcmp(argv[1],"-p")==0){ //checking for port only
		servPort = atoi(argv[2]);
		if(DEBUG) printf("PORT: %d\n",servPort);
	} else if(argc == 2) { //no port. directory specified
		if(strcmp(argv[1],"-p")==0){ //-p with no port
			fprintf(stderr, "Usage: %s [-p port] [directory]\n", argv[0]);
			exit(0);	
		}
		localDirectory = argv[1];
		if(DEBUG) printf("DIR: %s\n", localDirectory); //do I need to check for a slash?
	} else if (argc == 4 && strcmp(argv[1],"-p") == 0){ //port and directory specified
		servPort = atoi(argv[2]);
		if(DEBUG) printf("PORT: %d\n",servPort);
		localDirectory = argv[3];
		if(DEBUG) printf("DIR: %s\n", localDirectory);
	} else {
		fprintf(stderr, "Usage: %s [-p port] [directory]\n", argv[0]);
		exit(0);
	}

	//------------------------ set up TCP ------------------------
    int servSock;               	// Socket ID for server
    int clntSock;              		// Socket ID for client
    struct sockaddr_in servAddr; 	// Local address
    struct sockaddr_in clntAddr; 	// Client address
    unsigned int clntLen;        	// Length of client address data structure

    // Create socket for incoming connections
    if ((servSock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
        DieWithError("socket() failed");

    // Construct local address structure
    memset(&servAddr, 0, sizeof(servAddr));   // Zero out structure
    servAddr.sin_family = AF_INET;                // Internet address family
    servAddr.sin_addr.s_addr = htonl(INADDR_ANY); // Any incoming interface
    servAddr.sin_port = htons(servPort);      // Local port

    // Bind to the local address
    if (bind(servSock, (struct sockaddr *) &servAddr, sizeof(servAddr)) < 0)
        DieWithError("bind() failed");

    // Mark the socket so it will listen for incoming connections
    if (listen(servSock, MAXPENDING) < 0)
        DieWithError("listen() failed");

    //------------------------ handle clients ------------------------
    
    for (;;) { // Run forever 
        clntLen = sizeof(clntAddr); // Set the size of the in-out parameter

        // Wait for a client to connect
        if ((clntSock = accept(servSock, (struct sockaddr *) &clntAddr, 
                               &clntLen)) < 0)
            DieWithError("accept() failed");

        // clntSock is connected to a client!
        char rcvBuffer[RCVBUFSIZE]; //request incoming
        int recvMsgSize;

        // Receive message from client
        if ((recvMsgSize = recv(clntSock, rcvBuffer, RCVBUFSIZE, 0)) < 0)
            DieWithError("recv() failed");

        //-------- PARSE REQUEST --------
        char *method = malloc(1024);	//method of http request
        char *path = malloc(1024);	//the requested file.
        char *httpVers = malloc(1024);		//used to assure the correct http version supported.

        //parse request and issue 400 error for bad request if needed.
	 	if(!parseRequest(rcvBuffer,method,path,httpVers)){
		 	send(clntSock,"HTTP/1.1 400 Bad Request\n",25,0);
		 	printOutput(method,path,400);
	 		exit(1);	 		
	 	}

	 	if(strcmp(path,"/")==0) strcpy(path,"/index.html"); //if no path, index.html default
	 	path++; //increment file path pointer to remove the preceding slash

	 	FILE *fp = NULL;
	 	fp = fopen(path,"r");
	 	if(fp == NULL){ //error opening file
	 		send(clntSock,"HTTP/1.1 404 Not Found\n",23,0);
	 		printOutput(method,path,404);
	 		exit(1);
	 	}
	 	else printOutput(method,path,200);

		//find file info	 	
	 	struct stat fileStat;
	 	int fd = open(path, O_RDWR);
	 		if(fd == -1){
	 	 		send(clntSock,"HTTP/1.1 404 Not Found\n",23,0);
	 			printOutput(method,path,404);
	 			exit(1);		
	 		}
		fstat(fd, &fileStat);
		int fileSize = fileStat.st_size;

		//-------- BUILD HEADER --------

		time_t now;
		struct tm *timeInfo;
		time(&now);
		timeInfo = localtime(&now);

		char *formattedDate = malloc(1024); 
		formattedDate = asctime(timeInfo);
			size_t ln = strlen(formattedDate) - 1;
				if (formattedDate[ln] == '\n')
    				formattedDate[ln] = '\0';

		char *httpHead = malloc(1024);
		char *portion = malloc(1024);

		sprintf(httpHead,"HTTP/1.1 200 OK\r\n");
		sprintf(portion,"Date: %s\r\n",formattedDate);
		strcat(httpHead,portion);
		sprintf(portion,"Content-Length: %d\r\n",fileSize);
		strcat(httpHead,portion);
		sprintf(portion,"Server: HTTPeeMyself\r\n\r\n");
		strcat(httpHead,portion);

		int totalSize = fileSize+strlen(httpHead);
		char sendBuffer[totalSize]; //buffer to send the file
		fread(sendBuffer,fileSize,1,fp);
			//sendBuffer should contain file now
		prepend(sendBuffer,httpHead);

		if (send(clntSock, sendBuffer, totalSize, 0) != totalSize)
                DieWithError("send() failed");

        close(clntSock);    // Close client socket
    }

	return 0;
}

void DieWithError(char *errorMessage) {
    perror(errorMessage);
    exit(1);
}

void printOutput(char *method, char *path, int status){
	time_t now;
	struct tm *timeInfo;
	time(&now);
	timeInfo = localtime(&now);

	char *formattedDate = malloc(1024); 
	formattedDate = asctime(timeInfo);
		size_t ln = strlen(formattedDate) - 1;
			if (formattedDate[ln] == '\n')
				formattedDate[ln] = '\0';
	printf("%s\t%s\t%s\t%d\n", method, path, formattedDate, status);
}

//checks if str starts with pre
bool startsWith(const char *str, const char *pre) {
   if(strncmp(str, pre, strlen(pre)) == 0) return 1;
   return 0;
}

bool parseRequest (char *requestString, char *method, char *path, char *httpVers){
    int i = 0;
    char *token; //process request piece-by piece

   	// FIRST TOKEN. should be GET or HEAD
   	token = strtok(requestString," ");
		if (strcmp(token,"GET")==0 || strcmp(token,"get")==0) strcpy(method,token);
   		else if (strcmp(token,"HEAD")==0 || strcmp(token,"head")==0) strcpy(method,token);
		else return false;
	
		//printf("Request is type: %s\n",method);

   	// OTHER TOKENS
	for(i=1; token != NULL && i<3; i++){
   	   	token = strtok(NULL, " ");

   		if (i==1){//token: path
   			//path = token;
   			strcpy(path,token);
   			//printf("REQUEST FILE: %s\n",path);
   			if (path[0] != '/'){
   				//printf("PATH ERROR. No slash\n");
   				return false;	
   			} 
   		} else if (i==2) {//token: http version
   			//printf("DEBUG-5\n");
   			if(startsWith(token,"HTTP/1.1")){
   				strcpy(httpVers,"HTTP/1.1"); 
   				//printf("HTTP VERSION: %s\n",httpVers);	
   			} else {
  				//printf("HTTP VERSION NOT SUPPORTED: %s",token);
  				return false;
  			} //else
   		} // i == 2
   	}//for
   	return true;
}

//Prepends toPrepend onto str. str must have enough space for toPrepend.
void prepend(char* str, const char* toPrepend) {
    size_t len = strlen(toPrepend);
    size_t i;

    memmove(str + len, str, strlen(str) + 1);

    for (i = 0; i < len; ++i) {
        str[i] = toPrepend[i];
    }
}

char* getContentType(char *path){



	return NULL;
}

