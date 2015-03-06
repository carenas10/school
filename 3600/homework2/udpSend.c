/*
*   File: udpTools.c
*   Author: Jackson Dawkins
*   Last Modified: 3.3.2015
*   Usage: valueGuesser <serverName> <serverPort>
*
*   Summary: contains code for sending a UDP message and returning the 
*           contents of the response.
*           
*           
*/

#include "udpSend.h"

//------------------------ SEND UDP MESSAGE ------------------------

char* sendMSG(char* server,int port, char message[],int messageLen){

    //UDP vars
    int sock;                        // Socket descriptor
    struct sockaddr_in echoServAddr; // server address
    struct sockaddr_in fromAddr;     // Source address of response
    struct hostent *thehost;         // Hostent from gethostbyname()
    unsigned short echoServPort;     // Server port
    unsigned int fromSize;           // In-out of address size for recvfrom()
    char *servIP;                    // IP address of server
	char *retMSG = (char *)malloc(256*sizeof(char));
    int messageLength;               // Length of string to echo
    int respStringLen;               // Length of received response

    servIP = server;               // First arg: server IP address (dotted quad)
    echoServPort = port;   // Second arg: server port

    // Create a datagram/UDP socket
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0){
        DieWithError("socket() failed");
    }

    // Construct the server address structure 
    memset(&echoServAddr, 0, sizeof(echoServAddr));    // Zero out structure
    echoServAddr.sin_family = AF_INET;                 // Internet addr family
    echoServAddr.sin_addr.s_addr = inet_addr(servIP);  // Server IP address
    echoServAddr.sin_port   = htons(echoServPort);     // Server port

    // If user gave a dotted decimal address, we need to resolve it
    if (echoServAddr.sin_addr.s_addr == -1) {
        thehost = gethostbyname(servIP);
        echoServAddr.sin_addr.s_addr = *((unsigned long *) thehost->h_addr_list[0]);
    }
 
	messageLength = messageLen;

    //send
    if (sendto(sock, message, messageLength, 0, (struct sockaddr *)
        &echoServAddr, sizeof(echoServAddr)) != messageLength)
        DieWithError("sendto() sent a different number of bytes than expected");

    fromSize = sizeof(fromAddr);
    if ((respStringLen = recvfrom(sock, retMSG, 256, 0,
        (struct sockaddr *) &fromAddr, &fromSize)) < 0)
        strcpy(retMSG, "-1"); //-1 indicates error 

    //if no receive error, check address.
    if (strcmp(retMSG,"-1") != 0){
        //check to make sure correct address was sending
        if (echoServAddr.sin_addr.s_addr != fromAddr.sin_addr.s_addr){
            fprintf(stderr,"Error: received a packet from unknown source \n");
        }
    }

    //finish and close
    close(sock);

	return retMSG;

}

