#include "UDPEcho.h"


void DieWithError(char *errorMessage);  /* External error handling function */

int main(int argc, char *argv[])
{
    int valueToGuess;   //the server's random value
    int guessedValue;   //the guessed value from the client
    char response;      //to send back to client.
        // 1 if high, 2 if low, 0 if correct.

    int sock;                        /* Socket */
    struct sockaddr_in echoServAddr; /* Local address */
    struct sockaddr_in echoClntAddr; /* Client address */
    unsigned int cliAddrLen;         /* Length of incoming message */
    char echoBuffer[ECHOMAX];        /* Buffer for echo string */
    unsigned short echoServPort;     /* Server port */
    int recvMsgSize;                 /* Size of received message */

    if (argc != 2)         /* Test for correct number of parameters */
    {
        fprintf(stderr,"Usage:  %s <UDP SERVER PORT>\n", argv[0]);
        exit(1);
    }

    echoServPort = atoi(argv[1]);  /* First arg:  local port */

    /* Create socket for sending/receiving datagrams */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
        DieWithError("socket() failed");

    /* Construct local address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));   /* Zero out structure */
    echoServAddr.sin_family = AF_INET;                /* Internet address family */
    echoServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    echoServAddr.sin_port = htons(echoServPort);      /* Local port */

    /* Bind to the local address */
    printf("UDPEchoServer: About to bind to port %d\n", echoServPort);
    if (bind(sock, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr)) < 0)
        DieWithError("bind() failed");

    for (;;) /* Run forever */
    {
        /* Set the size of the in-out parameter */
        cliAddrLen = sizeof(echoClntAddr);

        /* Block until receive message from a client */
        if ((recvMsgSize = recvfrom(sock, echoBuffer, ECHOMAX, 0,
            (struct sockaddr *) &echoClntAddr, &cliAddrLen)) < 0){
            printf("recvfrom() failed\n"); //DieWithError("recvfrom() failed");
            exit(1);
        }

        printf("Handling client %s\n", inet_ntoa(echoClntAddr.sin_addr));
/*
        //check guess
        guessedValue = atoi(echoBuffer);
        printf("%s\n"guessedValue);
        if(guessedValue > valueToGuess){ //guessedValue too large

        }else if(guessedValue < valueToGuess){ //guessedValue too small

        }else if(guessedValue == valueToGuess){ //guessedValue is correct!
            //guess new value
        }
*/
        /* Send received datagram back to the client */
        if (sendto(sock, echoBuffer, recvMsgSize, 0,
             (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != recvMsgSize)
            DieWithError("sendto() sent a different number of bytes than expected\n");
    }
    /* NOT REACHED */
}
