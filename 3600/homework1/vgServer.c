#include "vg.h"

#define MAXVAL 1000000000

//function prototypes
int selectNextValue();
void copyStringAndTerminate(int, char*, char*);

int main (int argc, char *argv[]){
    int valueToGuess;   //the server's random value
    int guessedValue;   //the guessed value from the client
    char *response = "-1";      //to send back to client.
    // 1 if high, 2 if low, 0 if correct.

    int sock;                        /* Socket */
    struct sockaddr_in echoServAddr; /* Local address */
    struct sockaddr_in echoClntAddr; /* Client address */
    unsigned int cliAddrLen;         /* Length of incoming message */
    char echoBuffer[256];        /* Buffer for echo string */
    char copyBuffer[15];
    unsigned short echoServPort;     /* Server port */
    int recvMsgSize;                 /* Size of received message */
    int sendMsgSize;

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
                DieWithError("recvfrom() failed");
            }

            //printf("Handling client %s\n", inet_ntoa(echoClntAddr.sin_addr));

            //check guess
            copyStringAndTerminate(recvMsgSize,echoBuffer,copyBuffer);
            copyStringAndTerminate(recvMsgSize,copyBuffer,echoBuffer);
            printf("echoBuffer: %s\n",echoBuffer);
            guessedValue = atoi(echoBuffer);

            printf("guess: %d, server: %d\n\n",guessedValue,valueToGuess); //DEBUG print
            //printf("size: %d\n",recvMsgSize);

            if(guessedValue > valueToGuess){ //guessedValue too large
                response = "1";
                sendMsgSize = strlen(response);
                //printf("Response: %s, Length: %d",response,sendMsgSize);
                /* Send received datagram back to the client */
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
            }else if(guessedValue < valueToGuess){ //guessedValue too small
                response = "2";
                sendMsgSize = strlen(response);
                //printf("Response: %s, Length: %d",response,sendMsgSize);
                /* Send received datagram back to the client */
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
            }else if(guessedValue == valueToGuess){ //guessedValue is correct!
                response = "0";
                sendMsgSize = strlen(response);
                //printf("Response: %s, Length: %d",response,sendMsgSize);
                /* Send received datagram back to the client */
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
                //client guessed correctly. Guess a new value and start over.
                valueToGuess = selectNextValue();
            } else {
                response = "-1";
                sendMsgSize = strlen(response);
                //printf("Response: %s, Length: %d",response,sendMsgSize);
                /* Send received datagram back to the client */
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
            } //else


    }

    return 0;
}

//returns a random int value
//TODO -- find better random generator
int selectNextValue(){
    srand(time(NULL));
    int r = rand();
    r = r % MAXVAL;
    printf("New guess: %d", r);
    return r;
}

void copyStringAndTerminate(int len, char* in, char* out){
    int i;
    for (i=0;i<len;i++){
        out[i] = in[i];
    }
    out[i+1] = '\0';
}
