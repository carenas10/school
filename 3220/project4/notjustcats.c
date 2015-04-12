#include <stdio.h> 
#include <stdlib.h> //for exit()
#include <fcntl.h>	//for open()
#include <assert.h>
#include <string.h>

#include <sys/types.h> //for stat() and mkdir
#include <sys/stat.h>
#include <unistd.h>

#define DEBUG 1

void prepend(char* str, const char* toPrepend);

int main(int argc, char *argv[]){
	//------------------------ PARSE INPUT ------------------------
	//check number of args
	if (argc != 3){
		printf("Usage: %s <Image Name> <Output Directory>\n",argv[0]);
		exit(0);
	}

	char *imgName = malloc(128);	//input image 
		strcpy(imgName,argv[1]);
	char *outputDir = malloc(128);	//where we store the files on the disk
		strcpy(outputDir,argv[2]);

	if(DEBUG) printf("IMAGE: %s\n",imgName);
	if(DEBUG) printf("OUTPUT: %s\n",outputDir);

	//------------------------ OPEN IMG ------------------------
	int fd = open(argv[1], 
			O_RDWR | O_CREAT, 
			S_IRWXU | S_IRWXG); //give user, grp all privileges

	assert(fd != -1); //make sure file is open.
	if(DEBUG) printf("Image is open with FD: %d\n",fd);

	//------------------------ DIRECTORY ------------------------	
	//check for . at beginning of dir
	if(outputDir[0] != '.') prepend(outputDir,".");

	struct stat st = {0};
	if (stat(outputDir, &st) == -1) {
	    mkdir(outputDir, 0700);
	    if(DEBUG) printf("MKDIR: %s\n",outputDir);
	} else if(DEBUG) printf("%s ALREADY EXISTS.\n",outputDir);

	//------------------------ SET UP ARRAY ------------------------





	//if(DEBUG) printf();
	return 0;
}

//Prepends toPrepend onto str. str must have enough space for toPrepend.
void prepend(char* str, const char* toPrepend) {
    size_t len = strlen(toPrepend);
    size_t i;

    memmove(str + len, str, strlen(str) + 1);

    for (i = 0; i < len; ++i) {
        str[i] = toPrepend[i];
    }
}
