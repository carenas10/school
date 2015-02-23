#include <stdio.h>
#include <time.h> //rand()
#include <stdlib.h>
#include <stdint.h>
#include <string.h> //strtok() 


#define MAXID 30000



int main(int argc, char *argv[]) {

	//------------------------ PARSE INPUT ------------------------
	int timeout = 5; //default
	int retries = 3; //default 
	int port = 53; //default

	//checks for minimum arguments, or if there is an even number of args.
	if (argc < 3 || argc%2 == 0){
		printf("ERR1 - Usage: dnsq [-t <time>] [-r <retries>] [-p <port>] @<svr> <name>\n");
		exit(1);
	}
	
	char* svr = argv[argc-2];
	char* name = argv[argc-1];

	//parse server input. Must start with @ char.
	if (svr[0] != '@'){
		printf("ERR2 - Usage: dnsq [-t <time>] [-r <retries>] [-p <port>] @<svr> <name>\n");
		exit(1);
	} else {
		strcpy(svr,&svr[1]);
	}

	//check & handle input flags
	int i; 
	for(i=1;i<argc-2;i++){
		if(strcmp(argv[i],"-t") == 0){
			timeout = atoi(argv[i+1]);
		} else if(strcmp(argv[i],"-r") == 0){
			retries = atoi(argv[i+1]);
		} else if(strcmp(argv[i],"-p") == 0) {
			port = atoi(argv[i+1]);
		} else {
			printf("Invalid Flag: %s\n", argv[i]);
			printf("ERR3 - Usage: dnsq [-t <time] [-r <retries>] [-p <port>] @<svr> <name>\n");
			exit(1);
		}
		i++;
	}

	//------------------------ FORM QUERY ------------------------
	int16_t QDCOUNT = 1; //question count. Always 1 for us.
	int16_t ANCOUNT = 0; //answer count. Always 0. We only ask.
	int16_t NSCOUNT = 0; //num server authority resource records. ignore.
	int16_t ARCOUNT = 0; //num server additional records. ignore.

	int16_t QTYPE = 1;	//query type. host addresses: 0x0001


	//parse input


	//generate random request ID
	srand(time(NULL)); //only call once. 
	int newID = rand() % MAXID;



	return 0;
}
