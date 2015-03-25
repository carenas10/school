#include <stdio.h>      // for printf() and fprintf() 
#include <sys/socket.h> // for socket(), connect(), send(), and recv() 
#include <arpa/inet.h>  // for sockaddr_in and inet_addr() 
#include <netdb.h>      // for getHostByName() 
#include <stdlib.h>     // for atoi() and exit() 
#include <string.h>     // for memset() 
#include <unistd.h>     // for close() 
#include <stdbool.h>	//for startsWith fuction

#define RCVBUFSIZE 10000   // Size of receive buffer 
#define MAXBUF 100000
#define DEBUG 0

void DieWithError(char *errorMessage);  // Error handling function 
bool startsWith(const char *str, const char *pre); //checks if string a starts with b
char* getFileType(char *str);

int main(int argc, char *argv[])
{
    int sock;                           // Socket ID 

    struct sockaddr_in servAddr;        // HTTP server address 
    unsigned short servPort = 8080;     // HTTP server port
    char *servIP = malloc(sizeof(char)*100);                       // HTTP Server IP address (dotted quad) 
    
    struct hostent *thehost;            // Hostent from gethostbyname() 
    
    char sendMsg[MAXBUF];                      //String to send to server (HTTP GET REQUEST)
    unsigned int sendMsgLen;            // Length of string to send 

    char recvBuffer[RCVBUFSIZE];        // Buffer for data to recv 
    int bytesRcvd, totalBytesRcvd;      //Bytes read in single recv(), and total bytes read 

    //------------------------ PARSE INPUT ------------------------ 
    char *url;
    char *filename;

    //impossible number of input args
    if(argc > 6 || argc < 2){
        fprintf(stderr, "Usage: %s URL [-p port] [-O Filename]\n", argv[0]);
        exit(0);
    }
    
    //check flags
    if (argc == 2){ //url only
        url = argv[1];
        if(DEBUG) printf("URL: %s\n",url);
    } else if (argc == 4 && strcmp(argv[2],"-p") == 0){ //url & port
        url = argv[1];
        if(DEBUG) printf("URL: %s\n",url);
        servPort = atoi(argv[3]);
        if(DEBUG) printf("PORT: %d\n",servPort);
    } else if (argc == 4 && strcmp(argv[2],"-O") == 0){ //url & filename
        url = argv[1];
        if(DEBUG) printf("URL: %s\n",url);
        filename = argv[3];
        if(DEBUG) printf("FILE: %s\n",filename);
    } else if (argc == 6 && (strcmp(argv[2],"-p") == 0 && strcmp(argv[4],"-O") == 0)){ //all 3
        url = argv[1];
        if(DEBUG) printf("URL: %s\n",url);
        servPort = atoi(argv[3]);
        if(DEBUG) printf("PORT: %d\n",servPort);
        filename = argv[5];
        if(DEBUG) printf("FILE: %s\n",filename);
    } else { //invalid combination
        fprintf(stderr, "Usage: %s URL [-p port] [-O Filename]\n", argv[0]);
        exit(0);
    }

    //if url starts with http://, remove. http is given.
	if(startsWith(url,"http://")){ //string starts with http://
		url += 7;
		if(DEBUG) printf("URL: %s\n",url);
	} 

	if(DEBUG) printf("------------------------\n");
	//separate url into path and host

    char *path; //will contain the path of the original URL.

    int pos = 0; //used to find the first slash.
    for(pos=0; pos<strlen(url); pos++){
    	if(url[pos]=='/' && pos!=strlen(url)-1){ //only change if not at end.
    		url[pos] = ' '; //change from slash to space for token
    		break;
    	}
    }

    // url will point to url in original URI.
	url = strtok(url," ");

	// url will point to path in original URI.
	path = strtok(NULL," ");

    if(DEBUG) printf("NEW PATH:%s\nNEW URL:%s\n",path,url);
	if(DEBUG) printf("------------------------\n");


    //resolve hostname using DNS
    struct hostent *host;
    struct in_addr **listOfDNSResults;

    if ((host = gethostbyname(url)) == NULL) {
        DieWithError("gethostbyname");
    }
 
    listOfDNSResults = (struct in_addr **) host->h_addr_list;

    if(listOfDNSResults[0] != NULL)
        strcpy(servIP, inet_ntoa(*listOfDNSResults[0])); //set servIP here
    else
        DieWithError("gethostbyname");

    if(DEBUG) printf("URL -> IP: %s\n",servIP);

    //cr - 13, lf - 10 \r\n
    //------------------------ CONSTRUCT HTTP REQUEST ------------------------
    if(DEBUG) printf("------------------------\n");

    //construct different request, depending on if path defined or not.
    if(path == NULL){
    	sprintf(sendMsg,"GET / HTTP/1.1\r\nHost: %s\n\n",url);
    } else{
    	sprintf(sendMsg,"GET /%s HTTP/1.1\r\nHost: %s\n\n",path,url);
    }

    if(DEBUG) printf("%s\n",sendMsg);
	
    if(DEBUG) printf("passed request construction...\n");

    //------------------------ SET UP TCP ------------------------

    // create TCP socket - SOCK_STREAM: stream paradigm, IPPROTO_TCP: tcp
    if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
        DieWithError("socket() failed");

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
    if (connect(sock, (struct sockaddr *) &servAddr, sizeof(servAddr)) < 0)
        DieWithError("connect() failed");

    sendMsgLen = strlen(sendMsg);   // Determine input length 

    //------------------------ SEND/RECEIVE ------------------------

    // Send the string to the server 
    if (send(sock, sendMsg, sendMsgLen, 0) != sendMsgLen)
        DieWithError("send() sent a different number of bytes than expected");

    // Receive the file back from the server 
    totalBytesRcvd = 0;
    if(DEBUG) printf("Received: ");	// Setup to print the received string

    //open a file write location if filname was set in input parsing...
   	FILE *fp; 
    if(filename != NULL) fp = fopen(filename, "w");

    while (1) {
        /* Receive up to the buffer size (minus 1 to leave space for
           a null terminator) bytes from the sender */
        if ((bytesRcvd = recv(sock, recvBuffer, RCVBUFSIZE - 1, 0)) <= 0)
            break; //done receiving
            //DieWithError("recv() failed or connection closed prematurely");
        
        totalBytesRcvd += bytesRcvd;   // Keep tally of total bytes 
        recvBuffer[bytesRcvd] = '\0';  // Terminate the string! 

        if(filename != NULL) fprintf(fp,"%s",recvBuffer); //print to file if open
        else printf("%s",recvBuffer);	//else print to stdout
    }//while receiving 

    //fclose(fp);
    //rename(filename,strcat(filename,getFileType(recvBuffer)));

	printf("\n");    // Print a final linefeed 
    
    if(DEBUG) printf("finished. closing...\n");
    close(sock);    //client terminates after timeout. TODO
    exit(0);
}

void DieWithError(char *errorMessage) {
    perror(errorMessage);
    exit(1);
}

//checks if a starts with b
bool startsWith(const char *str, const char *pre) {
   if(strncmp(str, pre, strlen(pre)) == 0) return 1;
   return 0;
}

char* getFileType(char *str){
	if(strstr(str,"text/html")) {
		return ".html";
	} else if (strstr(str,"text/css")) {
		return ".css";
	} else if (strstr(str,"application/javascript")) {
		return ".js";
	} else if (strstr(str,"text/plain")) {
		return ".txt";
	} else if (strstr(str,"image/jpeg")){
		return ".jpg";
	} else if (strstr(str,"application/pdf")) {
		return ".pdf";
	} else { //application/octet-stream
		return ""; //no file extension 
	}
}