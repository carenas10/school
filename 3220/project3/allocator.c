#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <stdint.h>
#include <sys/mman.h>
#include <string.h>
#include <sys/types.h> //open
#include <sys/stat.h>	//open
#include <fcntl.h>		//open
//#include "allocator.h"

#define PAGESIZE 4096

//----------------------SETUP----------------------
void __attribute__ ((constructor)) shim_init(void);
void __attribute__ ((destructor)) cleanup(void);

typedef struct memBlock memBlock;
struct memBlock {
	int valid;
	memBlock *next;
	void *data;
};

typedef struct page_t page_t;
struct page_t {
	page_t *prev;
	page_t *next;
	int totalObjects;
	int blockSize;
	memBlock *data;
};

//----------------------GLOBALS----------------------

//function prototypes
page_t *newPage(page_t *prev, int size);
int pageIsFull(int totalObjects, int size);
memBlock *newBlockNode(page_t *page, int size);
page_t *newLargePage(page_t *prev, int size);

//array to hold page list heads
page_t *lists[11];

//----------------------SETUP/CLEANUP FUNCTIONS----------------------

//set up function pointers 
void shim_init(void) {
  	return;
}

//----------------------SHIMMED FUNCTIONS----------------------

/*					MALLOC:
*	Using size, determine which page to place in.
*	Create page if needed (no page in list).
*	Check if there is space in that page.
*		If space, create new memBlock and add to linked list.
*		No space, create new page.
*	If size > 1024, place in its own page on lists[10];
*/
void *malloc(size_t size){
	/*
	memBlock *newBlock = NULL;
	page_t *workingPage = NULL;	
	int blockSize = -1; //for making new pages/blocks

	if (size <= 0) return NULL;

	//determine which seg. list
	int segListNum = 0;
	if(size <= 1024){ //normal sized objects for lists[0-9]
		if(size <= 2) segListNum = 0;
		else if(size > 2 && size <= 4) segListNum = 1; //size 4 
		else if(size > 4 && size <= 8) segListNum = 2;
		else if(size > 8 && size <= 16) segListNum = 3;
		else if(size > 16 && size <= 32) segListNum = 4;
		else if(size > 32 && size <= 64) segListNum = 5;
		else if(size > 64 && size <= 128) segListNum = 6;
		else if(size > 128 && size <= 256) segListNum = 7;
		else if(size > 256 && size <= 512) segListNum = 8;
		else segListNum = 9;
		
		blockSize = 1<<(segListNum+1);

		//find which page has space. Make new one if necessary.
		//check if we need to add a page.
		workingPage = lists[segListNum]; 
		if (workingPage == NULL){
			//need to assign a first page.
			workingPage = newPage(NULL,blockSize);
			lists[segListNum] = workingPage;
		} else { //first page exists. check capacity.
			workingPage = lists[segListNum];
			while (workingPage->next && pageIsFull(workingPage->totalObjects, blockSize)){
				workingPage = workingPage->next; //keep moving.
			}
			if(pageIsFull(workingPage->totalObjects,blockSize)){
				//all pages are full. Need a new one.
				workingPage->next = newPage(workingPage,blockSize);
				workingPage = workingPage->next; //advance.
			}
		} //else

		//page should be assigned.
		newBlock = newBlockNode(workingPage,size); //pass in actual size. Not block size.

	} else { //size > 1024. placed in lists[10]
		//create page after end of curr pages in list[10] and insert into page.
		workingPage = lists[10];
		if(workingPage == NULL) {
			//need to assign a first page.
			workingPage = newLargePage(NULL,blockSize);
			lists[10] = workingPage;
		} else{
			while(workingPage->next) workingPage = workingPage->next; //advance to end.
			workingPage->next = newLargePage(workingPage,size);
			workingPage = workingPage->next;

		}//else
	} //size  > 1024 

	if(newBlock == NULL) {
		return newBlock;
	} else {
		return &newBlock->data;
	}*/
		return NULL;
} //malloc end


/*				CALLOC:
*	Acts like malloc, but with memory initialization to 0.
*	allocates nmemb block of size.
*/
void *calloc(size_t nmemb, size_t size){/*
	void *retptr;
	int totalSize = nmemb * size;
	retptr = malloc(totalSize);

	if(totalSize < 4096) memset(retptr, 0, totalSize); //init to 0. 

	return retptr;*/
	return NULL;
}


/*				REALLOC:
*	If ptr is null, acts as malloc for size
*	if size == 0 and ptr is valid, acts as free
*	if size and ptr both valid
*		calls malloc on size and memcpys to that location
*		free old ptr.
*/
void *realloc(void *ptr, size_t size){/*
	void *newLoc = ptr;
	
	if (ptr == NULL) return malloc(size);
	if (size == 0 && ptr != NULL) free(ptr);
	else if (size != 0 && ptr != NULL){
		page_t *page = (void*)((uintptr_t)ptr & ~((uintptr_t)0x00FFF));
		int currentSize = page->blockSize;
		if(size > currentSize) {
			newLoc = malloc(size);
			memcpy(newLoc, ptr, currentSize); //move to new location
			free(ptr);
		} //don't know what to do otherwise...
	}
	return newLoc;*/
	return NULL;
}

/*				FREE:
*	null ptr arg -> returns NULL.
*	identify page # by last 12 lsb in ptr.
*	mark the memory block as invalid, and decrement num objects in page.
*	DISABLED: unmap page if empty.
*/

void free(void *ptr){/*
	if(ptr == NULL) return; //nothing to free! We done!

	//for bit math fix for getting the page containing the memBlock
		//(thanks Dr. Sorber!)
	page_t *freePage = (void *) ((uintptr_t)ptr & (uintptr_t)0x00FFF);

	//change valid bit to 0 and decrement the total num objects in page.
	memBlock *curr = (memBlock *) &freePage->data;
	while(&curr->data != ptr) curr = curr->next; //iterate to find block
		curr->valid = 0;
		freePage->totalObjects--;*/
/*
	//check for empty page. If no objects, unmap & adjust list.
	if(freePage->totalObjects == 0){ //unmap
		if(freePage->prev == NULL) {//list head
			//determine which list this is head of...
			int segListNum = -1;
			if(freePage->blockSize == 2) segListNum = 0; //size 4 
			else if(freePage->blockSize == 4) segListNum = 1;
			else if(freePage->blockSize == 8) segListNum = 2;
			else if(freePage->blockSize == 16) segListNum = 3;
			else if(freePage->blockSize == 32) segListNum = 4;
			else if(freePage->blockSize == 64) segListNum = 5;
			else if(freePage->blockSize == 128) segListNum = 6;
			else if(freePage->blockSize == 256) segListNum = 7;
			else if(freePage->blockSize == 512) segListNum = 8;
			else if(freePage->blockSize == 1024) segListNum = 9;
			else segListNum = 10;

			lists[segListNum] = freePage->next; //advance
			//make sure not null so no segfault :)
			if (lists[segListNum] != NULL) lists[segListNum]->prev = NULL;
		} else if(freePage->next != NULL) { //middle of list
			freePage->prev->next = freePage->next;
			freePage->next->prev = freePage->prev;
		} else freePage->prev->next = NULL; //end of list
	
		//list management is done. Remove the page node.

		munmap(freePage,freePage->blockSize);
	}*/
		return;
}

//------------------------ CREATION ------------------------

//creates a new page node and adds itself to the end of the page list.
page_t *newPage(page_t *prev, int size){
	page_t *newPage = NULL;

	//used for initializing the memory to zero.
	int fd = open("/dev/zero", O_RDWR);
	
	//ask the OS to map a page of virtual memory initialized to zero
	newPage = mmap (NULL , PAGESIZE ,
	PROT_READ | PROT_WRITE , MAP_PRIVATE , fd, 0);

	if(newPage == (page_t *)-1) perror("MMAP FAIL");

	//set up list
	newPage->prev = prev;
	newPage->next = NULL;
	if (!(prev == NULL)) prev->next = newPage;

	//set up node
	newPage->blockSize = size;
	newPage->totalObjects = 0;

	return newPage;
} //newPageNode

page_t *newLargePage(page_t *prev, int size){
	page_t *newPage = NULL;

	//used for initializing the memory to zero.
	int fd = open("/dev/zero", O_RDWR);
	
	//ask the OS to map a page of virtual memory initialized to zero
		//ask for size + 32 to accomodate 4K objects. Would need 2 pages with this impl.
	newPage = mmap (NULL , (size + 32) ,
	PROT_READ | PROT_WRITE , MAP_PRIVATE , fd, 0);

	if(newPage == (page_t *)-1) perror("MMAP FAIL");

	//set up list
	newPage->prev = prev;
	newPage->next = NULL;
	prev->next = newPage;

	//set up node
	newPage->blockSize = size;
	newPage->totalObjects = 0;

	return newPage;
} //newPageNode


//Add new object to page.
//REQUIRES: Page have enough room. Doesn't check
memBlock *newBlockNode(page_t *page, int size){ //size is size of OBJECT. Not blockSize.
	memBlock *newBlock = NULL;
	memBlock *current = page->data; //start at beginning of page.
	memBlock *prev = NULL;

	if(current == NULL){ //need to create list.

	}


	while(current->valid){ //search list for free block.
		prev = current;
		if(current->next != NULL){
			current = current->next;
		} else current = (memBlock*)((char*)current + sizeof(memBlock) + size);
	}//while

	if(!current->valid){
		newBlock = current;
	} else newBlock = (current + (size + sizeof(memBlock *) + sizeof(int)));
	
	if(prev != NULL) {
		prev->next = newBlock;
	}
	current->valid = 1; //we're allocating this, so validate.
	page->totalObjects++;
	
	return newBlock;
} //newBlock

//------------------------ DELETION ------------------------

//------------------------ MANIPULATION / CHECKS ------------------------

//checks if a page had enough room for a object of size
int pageIsFull(int totalObjects, int size) {
	//calculate size needed for page with new obj. This only works b/c all same size.
	int requiredSize = ((totalObjects + 1) * size + 32);
	if(requiredSize > PAGESIZE) { //if size needed larger than 4096... 
		return 1;
	}
	else 
		return 0; 
} //pageIsFull

