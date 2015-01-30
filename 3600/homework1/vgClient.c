#include "vg.h"
#include <signal.h>

#define MAXVAL 1000000000
//function prototypes
int selectNextValue();
void clientCNTCCode();
char *itoa (int value, char *result, int base);

int main (int argc, char *argv[]){
    //Client vars
    int tmp = 0;
    int prevGuess = MAXVAL;
    int guess = MAXVAL/2;                  //value to send to server
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
        DieWithError("socket() failed");
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

    //guess random, send random, check result, repeat (if incorrect);
    //----------------------- SEND/RCV ---------------------

    while(1){
        sprintf(echoString, "%d", guess);

        //itoa(guess,echoString,10);
        printf("%s\n",echoString);
        echoStringLen = strlen(echoString);
        printf("send size: %d\n",echoStringLen);

        //send
        if (sendto(sock, echoString, echoStringLen, 0, (struct sockaddr *)
            &echoServAddr, sizeof(echoServAddr)) != echoStringLen)
            DieWithError("sendto() sent a different number of bytes than expected");

        //receive
        fromSize = sizeof(fromAddr);
        if ((respStringLen = recvfrom(sock, echoBuffer, 256, 0,
            (struct sockaddr *) &fromAddr, &fromSize)) < 0) //added +1
            DieWithError("recvfrom() failed");

        //check to make sure correct address was sending
        if (echoServAddr.sin_addr.s_addr != fromAddr.sin_addr.s_addr){
            fprintf(stderr,"Error: received a packet from unknown source \n");
        }

        result = atoi(echoBuffer);

        //binary search
        if (result == -1){
            //no response set
            printf("Server didn't respond.");
        } else if (result == 0){
            printf("correct guess!\n");
            exit(0);
            //printf("Server responded with %d\n",result);
        } else if (result == 1){
            //too high
            tmp = guess;
            guess = guess - abs(prevGuess-guess)/2;
            prevGuess = tmp;
            if (guess == prevGuess) guess--;
            printf("Server responded with %d\n",result);
        } else if (result == 2){
            //too low
            tmp = guess;
            guess = guess + abs(prevGuess - guess)/2;
            prevGuess = tmp;
            if (guess == prevGuess) guess++;
            printf("Server responded with %d\n",result);
        } else {
            printf("Error:\n");
            printf("Server responded with %d\n",result);
            //incorrect response
        }

    }//while

//----------------------- SEND/RCV ---------------------

// printf("%d\t%.3f\t%d\n",tries,runningTime,guess);

//finish and close
close(sock);
exit(0);

return 0;
}

//----------------------- methods ---------------------------------

//returns a random int value
//TODO -- find better random generator
int selectNextValue(){
    srand(time(NULL));
    int r = rand();
    //printf("guess: %d", r);
    return r;
}

//calculates the result of base^power as ints
int ipower(int base, int power){
    int result = base;
    while (power > 1){
        result = result * base;
        power--;
    }
    return result;
}


void clientCNTCCode() {
    printf("UDPEchoClient:  CNT-C Interrupt,  exiting....\n");
}

char *itoa (int value, char *result, int base)
{
    // check that the base if valid
    if (base < 2 || base > 36) { *result = '\0'; return result; }

        char* ptr = result, *ptr1 = result, tmp_char;
        int tmp_value;

        do {
            tmp_value = value;
            value /= base;
            *ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
        } while ( value );

        // Apply negative sign
        if (tmp_value < 0) *ptr++ = '-';
        *ptr-- = '\0';
        while (ptr1 < ptr) {
            tmp_char = *ptr;
            *ptr--= *ptr1;
            *ptr1++ = tmp_char;
        }
        return result;
}
