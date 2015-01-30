/*
*   File: vgServer.c
*   Author: Jackson Dawkins
*   Last Modified: 1.30.2015
*   Usage: valueServer <serverPort> <initialValue>
*
*   Summary: This file contains code for a value-guessing server.
*           The server binds to the port designated in the cmd line args.
*           The server picks a random number bounded to 10^9
*           The server waits for udp messages containing a guess, and responds
*           depending on the value of the guess.
*/

#include "vg.h"

#define MAXVAL 1000000000

//function prototypes
int selectNextValue();
void clientCNTCCode();

//globals
int numMessages = 0;
int numCorrect = 0;
char clientList [256];

int main (int argc, char *argv[]){
    signal(SIGINT, clientCNTCCode); //handler for Ctrl-C signal

    int valueToGuess;               //the server's random value
    int guessedValue;               //the guessed value from the client
    char *response = "-1";          //to send back to client.
    clientList[0] = '\0';           //initialize empty string for clients.

    int sock;                           // Socket
    struct sockaddr_in echoServAddr;    // Local address
    struct sockaddr_in echoClntAddr;    // Client address
    unsigned int cliAddrLen;            // Length of incoming message
    char echoBuffer[256];               // Buffer for echo string
    unsigned short echoServPort;        // Server port
    int recvMsgSize;                    // Size of received message
    int sendMsgSize;

    if (argc != 3 && argc !=2)          // Test for correct number of parameters
    {
        fprintf(stderr,"Usage:  valueServer <serverPort> <initialValue>\n");
        exit(1);
    }

    echoServPort = atoi(argv[1]);       // First arg:  local port

    if (argc == 3) valueToGuess = atoi(argv[2]);  // Second arg: (optional) initial guess
    else valueToGuess = selectNextValue();

    // Create socket for sending/receiving datagrams
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0){
        DieWithError("socket() failed");
    }

    // Construct local address structure
    memset(&echoServAddr, 0, sizeof(echoServAddr));   // Zero out structure
    echoServAddr.sin_family = AF_INET;                // Internet address family
    echoServAddr.sin_addr.s_addr = htonl(INADDR_ANY); // Any incoming interface
    echoServAddr.sin_port = htons(echoServPort);      // Local port

    // Bind to the local address
    if (bind(sock, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr)) < 0){
        DieWithError("bind() failed");
    }

    //receive message, add client info, check guess, respond, repeat.
    while (1) {     // Run forever
        // Set the size of the in-out parameter
        cliAddrLen = sizeof(echoClntAddr);

        // Block until receive message from a client
        if ((recvMsgSize = recvfrom(sock, echoBuffer, 255, 0,
            (struct sockaddr *) &echoClntAddr, &cliAddrLen)) < 0){
                DieWithError("recvfrom() failed");
            }

            //handle a client. Track a client.
            strcat(clientList,inet_ntoa(echoClntAddr.sin_addr));
            strcat(clientList,", ");
            numMessages++;

            //check guess
            echoBuffer[recvMsgSize] = '\0';
            guessedValue = atoi(echoBuffer);

            if(guessedValue > valueToGuess){ //guessedValue too large
                response = "1";
                sendMsgSize = strlen(response);

                // Send received datagram back to the client
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
            }else if(guessedValue < valueToGuess){ //guessedValue too small
                response = "2";
                sendMsgSize = strlen(response);

                // Send received datagram back to the client
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
            }else if(guessedValue == valueToGuess){ //guessedValue is correct!
                response = "0";
                sendMsgSize = strlen(response);

                // Send received datagram back to the client
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
                //client guessed correctly. Guess a new value and start over.
                numCorrect++;
                valueToGuess = selectNextValue();
            } else {
                response = "-1";
                sendMsgSize = strlen(response);

                // Send received datagram back to the client
                if (sendto(sock, response, sendMsgSize, 0,
                    (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != sendMsgSize){
                        DieWithError("sendto() sent a different number of bytes than expected.");
                    }
            } //else
    }//while

    return 0;
}

//----------------------- methods ---------------------------------

//handles user pressing ctrl-c by printout output and exiting.
void clientCNTCCode() {
    printf("\nvalueServer:  CNT-C Interrupt,  exiting....\n");
    printf("%d\t%d\t%s",numMessages,numCorrect,clientList);
    exit(0);
}

//returns a random int value
//find better random generator
int selectNextValue(){
    srand(time(NULL));
    int r = rand();
    r = r % MAXVAL;
    printf("New guess: %d", r);
    return r;
}
