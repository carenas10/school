#include <sys/ptrace.h>
#include <sys/reg.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdbool.h>

int main(int argc, char **argv, char **envp) {
    char* args[256];
    char* inputString;
    int i=0;

    char* syscalls = malloc(sizeof(int) * 326); //keeps track of all system calls individually

	//parse input string elements into individual args
    inputString = strtok(argv[1], " "); //break on spaces
	while (inputString != NULL) {
		args[i] = inputString;
		//printf("%s\n", inputString);
		i++;
		inputString = strtok(NULL, " ");
	}
	//args[i+1] = NULL;

    pid_t child = fork();

    if (child == 0) {
        
        ptrace(PTRACE_TRACEME); //allow tracing

        kill(getpid(),SIGSTOP); //prepare parent to trace
		child = getpid();
        
        //trace another program using execve. if returns < 0, there was an error.
        printf("%s %s %s\n",args[0],args[1],args[2]);
        //printf("%s\n",args[1]);
        //printf("%s\n",args[2]);
        
        if (execlp(args[0], *args, NULL) < 0){
        	printf("exec error!\n");
        }


    } else { //parent
    	printf("PARENT RUN\n");
        int status,syscall_num;
        bool called = false;

        //this option makes it easier to distinguish normal traps from
        //system calls
        ptrace(PTRACE_SETOPTIONS, child, 0, PTRACE_O_TRACESYSGOOD);

		while (1) {
			ptrace(PTRACE_SYSCALL, child, NULL, NULL);
			waitpid(child, &status, 0);
			if(WIFEXITED(status))
            	exit(1); //child exited. 
			syscall_num = ptrace(PTRACE_PEEKUSER, child, sizeof(long)*ORIG_RAX, NULL);
			if (!called) {
				called = true;
			}
			else {
				syscalls[syscall_num]++;
				called = false;
			}
		}//while

		for (i = 0; i < 326; ++i) {
			if (syscalls[i] != 0) {
				printf("%d\t%d\n", i, syscalls[i]);
			}
		}

    }//else 

    return 0;
}//main


