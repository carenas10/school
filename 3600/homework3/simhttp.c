#include <stdio.h>
#include <sys/socket.h> //for socket
#include <arpa/inet.h> 	//for sockaddr_in
#include <netdb.h> 		//for gethostbyname
#include <stdlib.h> 	//for atoi and exit
#include <string.h>     // for memset
#include <unistd.h>     //for close

#define MAXPENDING 5

void DieWithError(char *errorMessage);


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
		printf("port set to %d\n",servPort);
	} else if(argc == 2) { //no port. directory specified
		if(strcmp(argv[1],"-p")==0){ //-p with no port
			fprintf(stderr, "Usage: %s [-p port] [directory]\n", argv[0]);
			exit(0);	
		}
		localDirectory = argv[1];
		printf("localDirectory set to: %s\n", localDirectory);
		//do I need to check for a slash?
	} else if (argc == 4 && strcmp(argv[1],"-p") == 0){ //port and directory specified
		servPort = atoi(argv[2]);
		printf("port set to %d\n",servPort);
		localDirectory = argv[3];
		printf("localDirectory set to: %s\n", localDirectory);
	} else {
		fprintf(stderr, "Usage: %s [-p port] [directory]\n", argv[0]);
		exit(0);
	}

	//------------------------ set up TCP ------------------------
    int servSock;               	// Socket ID for server
    int clntSock;              		// Socket ID for client
    struct sockaddr_in servAddr; 	// Local address
    struct sockaddr_in clntAddr; 	// Client address
    //unsigned short ServPort;     	// Server port DEFINED ABOVE
    unsigned int clntLen;        	// Length of client address data structure

    /* Create socket for incoming connections */
    if ((servSock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
        DieWithError("socket() failed");

    /* Construct local address structure */
    memset(&servAddr, 0, sizeof(servAddr));   /* Zero out structure */
    servAddr.sin_family = AF_INET;                /* Internet address family */
    servAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    servAddr.sin_port = htons(servPort);      /* Local port */

    /* Bind to the local address */
    if (bind(servSock, (struct sockaddr *) &servAddr, sizeof(servAddr)) < 0)
        DieWithError("bind() failed");

    /* Mark the socket so it will listen for incoming connections */
    if (listen(servSock, MAXPENDING) < 0)
        DieWithError("listen() failed");


    //------------------------ handle clients ------------------------

    for (;;) /* Run forever */
    {
        /* Set the size of the in-out parameter */
        clntLen = sizeof(clntAddr);

        /* Wait for a client to connect */
        if ((clntSock = accept(servSock, (struct sockaddr *) &clntAddr, 
                               &clntLen)) < 0)
            DieWithError("accept() failed");

        /* clntSock is connected to a client! */

        printf("Handling client %s\n", inet_ntoa(echoClntAddr.sin_addr));

        HandleTCPClient(clntSock);
    }





	return 0;
}

void DieWithError(char *errorMessage)
{
    perror(errorMessage);
    exit(1);
}

