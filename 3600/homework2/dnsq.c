#include "dnsq.h"
#include "udpSend.h"

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
	struct DNS_HEAD *dns = NULL;

	char message[10000];
	unsigned char *rcvBuffer;
	int messageLen = 0;
	unsigned char *qname, *reader;

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

   int headersize = sizeof(struct DNS_HEAD);


	//-------- Set Up Question --------
	qname =(unsigned char*)&message[sizeof(struct DNS_HEAD)];
	
   	int qnamesize = strlen((const char*)qname);
	
	hostToDNS(qname,(unsigned char*)name);

	question = (struct DNS_QUESTION*)&message[sizeof(struct DNS_HEAD)+(strlen((const char*)qname)+1)];
	question->QTYPE = htons(1);		//Question type			DEFAULT: 1
	question->QCLASS = htons(1);	//Question class		DEAFULT: 1

	//-------- Send Message --------
	struct sockaddr_in addr;
	messageLen = sizeof(struct DNS_HEAD) + (strlen((const char*)qname)+1) + sizeof(struct DNS_QUESTION);
	rcvBuffer = (unsigned char*)sendMSG(svr,port,message,messageLen);

	//-------- Process Response --------
	dns = (struct DNS_HEAD *)rcvBuffer;
	struct RES_RECORD answers[20];

   	//dns = (struct DNS_HEADER*) buffer;
   	reader = &rcvBuffer[headersize + (qnamesize+1) + sizeof(struct DNS_QUESTION)];
   	int pos=0;
	int j;

   	//read response
   	for (i=0;i<ntohs(dns->ANCOUNT);i++) {
      answers[i].name=readname(reader,rcvBuffer,&pos);
      reader = reader + pos;

        answers[i].resource = (struct R_DATA*)(reader);
        reader = reader + sizeof(struct R_DATA);

        answers[i].rdata = (unsigned char*)malloc(ntohs(answers[i].resource->data_len));

        for (j=0 ; j<ntohs(answers[i].resource->data_len) ; j++) {
            answers[i].rdata[j]=reader[j];
        }

        answers[i].rdata[ntohs(answers[i].resource->data_len)] = '\0';

        reader = reader + ntohs(answers[i].resource->data_len);
    }

    //print answers
    for (i=0 ; i < ntohs(dns->ANCOUNT) ; i++) {

        long *p;
        p=(long*)answers[i].rdata;
        addr.sin_addr.s_addr=(*p);
        printf("IP\t%s\t1\tauth ",inet_ntoa(addr.sin_addr));

        if (ntohs(answers[i].resource->type)==5)
            printf("CNAME\t%s\t1\tauth",answers[i].rdata);

        printf("\n");
    }









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

//read names in from dns format
u_char* readname(unsigned char* reader,unsigned char* buffer,int* count)
{
    unsigned char *name;
    unsigned int p=0,jumped=0,offset;
    int i , j;

    *count = 1;
    name = (unsigned char*)malloc(256);

    name[0]='\0';

    while (*reader!=0) {
        if (*reader>=192) {
            offset = (*reader)*256 + *(reader+1) - 49152;
            reader = buffer + offset - 1;
            jumped = 1;
        }
        else
            name[p++]=*reader;

        reader = reader+1;

        if (jumped==0) {
            *count = *count + 1;
        }
    }

    name[p]='\0';
    if (jumped==1) {
        *count = *count + 1;
    }

    for (i=0;i<(int)strlen((const char*)name);i++) {
        p=name[i];
        for (j=0;j<(int)p;j++) {
            name[i]=name[i+1];
            i=i+1;
        }
        name[i]='.';
    }
    name[i-1]='\0';
    return name;
}
