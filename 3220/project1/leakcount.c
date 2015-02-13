#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdbool.h>

int main(int argc, char *argv[]){

    //check cmd line args
    if(argc != 2){
        printf("Usage: %s <command>\n",argv[0]);
        exit(1);
    }

    //prepare for execve by specifying preload variable
    char* preload[] = {"LD_PRELOAD=./memory_shim.so",NULL};
    char* args[argc];	//args for execve

    //shift args for exec
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
    }

return 0;
}
