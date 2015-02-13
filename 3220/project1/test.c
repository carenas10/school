#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
	int *cat = malloc(sizeof(int));
	long *dog = malloc(sizeof(long));
	*cat = 5;
	*dog = 4389048;
	//printf("About to free\n");
	//free(cat);
	free(dog);
	//printf("THIS IS A TEST!!!\n");
	
return 0;
}
