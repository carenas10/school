#include <stdio.h>      // for printf() and fprintf() 
#include <sys/socket.h> // for socket(), connect(), send(), and recv() 
#include <arpa/inet.h>  // for sockaddr_in and inet_addr() 
#include <netdb.h>      // for getHostByName() 
#include <stdlib.h>     // for atoi() and exit() 
#include <string.h>     // for memset() 
#include <unistd.h>     // for close() 

#define RCVBUFSIZE 32   // Size of receive buffer 

void DieWithError(char *errorMessage);  // Error handling function 

int main(int argc, char *argv[])
{
    int sock;                           // Socket ID 

    struct sockaddr_in servAddr;        // HTTP server address 
    unsigned short servPort = 8080;     // HTTP server port
    char *servIP = malloc(sizeof(char)*100);                       // HTTP Server IP address (dotted quad) 
    
    struct hostent *thehost;            // Hostent from gethostbyname() 
    
    char sendMsg[256];                      //String to send to server (HTTP GET REQUEST)
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
        printf("URL: %s\n",url);
    } else if (argc == 4 && strcmp(argv[2],"-p") == 0){ //url & port
        url = argv[1];
        printf("URL: %s\n",url);
        servPort = atoi(argv[3]);
        printf("PORT: %d\n",servPort);
    } else if (argc == 4 && strcmp(argv[2],"-O") == 0){ //url & filename
        url = argv[1];
        printf("URL: %s\n",url);
        filename = argv[3];
        printf("FILE: %s\n",filename);
    } else if (argc == 6 && (strcmp(argv[2],"-p") == 0 && strcmp(argv[4],"-O") == 0)){ //all 3
        url = argv[1];
        printf("URL: %s\n",url);
        servPort = atoi(argv[3]);
        printf("PORT: %d\n",servPort);
        filename = argv[5];
        printf("FILE: %s\n",filename);
    } else { //invalid combination
        fprintf(stderr, "Usage: %s URL [-p port] [-O Filename]\n", argv[0]);
        exit(0);
    }

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

    printf("URL -> IP: %s\n",servIP);

    //cr - 13, lf - 10
    //------------------------ CONSTRUCT HTTP REQUEST ------------------------
    sendMsg[0] = 0;
    strcat(sendMsg, "GET ");
    strcat(sendMsg,url);
    strcat(sendMsg," HTTP/1.1\n\n");

    //strcat();

    printf("%s\n",sendMsg);

    printf("passed request construction...\n");
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
    printf("Received: ");                // Setup to print the echoed string 
    while (1)
    {
        /* Receive up to the buffer size (minus 1 to leave space for
           a null terminator) bytes from the sender */
        if ((bytesRcvd = recv(sock, recvBuffer, RCVBUFSIZE - 1, 0)) <= 0)
            break; //done receiving
            //DieWithError("recv() failed or connection closed prematurely");
        totalBytesRcvd += bytesRcvd;   // Keep tally of total bytes 
        recvBuffer[bytesRcvd] = '\0';  // Terminate the string! 
        printf("%s",recvBuffer);            // Print the echo buffer 
    }

    printf("\n");    // Print a final linefeed 
    printf("finished. closing...\n");
    close(sock);    //client terminates after timeout. TODO
    exit(0);
}

void DieWithError(char *errorMessage)
{
    perror(errorMessage);
    exit(1);
}

