#include <stdio.h> 
#include <stdlib.h> //for exit()
#include <fcntl.h>	//for open()
#include <assert.h>
#include <string.h>
#include <stdint.h> //for uint32
#include <sys/mman.h> //for mmap
#include <unistd.h>  //for access

#include <sys/types.h> //for stat() and mkdir
#include <sys/stat.h>
#include <unistd.h>

#define FAT1LOC 512		//absolute location of the first FAT table
#define FAT2LOC 5120	//absolute location of the second FAT table
#define ROOTLOC 9728	//absolute location of root directory
#define CSIZE	512 	//size of each cluster (B)

#define DEBUG 0

void readDirectory(char *image, int offset, char *currPath);
int locationOfCluster(int cluster);
void prepend(char* str, const char* toPrepend);
int entryIsDirectory(char *entry);
uint16_t readFat(uint16_t fatIndex);
int startsWith(const char *str, const char *pre);
void processFile(uint16_t firstCluster, uint32_t fileSize, char *ext);
char* getName(char *dirEntry);

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

	//------------------------ OPEN FILE ------------------------
	int fd = open(argv[1], O_RDONLY); //open image, read only.
		assert(fd != -1); //make sure file is open.	
		if(DEBUG) printf("Image is open with FD: %d\n",fd);

	//------------------------ SET UP ARRAY ------------------------
	//get image size
	struct stat fileStat;
	fstat(fd, &fileStat);
	int fileSize = fileStat.st_size;
	if(DEBUG) printf("FILESIZE: %d\n",fileSize);

	// mmap the space for the image from the opened image
	image = mmap(NULL, fileSize, PROT_READ, MAP_PRIVATE, fd, 0); 
	if(DEBUG) printf("FILE READ GOOD!\n");


	//------------------------ SET UP DIRECTORY ------------------------	
	//check for . at beginning of dir
	if(outputDir[0] != '.') prepend(outputDir,".");

	struct stat st = {0};
	if (stat(outputDir, &st) == -1) { //doesn't exist
	    mkdir(outputDir, 0700); //make the outut directory
	    chdir(outputDir); // Change to desired output directory
	    if(DEBUG) printf("MKDIR: %s\n",outputDir);
	} else {
		if(DEBUG) printf("%s ALREADY EXISTS.\n",outputDir);
		chdir(outputDir); // Change to desired output directory
	}

	//------------------------ READ ROOT FOLDER ------------------------
	fileIndex = 0;
	readDirectory(image,ROOTLOC,"/");

	return 0;
}


//------------------------ MAJOR FUNCTIONS ------------------------

//offset is to cluster start
//recursively checks directories until a '\n' is found, then breaks using "finished"
void readDirectory(char *image, int offset, char *currPath){
	int i=0;
	int loc = offset;
	int finished = 0;


	for(;!finished && i<15;i++, loc += 32){
		if(DEBUG) printf("%d: %d\t",loc, image[loc]);
		//check for parent and this directory. Dont enter. Will infinite loop.
		if(image[loc] == '.'){
			if(DEBUG) printf("\tPARENT/SELF\n");
			continue;
		} else if(image[loc] == 0){
			finished = 1;
			continue;
		} else if (image[loc] < 0){
			//find first fat & filesize
			uint16_t firstFat = *(image + loc + 26);
			int fileSize = *((int*)(image + loc + 28));

			//get extension
			char ext[4];
			strncpy(ext, (image + loc + 8), 3);
			//ext[3] = '\0';

			//get file path
			char *filePath = malloc(256);
			strcat(filePath, currPath);
			if (strcmp(currPath,"/") != 0) strcat(filePath,"/");
			strcat(filePath, getName(image + loc));
			strcat(filePath,".");
			strcat(filePath, ext);

			processFile(firstFat,fileSize,ext);
	
			if(filePath[strlen(filePath)-1] < 32) {
				if(DEBUG) printf("WRONG LAST\n");				
				filePath[strlen(filePath)-1] = '\0';
			}			
			printf("FILE\tDELETED\t%s\t%d\n",filePath,fileSize);
		} else if(entryIsDirectory(image + loc)){
			if(DEBUG) printf("\tDIRECTORY\n");
			uint16_t clusterNum = *(image + loc + 26);
			
			//determine next deepest path using current + next deepest
			char *nextPath = malloc(256);
			strcat(nextPath,currPath);
			strcat(nextPath,getName(image + loc));
			
			readDirectory(image, locationOfCluster(clusterNum), nextPath);
		} else {
			//find first fat & filesize
			uint16_t firstFat = *(image + loc + 26);
			int fileSize = *((int*)(image + loc + 28));

			//get extension
			char ext[4];
			strncpy(ext, (image + loc + 8), 3);

			//get file path
			char *filePath = malloc(128);
			strcat(filePath, currPath);
			if (strcmp(currPath,"/") != 0) strcat(filePath,"/");
			strcat(filePath, getName(image + loc));
			strcat(filePath,".");
			strcat(filePath,ext);

			processFile(firstFat,fileSize,ext);
			
			if(filePath[strlen(filePath)-1] < 32) {
				if(DEBUG) printf("WRONG LAST\n");				
				filePath[strlen(filePath)-1] = '\0';
			}
			
			printf("FILE\tNORMAL\t%s\t%d\n",filePath,fileSize);
		}
	}//for
}


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
	ext[3] = '\0';
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

		if(currentFat < 0xff0){ //not end of file
			currentSector = image + locationOfCluster(currentFat);
		}
	}
}

//------------------------ HELPER FUNCTIONS ------------------------

//takes an index in the FAT table, and returns value at that index.
uint16_t readFat(uint16_t index)
{
	uint16_t retFat = 0;
	
	unsigned char *mystery = (unsigned char*)(image + FAT1LOC + ((index/2)*3));

	unsigned char middle = mystery[1];
	middle >>= (4*(index%2));
	unsigned char other = mystery[(index%2)*2];
	retFat = (uint16_t)middle;
	
	retFat &= 0x000f;
	retFat <<= 8*((index%2)%1);
	other <<= 4*(index%2);
	
	retFat |= other;

	return retFat;
}

//finds the location of a cluster, based on its ID
int locationOfCluster(int cluster){
	return ((33 + cluster - 2)*CSIZE);
}


//checks a directory entry to see if it points to another directory.
int entryIsDirectory(char *entry){
	char attributes = *(entry + 11);
	if(((unsigned int)attributes & 0x10) == 16) return 1;
	else return 0;
}


//takes a directory entry and returns a name
//doesn't matter if deleted or not
char* getName(char *dirEntry){
	char *name = malloc(9);
	name[8] = '\n';
	strncpy(name,dirEntry, 8);
	char *spaceLoc = strchr(name, ' '); //find location of first space
	if(spaceLoc != NULL) *spaceLoc = '\0'; //swap for \n
	if (name[0] < 0) name[0] = '_'; //fix deleted filenames
	return name;
}


//------------------------ STRING OPS ------------------------

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

