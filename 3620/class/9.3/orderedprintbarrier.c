#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]){
 	int i, rank, size;
	MPI_Init(&argc, &argv);
  	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  	MPI_Comm_size(MPI_COMM_WORLD, &size);
  
	for (i = 0; i < size; i++){
		MPI_Barrier(MPI_COMM_WORLD);
    	if (rank == i) {
      		FILE *f = fopen("output.txt","a+");
      		fprintf(f,"Record of employee %d\n", rank);
      		fclose(f);
    	}
  		//MPI_Barrier(MPI_COMM_WORLD);
  	}

  	MPI_Finalize();
  	return 0;
}

