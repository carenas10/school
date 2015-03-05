#include <stdio.h>
#include <time.h> //rand()
#include <stdlib.h>
#include <stdint.h>
#include <string.h> //strtok() 
#include <netinet/in.h>
#include <assert.h>

//max number of unique DNS request IDs to be used
#define MAXID 30000

struct DNS_HEAD { // <bit len> 
	//------------------------ HEADER ------------------------
	uint16_t ID;		//unique ID <16>					DEFAULT: ~			
	unsigned char QR;				//query or message <1>				DEFAULT: 1	
	unsigned char OPCODE;			//type of query <4>					DEFAULT: 1
	unsigned char AA;				//authoritative answer.<1>			DEFAULT: ~
	unsigned char TC;				//trucated response	<1>				DEFAULT: ~
	unsigned char RD;				//recursion desired <1>				DEFAULT: 1
	unsigned char RA;				//recursion available <1>			DEFAULT: ~
	unsigned char Z;				//not used <3>						DEFAULT: 0
	unsigned char RCODE;			//response type code <4>			DEFAULT: ~
	uint16_t QDCOUNT;	//question count. <16> 				DEFAULT: 1
	uint16_t ANCOUNT; 	//answer count. <16>				DEFAULT: 0
	uint16_t NSCOUNT; 	//num server authority <16> 		DEFUALT: 0
	uint16_t ARCOUNT; 	//num server additional <16>		DEFAULT: 0
};
