#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>

#define FIFO_FILE "LEAKFIFO"

int buffer[100];

bool wasFreed(int addr, int size) {
	int i;
	for (i = 1; i < size-1; i += 2) {
		if (buffer[i] == addr && buffer[i+1] == -1) {
			buffer[i] = 0;
			return true;
		}
	}
	return false;
}

int main (int argc, char *argv[]) {

	FILE* fp;
	int j;
	char *newargs[argc];

	for (j = 0; j < argc; ++j) {
		newargs[j] = argv[j+1];
	}

	int childpid;
	char *envp[] = {"LD_PRELOAD=./memory_shim.so", NULL};
	
	childpid = fork();

	if (childpid == 0) {
		int exc = execve(argv[1], newargs, envp);
		if ( exc < 0 ) {
			printf("Exec error\n");
			exit(1);
		}
	}
	else {
		waitpid(childpid, NULL, 0);
		fp = fopen("resource.txt", "r");
		fread(buffer, sizeof(int), 100, fp);
		//fclose(fp);
	}

	int i;
	int size = buffer[0];
	int leaknum = 0;
	int leaksize = 0;



	for (i = 1; i < size-1; i += 2) {
		if (!wasFreed(buffer[i], size)) {
			fprintf(stderr,"LEAK\t%d\n", buffer[i+1]);
			leaknum++;
			leaksize += buffer[i+1];
		}
	}

	fprintf(stderr, "TOTAL\t%d\t%d\n", leaknum, leaksize);

	system("rm resource.txt");

	return 0;
}