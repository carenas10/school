#include <stdio.h> 
#include <stdlib.h> //for exit()
#include <fcntl.h>	//for open()
#include <assert.h>
#include <string.h>
#include <stdint.h> //for uint32
#include <sys/mman.h> //for mmap

#include <sys/types.h> //for stat() and mkdir
#include <sys/stat.h>
#include <unistd.h>

#define FAT1LOC 512		//absolute location of the first FAT table
#define FAT2LOC 5120	//absolute location of the second FAT table
#define ROOTLOC 9728	//absolute location of root directory
//#define C2LOC 	16896	//absolute location of Cluster 2
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
//unsigned int readFAT(char *input, int pos);
uint16_t readFat(uint16_t fatIndex);
int startsWith(const char *str, const char *pre);
void processFile(uint16_t firstCluster, uint32_t fileSize, char *ext);

char *image;
int fileIndex;

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

	//------------------------ DIRECTORY ------------------------	
	//check for . at beginning of dir
	if(outputDir[0] != '.') prepend(outputDir,".");

	struct stat st = {0};
	if (stat(outputDir, &st) == -1) { //doesn't exist
	    mkdir(outputDir, 0700); //make the outut directory
	    chdir(outputDir); // Change to desired output directory
	    if(DEBUG) printf("MKDIR: %s\n",outputDir);
	} else if(DEBUG) printf("%s ALREADY EXISTS.\n",outputDir);

	//------------------------ SET UP ARRAY ------------------------
	int fd = open(argv[1], O_RDONLY); //open image, read only.
		assert(fd != -1); //make sure file is open.
		if(DEBUG) printf("Image is open with FD: %d\n",fd);

	//get image size
	struct stat fileStat;
	fstat(fd, &fileStat);
	int fileSize = fileStat.st_size;
	if(DEBUG) printf("FILESIZE: %d\n",fileSize);

	// mmap the space for the image from the opened image
	image = mmap(NULL, fileSize, PROT_READ, MAP_PRIVATE, fd, 0); 
	if(DEBUG) printf("FILE READ GOOD!\n");

	//------------------------ READ ROOT FOLDER ------------------------
	fileIndex = 0;
	readDirectory(image,ROOTLOC);


	return 0;
}

//offset is to cluster start
void readDirectory(char *image, int offset){
	int i=0;
	int loc = offset;
	int finished = 0;
	for(;!finished && i<15;i++, loc += 32){
		printf("%d: %d\t",loc, image[loc]);
		//check for parent and this directory. Dont enter. Will infinite loop.
		if(image[loc] == '.'){
			if(DEBUG) printf("\tPARENT/SELF\n");
			continue;
		} else if(image[loc] == 0){
			//if(DEBUG) printf("\tBLANK\n");
			finished = 1;
			continue;
		} else if (image[loc] < 0){
			if(DEBUG) printf("\tDELETED\n");
			//find first fat & filesize
			uint16_t firstFat = *(image + loc + 26);
			uint32_t fileSize = *(image + loc + 28);
			char ext[10];
			strncpy(ext, (image + loc + 8), 3);

			processFile(firstFat,fileSize,ext);
		} else if(entryIsDirectory(image + loc)){
			if(DEBUG) printf("\tDIRECTORY\n");
			uint16_t clusterNum = *(image + loc + 26);
			readDirectory(image, locationOfCluster(clusterNum));
		} else {
			if(DEBUG) printf("\tFILE\n");
			//find first fat & filesize
			uint16_t firstFat = *(image + loc + 26);
			uint32_t fileSize = *(image + loc + 28);
			char ext[10];
			strncpy(ext, (image + loc + 8), 3);

			processFile(firstFat,fileSize,ext);
		}
	}//for
}

//checks a directory entry to see if it is another directory.
int entryIsDirectory(char *entry){
	char attributes = *(entry + 11);
	if(((unsigned int)attributes & 0x10) == 16) return 1;
	else return 0;
}

//given 3B, returns fat number in pos 0 or 1.
/*
unsigned int readFAT(char *input, int pos){
	twoFatEntries *entry = (twoFatEntries *)input;
	if (pos == 0) return ((entry->b << 8) | (unsigned int)entry->a); //want left 
	else return ((((unsigned int)entry->d) << 4) | entry->c); //want right
}*/

/* ---- PROCESS FILE ----
	if filesize > 512
		while(not end of FAT chain)
			open file
			write 512 to file
		end while
	else 
		open file
		write filesize to file
	end if
*/
void processFile(uint16_t firstSector, uint32_t fileSize, char *ext){
	//get fileName
	char *fileName = malloc(128);
	sprintf(fileName, "file%d.%s", fileIndex, ext);
	fileIndex ++;
	if(DEBUG) printf("OUT FILE: %s\n",fileName);
	int remaining = fileSize;

	//open file
	FILE *newFile = fopen(fileName,"w+");
	
	//location of first sector
	uint16_t currentFat = firstSector;
	void *currentSector = image + locationOfCluster(firstSector);

	while(remaining){
		if(remaining/CSIZE){ //more than 1 sector to go
			fwrite(currentSector, sizeof(char), CSIZE, newFile);
			remaining -= CSIZE;
		} else { //last sector to read.
			fwrite(currentSector, sizeof(char), remaining, newFile);
			remaining -= remaining;
		}
		currentFat = readFat(currentFat); //find next fat location

		if(currentFat < 0xff0){
			currentSector = image + locationOfCluster(currentFat);
		}
	}



	/*
	if(fileSize > 512){

	} else { //filesize less than 512B
		fwrite((image + locationOfCluster(firstCluster)), sizeof(char), fileSize, newFile);
	}*/
}

uint16_t readFat(uint16_t index)
{
	uint16_t retFat = 0;
	
	unsigned char *toDecode = (unsigned char*)(image + FAT1LOC + ((index/2)*3));

	unsigned char middlechar = toDecode[1];
	middlechar >>= (4 * (index % 2));
	unsigned char otherhalf = toDecode[(index%2)*2];
	retFat = (uint16_t)middlechar;
	retFat &= 0x000f;
	retFat <<= 8 * ((index % 2)%1);
	otherhalf <<= 4 * (index % 2);
	retFat |= otherhalf;
	return retFat;
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

