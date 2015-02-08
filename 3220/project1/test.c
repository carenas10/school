#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
	int *cat = malloc(sizeof(int));
	*cat = 5;
	printf("%d\n",*cat);
	
return 0;
}
