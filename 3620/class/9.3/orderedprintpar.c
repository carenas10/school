#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]){
  	int i, rank, size;
  	//size = 4;
  	MPI_Init(&argc, &argv);
  	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  	MPI_Comm_size(MPI_COMM_WORLD, &size);

	for (i = 0; i < size; i++){
		if(rank == i){
			FILE *f = fopen("output.txt","a+");
			fprintf(f,"Record of employee %d\n",i);
			fclose(f);
		}
  	}

  	MPI_Finalize();
  	return 0;
	}

