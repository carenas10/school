#include "vg.h"

//function prototypes
int selectNextValue();


int main (int argc, char *argv[]){
    int valueToGuess;   //the server's random value
    int guessedValue;   //the guessed value from the client
    char response = -1;      //to send back to client.
    // 1 if high, 2 if low, 0 if correct.

    int sock;                        /* Socket */
    struct sockaddr_in echoServAddr; /* Local address */
    struct sockaddr_in echoClntAddr; /* Client address */
    unsigned int cliAddrLen;         /* Length of incoming message */
    char echoBuffer[256];        /* Buffer for echo string */
    unsigned short echoServPort;     /* Server port */
    int recvMsgSize;                 /* Size of received message */

    if (argc != 3)         /* Test for correct number of parameters */
    {
        fprintf(stderr,"Usage:  valueServer <serverPort> <initialValue>\n");
        exit(1);
    }

    echoServPort = atoi(argv[1]);  /* First arg:  local port */
    valueToGuess = atoi(argv[2]);  /* Second arg:  initial guess */

    /* Create socket for sending/receiving datagrams */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0){
        printf("socket() failed"); //DieWithError("socket() failed");
        exit(1);
    }

    /* Construct local address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));   /* Zero out structure */
    echoServAddr.sin_family = AF_INET;                /* Internet address family */
    echoServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    echoServAddr.sin_port = htons(echoServPort);      /* Local port */

    /* Bind to the local address */
    printf("UDPEchoServer: About to bind to port %d\n", echoServPort);
    if (bind(sock, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr)) < 0){
        printf("bind() failed"); //DieWithError("bind() failed");
        exit(1);
    }


    for (;;) /* Run forever */
    {
        /* Set the size of the in-out parameter */
        cliAddrLen = sizeof(echoClntAddr);

        /* Block until receive message from a client */
        if ((recvMsgSize = recvfrom(sock, echoBuffer, 255, 0,
            (struct sockaddr *) &echoClntAddr, &cliAddrLen)) < 0){
                printf("recvfrom() failed");    //DieWithError("recvfrom() failed");
                exit(1);
            }

            printf("Handling client %s\n", inet_ntoa(echoClntAddr.sin_addr));

            //check guess
            guessedValue = atoi(echoBuffer);
            printf("%d\n",guessedValue); //DEBUG print
            if(guessedValue > valueToGuess){ //guessedValue too large

            }else if(guessedValue < valueToGuess){ //guessedValue too small

            }else if(guessedValue == valueToGuess){ //guessedValue is correct!
            //guess new value
            }



            /* Send received datagram back to the client */
            if (sendto(sock, echoBuffer, recvMsgSize, 0,
                (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != recvMsgSize){
                    printf("sendto() sent a different number of bytes than expected");
                    exit(1);
                }
                //DieWithError("sendto() sent a different number of bytes than expected");
    }
            /* NOT REACHED */

    /*
    TODO -- The server replies with a message of 0, 1, or 2.
    Zero is returned if the guess is correct,
    1 if the guess is too high, and 2 if the guess is too low.
    */

    /*
    TODO -- At the server, if the value is guessed, the server randomly
    comes up with a new value and loops to play the game again.
    */

    /*
    At the client, if it successfully guesses the value
    it terminates displaying an appropriate message to the user.
    */

    return 0;
}

//returns a random int value
//TODO -- find better random generator
int selectNextValue(){
    srand(time(NULL));
    int r = rand();
    printf("guess: %d", r);
    return r;
}
