#include "allocator.h"
#include <stdlib.h>
#include <string.h>

#include <stdio.h>

int main(){
	int *test1 = malloc(sizeof(int)); 
	*test1 = 5;

	return 0;
}
