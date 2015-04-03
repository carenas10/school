#include <stdlib.h>
#include <string.h>

#include <stdio.h>

int main(){
	//------------------------ BASIC MALLOC ------------------------
	int *test1 = malloc(sizeof(int)); 
	*test1 = 5;

	printf("Malloc Passed: %d\n",*test1);

	//------------------------ BASIC CALLOC ------------------------
	int *test2 = calloc(1,sizeof(int));
	printf("Calloc: before assigning: %d\n",*test2);
	*test2 = 10;

	printf("Calloc Passed: %d\n",*test2);

	//------------------------ FREE ------------------------
	free(test1);
	printf("Free Passed: %d\n",*test1);	
	free(test2);
	//printf("Free Passed: %d\n",*test2);	

	//------------------------ LG OBJS ------------------------
	char *test3 = malloc(1500);
	printf("passed lg malloc!\n");
	//strcpy(test3,"hello world!");
	test3[0] = 'H';
	test3[1] = 'i';
	test3[2] = 0;

	printf("string: %s\n",test3);
	free(test3);
	//printf("test3 freed: %s\n",test3);



	return 0;
}
