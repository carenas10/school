#include "vg.h"

#define MAXVAL 1000000000

//function prototypes
void clientCNTCCode();
double getTime();
void catchAlarm(int ignored);       //handler for SIGALRM signal - timeout

//globals
int tries = 0;                      //number of attempts
static const unsigned int TIMEOUT_SECS = 2; //time before timeout fired.

int main (int argc, char *argv[]){
    signal(SIGINT, clientCNTCCode); //handler for Ctrl-C signal

    double time = 0.0;              //elapsed time
    time = getTime();

    //Client vars
    int tmp = 0;
    int prevGuess = MAXVAL;         //used for binary search
    int guess = MAXVAL/2;           //value to send to server
    int result = -1;                //response from server

    //UDP vars
    int sock;                        // Socket descriptor
    struct sockaddr_in echoServAddr; // server address
    struct sockaddr_in fromAddr;     // Source address of response
    struct hostent *thehost;         // Hostent from gethostbyname()
    unsigned short echoServPort;     // Server port
    unsigned int fromSize;           // In-out of address size for recvfrom()
    char *servIP;                    // IP address of server
    char *echoString;                // String to send to echo server
    char echoBuffer[256];            // Buffer for receiving response string
    int echoStringLen;               // Length of string to echo
    int respStringLen;               // Length of received response

    //check cmd line arguments
    if(argc != 3){
        printf("Usage: valueGuesser <serverName> <serverPort>\n");
        exit(1);
    }

    servIP = argv[1];               // First arg: server IP address (dotted quad)
    echoServPort = atoi(argv[2]);   // Second arg: server port

    // Create a datagram/UDP socket
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0){
        DieWithError("socket() failed");
    }

    // Construct the server address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));    // Zero out structure
    echoServAddr.sin_family = AF_INET;                 // Internet addr family
    echoServAddr.sin_addr.s_addr = inet_addr(servIP);  // Server IP address
    echoServAddr.sin_port   = htons(echoServPort);     // Server port

    // If user gave a dotted decimal address, we need to resolve it
    if (echoServAddr.sin_addr.s_addr == -1) {
        thehost = gethostbyname(servIP);
        echoServAddr.sin_addr.s_addr = *((unsigned long *) thehost->h_addr_list[0]);
    }

    //choose guess (bsearch), send, check response, repeat (if incorrect)
    while(1){
        tries++;
        sprintf(echoString, "%d", guess);

        echoStringLen = strlen(echoString);

        //set up signal handler
        struct sigaction handler;
        handler.sa_handler = catchAlarm;
        if (sigfillset(&handler.sa_mask)<0) //block everything in handler
            DieWithError("sigfillset() failed");
        handler.sa_flags = 0;
        if (sigaction(SIGALRM, &handler, 0) < 0)
            DieWithError("sigaction() failed for SIGALRM");

        //send
        if (sendto(sock, echoString, echoStringLen, 0, (struct sockaddr *)
            &echoServAddr, sizeof(echoServAddr)) != echoStringLen)
            DieWithError("sendto() sent a different number of bytes than expected");

        //receive with a timer to trip at TIMEOUT_SECS (2)
        alarm(TIMEOUT_SECS);    //start timer
        fromSize = sizeof(fromAddr);
        if ((respStringLen = recvfrom(sock, echoBuffer, 256, 0,
            (struct sockaddr *) &fromAddr, &fromSize)) < 0)
            strcpy(echoBuffer, "-1"); //-1 indicates error
        alarm(0); //reset timer. Receive successful.

        //if no receive error, check address.
        if (strcmp(echoBuffer,"-1") != 0){
            //check to make sure correct address was sending
            if (echoServAddr.sin_addr.s_addr != fromAddr.sin_addr.s_addr){
                fprintf(stderr,"Error: received a packet from unknown source \n");
            }
        }

        result = atoi(echoBuffer);

        //binary search
        if (result == -1){
            //no response set
        } else if (result == 0){
            //correct guess! Break loop and print.
            break;
        } else if (result == 1){
            //too high
            tmp = guess;
            guess = guess - abs(prevGuess-guess)/2;
            prevGuess = tmp;
            if (guess == prevGuess) guess--;
        } else if (result == 2){
            //too low
            tmp = guess;
            guess = guess + abs(prevGuess - guess)/2;
            prevGuess = tmp;
            if (guess == prevGuess) guess++;
        }
    }//while

    //subtract curr time from time at start to get runtime
    time = getTime() - time;

    //final printout after correct guess
    printf("%d\t%.6f\t%d\n",tries,time,guess);

    //finish and close
    close(sock);
    exit(0);

return 0;
}

//----------------------- methods ---------------------------------

//handler for SIGALRM
void catchAlarm(int ignored){
    //do nothing
}

//returns the time in seconds
double getTime()
{
    struct timeval curTime;
    (void) gettimeofday (&curTime, (struct timezone *) NULL);
    return (((((double) curTime.tv_sec) * 1000000.0)
         + (double) curTime.tv_usec) / 1000000.0);
}

//handles user pressing ctrl-c by printout output and exiting.
void clientCNTCCode() {
    printf("\nvalueGuesser:  CNT-C Interrupt,  exiting....\n");
    exit(0);
}
