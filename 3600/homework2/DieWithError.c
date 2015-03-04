#include <stdio.h>  	// for perror()
#include <stdlib.h> 	// for exit() 
#include <string.h>	//for strcmp

void DieWithError(char *errorMessage)
{
	if(strcmp(errorMessage,"usage")==0)
		printf("Usage: dnsq [-t <time>] [-r <retries>] [-p <port>] @<svr> <name>\n");
	else
		perror(errorMessage);
    exit(1);
}
