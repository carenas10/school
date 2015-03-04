#include "dnsq.h"
#include "udpTools.h"

int main(int argc, char *argv[]) {

	//------------------------ PARSE INPUT ------------------------
	int timeout = 5; //default
	int retries = 3; //default 
	int port = 53; //default

	//checks for minimum arguments, or if there is an even number of args.
	if (argc < 3 || argc%2 == 0){
		DieWithError("usage");
	}

	char* svr = argv[argc-2];
	char* name = argv[argc-1];

	//parse server input. Must start with @ char.
	if (svr[0] != '@'){
		DieWithError("usage");
	} else {
		strcpy(svr,&svr[1]);
	}

	//check & handle input flags. Checks for placement and flag, not values.
	int i; 
	for(i=1;i<argc-2;i++){
		if(strcmp(argv[i],"-t") == 0){
			timeout = atoi(argv[i+1]);
		} else if(strcmp(argv[i],"-r") == 0){
			retries = atoi(argv[i+1]);
		} else if(strcmp(argv[i],"-p") == 0) {
			port = atoi(argv[i+1]);
		} else {
			DieWithError("usage");
		}
		i++;
	}

	//silence unused warning DEBUG
	if(timeout == retries && port == retries)
		printf("oh wow...\n");


	//------------------------ FORM QUERY ------------------------
	struct DNSQ_T *query = malloc(sizeof(struct DNSQ_T));

	char message[256];

	//-------- HEADER VARS --------
	/*srand(time(NULL)); //only call once. 
	query->ID = rand() % MAXID;*/
	query->ID = 18505; 	//TEMP for testing -- printout: 'HI' ascii	
	
	query->QR = 1; 		//query or message <1>				DEFAULT: 1	
	query->OPCODE = 1;	//type of query <4>					DEFAULT: 1
	query->AA = 0; 		//authoritative answer.<1>			DEFAULT: ~
	query->TC = 0;		//trucated response	<1>				DEFAULT: ~
	query->RD = 1;		//recursion desired <1>				DEFAULT: 1

	query->RA = 0;		//recursion available <1>			DEFAULT: ~
	query->Z = 0;		//not used <3>						DEFAULT: 0
	query->RCODE = 0;	//response type code <4>			DEFAULT: ~

	query->QDCOUNT = 1; //question count. <16> 				DEFAULT: 1
	query->ANCOUNT = 0; //answer count. <16>				DEFAULT: 0
	query->NSCOUNT = 0; //num server authority <16> 		DEFUALT: 0
	query->ARCOUNT = 0; //num server additional <16>		DEFAULT: 0

	//-------- QUESTION VARS --------
	strcpy(query->QNAME,name); 	//host name from input	
	query->QTYPE = 1;			//query type. <16> 			DEFAULT: 1
	query->QCLASS = 1;			//query class. <16>			DEFAULT: 1 	

	((int16_t*)message)[0]=htons(query->ID);
	((int16_t*)message)[1]=htons(query->ID);//35072
	((int16_t*)message)[2]=htons(query->ID);
	((int16_t*)message)[3]=htons(query->ID);
	((int16_t*)message)[4]=htons(query->ID);


	//------------------------ SEND QUERY ------------------------
	char* response;
	response = sendMSG(svr,port,message,10);
	printf("%s\n",response);

	return 0;
}
