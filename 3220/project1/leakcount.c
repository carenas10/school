#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdbool.h>

long readBuffer[256];

int main(int argc, char *argv[]){

//	int leakCount = 0;
//	int leakSize = 0;

    //check cmd line args
    if(argc != 2){
        printf("Usage: %s <command>",argv[0]);
        exit(1);
    }

    char* preload[] = {"LD_PRELOAD=./memory_shim.so",NULL};
    char* args[argc];	//args for execve

    int i;
    for (i=0;i<argc;i++){
    	args[i] = argv[i+1];
    }

    int childID; //track process ID.
    childID = fork();

    //run arg program with preloaded shim. 
    if (childID == 0){ //child
    	if(execve(argv[1], args, preload) < 0){
    		printf("Error running execve!\n");

    		exit(1);
    	}
    	//NOTE: Nothing after execve runs. Replaces process.
    } else { //parent
    	waitpid(childID, NULL, 0); //waits for child to finish
    //	file = fopen("log.txt","r"); //open logfile
    //	fread(readBuffer, sizeof(int), 256, file);
    }
/*
    //Prepare to analyze readBuffer
    long size = readBuffer[0];
    bool released;
    int j;

    //search thru readBuffer.
    //for each address (odd places), check to see if realeased by looking for
    //-1 values in the size block adjacent (even places)
    for(i=1;i<size-1;i+=2){

   		//check for a release of readBuffer[i] if readBuffer[i] not zero (cleared)
   		//if (readBuffer[i] != 0){
   			released = false;	
	    	for (j=1;j<size-1;j+=2){
	    		if(readBuffer[j] == readBuffer[i] && readBuffer[j+1] == -1){
	    			released = true;
	    		}
	    	}//for
   		//}//if

   		//if readBuffer[i] not released...
   		//add the size of the unreleased memory to size and increment counter
   		if (!released){
   			leakCount++;
   			leakSize += readBuffer[i+1];
   			printf("LEAK\t%lu\n",readBuffer[i+1]);
   		}
    }

    //readBuffer has been analyzed.
    fprintf(stderr, "TOTAL\t%d\t%d\n", leakCount, leakSize);
*/
return 0;
}
