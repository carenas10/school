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

#define PAGESIZE 4096

//----------------------SETUP----------------------
void __attribute__ ((constructor)) shim_init(void);
void __attribute__ ((destructor)) cleanup(void);

typedef struct mem_t mem_t;
struct mem_t {
	mem_t *next; 	// <8>
	void *data;		// <8>
};

typedef struct page_t page_t;
struct page_t {
	page_t *next; 	// <8>
	mem_t *freeList;// <8>
	mem_t *usedList;// <8>
	int blockSize;	// <8>
};

//----------------------GLOBALS----------------------

//function prototypes
page_t 	*newPage(page_t *prev, int size);
mem_t 	*newMemBlock(page_t *page, int size);
page_t 	*newLargePage(page_t *prev, int size);

//array to hold page list heads
page_t *lists[11];

//used for initializing the memory to zero.
int fd;

//----------------------SETUP/CLEANUP FUNCTIONS----------------------

//set up function pointers 
void shim_init(void) {
	fd = open("/dev/zero", O_RDWR);
  	return;
}

//----------------------SHIMMED FUNCTIONS----------------------

/*					MALLOC:
*	Using size, determine which page to place in.
*	Create page if needed (no page in list).
*	Check if there is space in each page. (check free list)
*		if space, remove from free list, remove old list memberships.
*		add to used list.
*		return data.
*	If size > 1024, place in its own page on lists[0];
*/
void *malloc(size_t size){
	if(size <= 0) return NULL; //spec.

	page_t *page = NULL; //to be searched.
	mem_t *memBlock = NULL; //the block where the memory will be returned from.
	int blockSize = -1; //size of memory blocks in page.

	//determine which seg. list
	int listNum = 0;
	if(size <= 1024){ //normal sized objects for lists[0-9]
		if(size <= 2) listNum = 1; 						//size 2
		else if(size > 2 && size <= 4) listNum = 2; 	//size 4 
		else if(size > 4 && size <= 8) listNum = 3;		// 8
		else if(size > 8 && size <= 16) listNum = 4;	// 16
		else if(size > 16 && size <= 32) listNum = 5;	// 32
		else if(size > 32 && size <= 64) listNum = 6;	// 64
		else if(size > 64 && size <= 128) listNum = 7;	// 128
		else if(size > 128 && size <= 256) listNum = 8;	// 256
		else if(size > 256 && size <= 512) listNum = 9;	// 512
		else listNum = 10;								// 1024
		
		blockSize = 1<<(listNum);
		
		//check list for space.
		if(lists[listNum] == NULL){ //no pages initially.
			lists[listNum] = newPage(NULL,blockSize);
			page = lists[listNum];
		} else { //pages initially present.
			page = lists[listNum];
			while(page->freeList == NULL && page->next != NULL) page = page->next; //traverse
			if (page->freeList == NULL && page->next == NULL){ //need a new page.
				page->next = newPage(page,blockSize);
				page = page->next;
			}
		}

		//page should be assigned by here. Remove from free list.
		memBlock = page->freeList;
		page->freeList = page->freeList->next; 	//it's okay if only thing in list. 
												//leaves it null 

		//add to front of used list.
		memBlock->next = page->usedList;
		page->usedList = memBlock;

		return memBlock->data;

	} else { //large elements
		//list already set to 0.
		blockSize = size;

		//check list for space.
		if(lists[listNum] == NULL){ //no pages initially.
			lists[listNum] = newLargePage(NULL,blockSize);
			page = lists[listNum];
		} else { //pages initially present.
			page = lists[listNum];
			while(page->next != NULL) page = page->next; //traverse
			//need new page every time.
			page->next = newLargePage(page,blockSize);
			page = page->next;
		}

		//page should be assigned by here. Remove from free list.
		memBlock = page->freeList;
		page->freeList = NULL;	//in large pages, there's only one object.

		//add to front of used list.
		//memBlock->next = page->usedList;
		page->usedList = memBlock;

		return memBlock->data;
	}
} //malloc end


/*				CALLOC:
*	Acts like malloc, but with memory initialization to 0.
*	allocates nmemb block of size.
*/
void *calloc(size_t nmemb, size_t size){
	void *retptr;
	int totalSize = nmemb * size;
	retptr = malloc(totalSize);

	memset(retptr, 0, totalSize); //init to 0. 

	return retptr;
}


/*				REALLOC:
*	If ptr is null, acts as malloc for size
*	if size == 0 and ptr is valid, acts as free
*	if size and ptr both valid
*		calls malloc on size and memcpys to that location
*		free old ptr.
*/
void *realloc(void *ptr, size_t size){ /*
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

void free(void *ptr){
	if(ptr == NULL) return; //nothing to free! We done!

	//for bit math fix for getting the page containing the mem_t
		//(thanks Dr. Sorber!)
	page_t *page = (page_t *)((uintptr_t)ptr & ((uintptr_t)0xFFFFFFFFFFFFF000));

	//TODO
	//check to make sure page is valid!!!

	mem_t *curr = (mem_t *) &page->usedList;
	mem_t *prev = NULL;
	while(curr->data != ptr){ //iterate to find correct block <<REMOVED & >>
		prev = curr;
		if (curr->next != NULL) curr = curr->next;
		//else curr = NULL
	} 

	//remove from used list.
	if(prev == NULL){ //front of list.
		page->usedList = curr->next;
	} else if (prev != NULL && curr->next != NULL) { //middle of list.
		prev->next = curr->next;
	} else { //end of list.
		prev->next = NULL;
	}

	//add to free list
	curr->next = page->freeList;
	page->freeList = curr;

	//set to 0 for good measure :)
	if(page->blockSize < 4096) memset(curr->data, 0, page->blockSize); //init to 0. 

	//Let's work on unmapping old pages!

	//check for empty page. If no objects, unmap & adjust list.
	if(page->usedList == NULL){ //unmap
		int listNum,isHead = 0;

		//checks if head. if it is, identifies which one.
		for (listNum=0;listNum<11;listNum++){
			if(lists[listNum] == page) isHead = 1; //is head of list i.
		}
/*
		//identify previous node if not head.
		if(!isHead){
			while(){

			}
		}
*/
		if(isHead) {//list head
			lists[listNum] = page->next; //advance
		} else if(page->next != NULL) { //middle of list
			page->prev->next = page->next;
			page->next->prev = page->prev;
		} else page->prev->next = NULL; //end of list
	
		//list management is done. Remove the page node.

		munmap(page,page->blockSize);
	}
}

//------------------------ CREATION ------------------------

//creates a new page node and adds itself to the end of the page list.
//size: size (B) of each node's data field.
page_t *newPage(page_t *prev, int size){
	page_t *newPage = NULL;
	
	//ask the OS to map a page of virtual memory initialized to zero
	newPage = mmap (NULL , PAGESIZE ,
	PROT_READ | PROT_WRITE , MAP_PRIVATE , fd, 0);

	if(newPage == (page_t *)-1) perror("MMAP FAIL"); //make sure page map works

	//set up list
	if (!(prev == NULL)) prev->next = newPage;
	newPage->next = NULL;

	//set up node
	newPage->usedList = NULL;
	newPage->blockSize = size;

	//set up free list
	int remaining = PAGESIZE - sizeof(page_t);
	int needed = sizeof(mem_t) + size;

	newPage->freeList =(mem_t*)((char *)newPage + sizeof(page_t));

	mem_t *currentBlock = newPage->freeList;
		currentBlock->data = (void*)((char*)currentBlock + sizeof(mem_t)); //set up data pointer.

	mem_t *prevBlock = currentBlock;
	
	while(remaining >= needed){
		mem_t *newBlock = NULL;
		newBlock = (mem_t*)((char*)prevBlock + sizeof(mem_t) + size);
			newBlock->data = (void*)((char*)newBlock + sizeof(mem_t)); //set up data pointer.
		prevBlock->next = newBlock;
		newBlock->next = NULL;

		remaining -= needed;
	} //free list is initialized.
	 

	return newPage;	
} //newPageNode

page_t *newLargePage(page_t *prev, int size){
	page_t *newPage = NULL;
	
	//ask the OS to map a page of virtual memory initialized to zero
	newPage = mmap (NULL , (size + 32) ,
	PROT_READ | PROT_WRITE , MAP_PRIVATE , fd, 0);

	if(newPage == (page_t *)-1) perror("MMAP FAIL"); //make sure page map works

	//set up list
	if (!(prev == NULL)) prev->next = newPage;
	newPage->next = NULL;

	//set up node
	newPage->usedList = NULL;
	newPage->blockSize = size;

	newPage->freeList =(mem_t*)((char *)newPage + sizeof(page_t));

	mem_t *currentBlock = newPage->freeList;
		currentBlock->data = (void*)((char*)currentBlock + sizeof(mem_t)); //set up data pointer.
	 
	return newPage;	

} //newLargePage


//clinecom
//------------------------ TESTS ------------------------