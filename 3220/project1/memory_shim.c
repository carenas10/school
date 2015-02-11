#define _GNU_SOURCE

void __attribute__ ((constructor)) shim_init(void);
void __attribute__ ((destructor)) cleanup(void);

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <stdint.h>

//set up function pointer to original_functions
//null for now... returns a void pointer
void* (*original_malloc)(size_t size) = NULL;
void (*original_free)(void* ptr) = NULL;

long buffer[256];
int count = 1;

void cleanup(void){
	FILE *file;
	file = fopen("log.txt","w");
	buffer[0] = count - 1;
	fwrite(buffer,sizeof(int),256,file);
	fclose(file);
}

//set up function pointers 
void shim_init(void) {
	if (original_malloc == NULL) {
  		original_malloc = dlsym(RTLD_NEXT, "malloc");
  	}
  	if (original_free == NULL) {
  		original_free = dlsym(RTLD_NEXT, "free");
  	}
  printf("initializing library.\n");
}

void *malloc(size_t size){
	void* returnPtr = original_malloc(size);
	buffer[count] = (long)returnPtr;
	count++;
	buffer[count] = size;
	count++;
	return returnPtr;
}

void free(void *ptr){
	buffer[count] = (long) ptr;
	count++;
	buffer[count] = -1;
	count++;
	original_free(ptr);
}