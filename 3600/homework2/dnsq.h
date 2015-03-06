#include <stdio.h>
#include <time.h> //rand()
#include <stdlib.h>
#include <stdint.h>
#include <string.h> //strtok() 
#include <netinet/in.h>
#include <assert.h>

//max number of unique DNS request IDs to be used
#define MAXID 30000

void hostToDNS(unsigned char* dns,unsigned char* host);
u_char* ReadName(unsigned char* reader,unsigned char* buffer,int* count);
u_char* readname(unsigned char* reader,unsigned char* buffer,int* count);

struct DNS_HEAD { 		// <bit len> 
	uint16_t ID;		//unique ID <16>					DEFAULT: ~			
	unsigned char RD :1;		//recursion desired <1>			DEFAULT: 1	
	unsigned char TC :1;		//trucated response	<1>			DEFAULT: ~
	unsigned char AA :1;		//authoritative answer.<1>		DEFAULT: ~
	unsigned char OPCODE :4;	//type of query <4>				DEFAULT: 0
	unsigned char QR :1;		//query or message <1>			DEFAULT: 0	
	unsigned char RCODE :4;	//response type code <4>		DEFAULT: ~
	unsigned char Z :3;		//not used <3>					DEFAULT: 0	
	unsigned char RA :1;		//recursion available <1>		DEFAULT: ~
	uint16_t QDCOUNT;	//question count. <16> 				DEFAULT: 1
	uint16_t ANCOUNT; 	//answer count. <16>				DEFAULT: 0
	uint16_t NSCOUNT; 	//num server authority <16> 		DEFUALT: 0
	uint16_t ARCOUNT; 	//num server additional <16>		DEFAULT: 0
};

struct DNS_QUESTION {
	//unsigned char *NAME;
	uint16_t QTYPE;		//query type.		DEFAULT: 1
	uint16_t QCLASS;	//query class.		DEFAULT: 1
};

struct R_DATA
{
    unsigned short type;
    unsigned short _class;
    unsigned int ttl;
    unsigned short data_len;
};

struct RES_RECORD
{
    unsigned char *name;
    struct R_DATA *resource;
    unsigned char *rdata;
};
 
//Structure of a Query
typedef struct
{
    unsigned char *name;
    struct QUESTION *ques;
} QUERY;
