/****************************************************************************
* JACKSON DAWKINS
* CPSC 3620 - ASG 5
* DESCRIPTION:  Given a dir, count words of all data_x.csv files
******************************************************************************/

#include "mpi.h"
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#define array_size 100

int countWords(char* inString, MPI_Offset len);
void ErrorMessage(int error, int rank, char* string);

int main(int argc, char **argv)
{
    int rank, size; //mpi vars
    MPI_File infile; //file handler
    MPI_Status status;
    double start, stop; //timing vars
    int i;
    char *fileBuffer; //array to read file into.
    int error;
    char *filename = malloc(100);
    long long int totalWords = 0; //total count of words

    // initialize MPI
    MPI_Init(&argc, &argv);
    start = MPI_Wtime();
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    //open 10 data files
    for(i=0;i<10;i++){
    	//set filename
        sprintf(filename,"%s/data_%d.csv",argv[1],i);

        //open file
        error = MPI_File_open(MPI_COMM_WORLD, filename, MPI_MODE_RDONLY, MPI_INFO_NULL, &infile);
        if (error != MPI_SUCCESS) ErrorMessage(error, rank, "MPI_File_open");
        
		//get filesize
        MPI_Offset fileSize; //TYPE: lld
    	MPI_File_get_size(infile,&fileSize);
        
        //how much each process will be responsible for
		MPI_Offset blockSize = fileSize/size;
        
        //divide each processes block up into smaller parts
        //to prevent over-malloc and segfault
		int j;
		for(j=0;j<4;j++){ 
			//set array size to blocksize / 4
	        fileBuffer = malloc(blockSize/4);
	        
			//seek to correct position in file
	        MPI_File_seek(infile, rank*blockSize + (j*(blockSize/4)), MPI_SEEK_SET);
	        
			//read infile portion
	        MPI_File_read(infile, &fileBuffer[0], blockSize/4, MPI_CHAR, &status);
			
	        //count words and increment total
	        totalWords += countWords(fileBuffer,blockSize/4);

	        //free up used memory
	        free(fileBuffer);
		}

		//printf("log8\n");
        // close file
        MPI_File_close(&infile);

		//printf("log9\n");
    }//end for
    //printf("total words (rank %d): %lld\n", rank, totalWords);

    //MPI_Gather(&totalWords, 1, MPI_INT, &totalWords, 1, MPI_INT, 0, MPI_COMM_WORLD);
    long long int globalTotalWords;
    MPI_Reduce(&totalWords, &globalTotalWords, 1, MPI_LONG_LONG_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    
	// finalize MPI
    stop = MPI_Wtime();

    if(rank == 0){
    	printf("NUM NODES:  %d\n",size);
        printf("WORD COUNT: %lld\n",globalTotalWords);
        printf("TOTAL TIME: %lf\n\n",stop-start);    
    }
    MPI_Finalize();

    return 0;
}

int countWords(char* inString, MPI_Offset len){
    //int len = strlen(inString);
    int wordCount = 0;
    int i;

    //set index to beginning of first word
	//printf("log11\n");
    for(i=0;i<len;i++){
        if (inString[i] == ' ' || inString[i] == '.' || inString[i] == ','){
            //do nothing. Just advance
        } else {
            if (i==0) wordCount++;
            break;
        }
    }
	//printf("log12\n");
    for(;i<len;i++){
        if (inString[i] != ' ' && inString[i] != '.' && inString[i] != ','){
            //stp[i] is a valid word char.
            //if the former char is a spacer, new word.
            if(inString[i-1] == ' ' || inString[i-1] == '.' || inString[i-1] == ','){
                wordCount++;
            }
        }
    }

    //to account for words broken up across chunks.
    //if last char is part of a word, we assume a word was broken
    if (inString[len-1] != ' ' && inString[len-1] != '.' && inString[len-1] != ',') wordCount--;

	//printf("log13\n");
    return wordCount;
	//printf("log14\n");
}

void ErrorMessage(int error, int rank, char* string) {
  fprintf(stderr, "Process %d: Error %d in %s\n", rank, error, string);
  MPI_Finalize();
  exit(0);
}
