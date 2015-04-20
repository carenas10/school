#include <stdio.h> 
#include <stdlib.h> //for exit()
#include <fcntl.h>	//for open()
#include <assert.h>
#include <string.h>

#include <sys/types.h> //for stat() and mkdir
#include <sys/stat.h>
#include <unistd.h>

#define FAT1LOC 512		//absolute location of the first FAT table
#define FAT2LOC 5120	//absolute location of the second FAT table
#define ROOTLOC 9728	//absolute location of root directory
#define C2LOC 	16896	//absolute location of Cluster 2
#define CSIZE	512 	//size of each cluster (B)

#define DEBUG 1

typedef struct twoFatEntries twoFatEntries;
struct twoFatEntries {
	char a;
	unsigned int b : 4;
	unsigned int c : 4;
	char d;
};

typedef struct fatCluster fatCluster;
struct fatCluster {
	char cluster[512];
};

void readDirectory(char *image, int offset);
int locationOfCluster(int cluster);
void prepend(char* str, const char* toPrepend);
int entryIsDirectory(char *entry);
unsigned int readFAT(char *input, int pos);
int startsWith(const char *str, const char *pre);

char *image;

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
	//get image size
	struct stat fileStat;
	fstat(fd, &fileStat);
	int fileSize = fileStat.st_size;

	//allocate space for array.
	image = malloc(fileSize);
	if(DEBUG) printf("FILESIZE: %d\n",fileSize);

	//read file to array
	if(read(fd, image, fileSize) == fileSize){
		if(DEBUG) printf("FILE READ GOOD!\n");
	}

	//------------------------ READ ROOT FOLDER ------------------------
	readDirectory(image,ROOTLOC);

	//if(DEBUG) printf();
	return 0;
}

//offset is to cluster start
void readDirectory(char *image, int offset){
	int i=0;
	int loc = offset;
	for(;i<15;i++, loc += 32){
		printf("%d: %d\t",loc, image[loc]);
		//check for parent and this directory. Dont enter. Will infinite loop.
		if(image[loc] == '.'){
			if(DEBUG) printf("\tPARENT/SELF\n");
			continue;
		} else if(image[loc] == 0){
			if(DEBUG) printf("\tBLANK\n");
			continue;
		} else if (image[loc] < 0){
			if(DEBUG) printf("\tDELETED\n");
			//output file
		} else if(entryIsDirectory(image + loc)){
			if(DEBUG) printf("\tDIRECTORY\n");
			//readDirectory(&image[locationOfCluster(/* CLUSTER NUM */)]);
		} else {
			if(DEBUG) printf("\tFILE\n");
			//output file
		}
	}//for
}

int entryIsDirectory(char *entry){
	char attributes = *(entry + 11);
	if(((unsigned int)attributes & 0x10) == 16) return 1;
	else return 0;
}

//given 3B, returns fat number in pos 0 or 1.
unsigned int readFAT(char *input, int pos){
	twoFatEntries *entry = (twoFatEntries *)input;
	if (pos == 0) return ((entry->b << 8) | (unsigned int)entry->a); //want left 
	else return ((((unsigned int)entry->d) << 4) | entry->c); //want right
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

//checks if str starts with pre
int startsWith(const char *str, const char *pre) {
   if(strncmp(str, pre, strlen(pre)) == 0) return 1;
   return 0;
}

int locationOfCluster(int cluster){
	return ((33 + cluster - 2)*CSIZE);
}

