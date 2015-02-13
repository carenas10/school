#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdbool.h>

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

return 0;
}
