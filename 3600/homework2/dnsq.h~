#include <stdio.h>
#include <time.h> //rand()
#include <stdlib.h>
#include <stdint.h>
#include <string.h> //strtok() 
#include <netinet/in.h>

//max number of unique DNS request IDs to be used
#define MAXID 30000

struct DNSQ_T { // <bit len> 
	//------------------------ HEADER ------------------------
	uint16_t ID;		//unique ID <16>					DEFAULT: ~			
	int QR;				//query or message <1>				DEFAULT: 1	
	int OPCODE;			//type of query <4>					DEFAULT: 1
	int AA;				//authoritative answer.<1>			DEFAULT: ~
	int TC;				//trucated response	<1>				DEFAULT: ~
	int RD;				//recursion desired <1>				DEFAULT: 1
	int RA;				//recursion available <1>			DEFAULT: ~
	int Z;				//not used <3>						DEFAULT: 0
	int RCODE;			//response type code <4>			DEFAULT: ~
	uint16_t QDCOUNT;	//question count. <16> 				DEFAULT: 1
	uint16_t ANCOUNT; 	//answer count. <16>				DEFAULT: 0
	uint16_t NSCOUNT; 	//num server authority <16> 		DEFUALT: 0
	uint16_t ARCOUNT; 	//num server additional <16>		DEFAULT: 0
	
	//------------------------ QUESTION ------------------------
	char QNAME[255];	//host name.
	int16_t QTYPE;		//query type. <16> 					DEFAULT: 1
	int16_t QCLASS;		//query class. <16>					DEFAULT: 1 	

};
