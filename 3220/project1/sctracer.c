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

    char* syscalls = malloc(sizeof(int) * 500); //keeps track of all system calls individually

    int i=0;
	for (i=0; i<500; i++){
		syscalls[i]=0;
	}

    pid_t child = fork();

    if (child == 0) {
        
        ptrace(PTRACE_TRACEME); //allow tracing

        kill(getpid(),SIGSTOP); //prepare parent to trace

        //run input file, and replace child.
        execvp(argv[1],argv);

    } else { //parent

        int status,syscall_num;

        int called = 0;

        waitpid(child,&status,0);

        //this option makes it easier to distinguish normal traps from
        //system calls
        ptrace(PTRACE_SETOPTIONS, child, 0, PTRACE_O_TRACESYSGOOD);

		do{
            //wait for a system call
            ptrace(PTRACE_SYSCALL, child, 0, 0);
            
            //actually wait for child status to change
            waitpid(child, &status, 0);

            if (WIFEXITED(status)) {
                //the child exited. Break loop.
                break;
            }

            syscall_num = ptrace(PTRACE_PEEKUSER, child, sizeof(long)*ORIG_RAX, NULL);
            if (called == 0) {
				called = 1;
			}
			else {
				syscalls[syscall_num]++;
				called = 0;
			}
        }while(1);

        //Time to write to file given by argv[2]
        FILE *file = fopen(argv[2],"w");
        if (file == NULL) {
        	printf("Error opening file!\n");
        	exit(1);
		}

		for (i = 0; i < 500; ++i) {
			if (syscalls[i] != 0) {
				fprintf(file,"%d\t%d\n", i, syscalls[i]);
			}
		}

		fclose(file);
    }//else 

    return 0;
}//main


