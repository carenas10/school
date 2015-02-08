#define _GNU_SOURCE

void __attribute__ ((constructor)) malloc_init(void);

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int (*original_malloc)(void) = NULL;

//set up function pointers 
void malloc_init(void) {
  if (original_rand == NULL) {
  		original_malloc = dlsym(RTLD_NEXT, "malloc");
  	}
  printf("initializing library.\n");
}

void *malloc(size_t size){
	void* returnPtr;
	returnPtr = original_malloc(size);
	printf("malloc run\n"); 
}

//---------------------------------------------------------------------


void free(void *ptr){


}

