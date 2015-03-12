#include <stdio.h>
#include <sys/socket.h> //for socket
#include <arpa/inet.h> 	//for sockaddr_in
#include <netdb.h> 		//for gethostbyname
#include <stdlib.h> 	//for atoi and exit
#include <string.h>     // for memset
#include <unistd.h>     //for close

int main(int argc, char *argv[]){
	int port = 8080; //default port
	char *localDirectory; //user provided

	//------------------------ parse input ------------------------
	
	//simhttp [-p port] [directory]

	//impossible number of input args
	if(argc < 2 || argc > 4){
		fprintf(stderr, "Usage: %s [-p port] [directory]\n", argv[0]);
	}

	//check port flag
	if(strcmp(argv[1],"-p")==0){
		port = atoi(argv[2]);
		printf("port set to %d\n",port);
	} //else if() {

	//}


	return 0;
}

