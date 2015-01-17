#include "vg.h"

//function prototypes
int selectNextValue();
int tryValue(int guess);


int main (int argc, char *argv[]){
    //Client vars
    int guess;                  //value to send to server
    int result = -1;            //response from server
    int tries = 0;              //number of attempts
    float runningTime = 0.0;    //elapsed time

    //UDP vars
    int sock;                        /* Socket descriptor */
    struct sockaddr_in echoServAddr; /* server address */
    struct sockaddr_in fromAddr;     /* Source address of response */
    struct hostent *thehost;         /* Hostent from gethostbyname() */
    unsigned short echoServPort;     /* Echo server port */
    unsigned int fromSize;           /* In-out of address size for recvfrom() */
    char *servIP;                    /* IP address of server */
    char *echoString;                /* String to send to echo server */
    char echoBuffer[256];      /* Buffer for receiving echoed string */
    int echoStringLen;               /* Length of string to echo */
    int respStringLen;               /* Length of received response */

    //check cmd line arguments
    if(argc != 3){
        printf("Usage: valueGuesser <serverName> <serverPort>\n");
        exit(1);
    }

    servIP = argv[1];           /* First arg: server IP address (dotted quad) */
    //echoString = argv[2];       /* Second arg: string to echo */
    echoServPort = atoi(argv[2]);     /* Second arg: server port */

    /* Create a datagram/UDP socket */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0){
        printf("socket() failed"); //DieWithError("socket() failed");
        exit(1);
    }

    /* Construct the server address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));    /* Zero out structure */
    echoServAddr.sin_family = AF_INET;                 /* Internet addr family */
    echoServAddr.sin_addr.s_addr = inet_addr(servIP);  /* Server IP address */
    echoServAddr.sin_port   = htons(echoServPort);     /* Server port */

    /* If user gave a dotted decimal address, we need to resolve it  */
    if (echoServAddr.sin_addr.s_addr == -1) {
        thehost = gethostbyname(servIP);
        echoServAddr.sin_addr.s_addr = *((unsigned long *) thehost->h_addr_list[0]);
    }
/*
    //guess random, send random, check result, repeat (if incorrect);
    while (1 == 1){
        guess = selectNextValue();
        result = tryValue(guess);
        if (result == 0){
            // print completion message and break;
            //output finished info to user
            printf("%d\t%.3f\t%d\n",tries,runningTime,guess);
            return 0;
        } if (result == 1){ //too high
            //continue looping
        } if (result == 2){ //too low
            //continue looping
        } if (result == -1){ //error/timeout
            //continue looping
        }
    }//while
*/
    /*
    TODO -- At the client, if it successfully guesses the value
    it terminates displaying an appropriate message to the user.
    */

return 0;
}

//----------------------- methods ---------------------------------

//returns a random int value
//TODO -- find better random generator
int selectNextValue(){
    srand(time(NULL));
    int r = rand();
    printf("guess: %d", r);
    return r;
}
