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
	char name[256];
		strcpy(name,argv[argc-1]);

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
	if(timeout == retries && port == retries){}


	//------------------------ FORM QUERY ------------------------
	struct DNS_HEAD *query = NULL;
	struct DNS_QUESTION *question = NULL;

	char message[10000];
	char *rcvBuffer;
	int messageLen = 0;
	unsigned char *qname;//*scan;

	//-------- Set Up Header --------
	srand(time(NULL)); //only call once. 
	int ID = rand() % MAXID;

	query = (struct DNS_HEAD *)&message;
	query->ID = htons(ID); 	//TEMP for testing -- printout: 'HI' ascii	
	
	query->QR = 0; 		//query or message <1>				DEFAULT: 0	
	query->OPCODE = 0;	//type of query <4>					DEFAULT: 0
	query->AA = 0; 		//authoritative answer.<1>			DEFAULT: ~
	query->TC = 0;		//trucated response	<1>				DEFAULT: ~
	query->RD = 1;		//recursion desired <1>				DEFAULT: 1

	query->RA = 0;		//recursion available <1>			DEFAULT: ~
	query->Z = 0;		//not used <3>						DEFAULT: 0
	query->RCODE = 0;	//response type code <4>			DEFAULT: ~

	query->QDCOUNT = htons(1); //question count. <16> 		DEFAULT: 1
	query->ANCOUNT = 0; //answer count. <16>				DEFAULT: 0
	query->NSCOUNT = 0; //num server authority <16> 		DEFUALT: 0
	query->ARCOUNT = 0; //num server additional <16>		DEFAULT: 0

	//-------- Set Up Question --------
	qname =(unsigned char*)&message[sizeof(struct DNS_HEAD)];
	hostToDNS(qname,(unsigned char*)name);

	question = (struct DNS_QUESTION*)&message[sizeof(struct DNS_HEAD)+(strlen((const char*)qname)+1)];
	question->QTYPE = htons(1);		//Question type			DEFAULT: 1
	question->QCLASS = htons(1);	//Question class		DEAFULT: 1

	//-------- Send Message --------
	printf("%s\n",message);
	messageLen = sizeof(struct DNS_HEAD) + (strlen((const char*)qname)+1) + sizeof(struct DNS_QUESTION);
	rcvBuffer = sendMSG(svr,port,message,messageLen);
	printf("%s\n",rcvBuffer);

	//-------- --------


	return 0;
}

//change www.google.com to 3www6google3com0 format
void hostToDNS(unsigned char* dns,unsigned char* host) 
{
    int j = 0 , i;  
    strcat((char*)host,".");

    for(i = 0 ; i < strlen((char*)host) ; i++) {
        if(host[i]=='.') {
            *dns++ = i-j; //label len
            for(;j<i;j++) {
                *dns++=host[j]; //fill rest of str.
            }
            j++;
        }
    }
    *dns++='\0';
}//hostToDNS



