#define _GNU_SOURCE
#define MAXARRSIZE 1000000
	//1 million

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <stdint.h>

//----------------------SETUP----------------------
void __attribute__ ((constructor)) shim_init(void);
void __attribute__ ((destructor)) cleanup(void);

// set up struct and array to manage all the mallocs...
struct memBlock
{
    long addr;
    int size;
};

//----------------------GLOBALS----------------------
struct memBlock mallocs[MAXARRSIZE];
int totalCount = 0;
int leakCount = 0;
int totalLeakSize = 0;

//set up function pointer to original_functions
//null for now... returns a void pointer
void* (*original_malloc)(size_t size) = NULL;
void (*original_free)(void* ptr) = NULL;

//----------------------SETUP/CLEANUP FUNCTIONS----------------------

//set up function pointers 
void shim_init(void) {
	if (original_malloc == NULL) {
  		original_malloc = dlsym(RTLD_NEXT, "malloc");
  	}
  	if (original_free == NULL) {
  		original_free = dlsym(RTLD_NEXT, "free");
  	}
//  printf("initializing library.\n");
}

//runs and checks to see how many have been freed before printing out. 
//if size = -1, freed.
void cleanup(void){
	//figure out how many leaks and print
	int i;
	for(i=0;i<totalCount;i++){
		if(mallocs[i].size > 0){
			leakCount++;
			totalLeakSize += mallocs[i].size;
			fprintf(stderr,"LEAK\t%d\n",mallocs[i].size);
		}
	}
	fprintf(stderr,"TOTAL\t%d\t%d\n",leakCount,totalLeakSize);
}

//----------------------SHIMMED FUNCTIONS----------------------

//adds malloc size and address to array.
void *malloc(size_t size){
	void* returnPtr = original_malloc(size);
	mallocs[totalCount].addr = (long)returnPtr;
	mallocs[totalCount].size = size;
	totalCount++;
	
	return returnPtr;
}

void free(void *ptr){
	//lookup and change size of malloc to -1 in mallocs array.
	int i;
	for(i=0;i<totalCount;i++){
		if(mallocs[i].addr == (long)ptr){
			mallocs[i].size = -1;
		}
	}
	
	original_free(ptr);
}
