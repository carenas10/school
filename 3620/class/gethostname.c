#include <stdio.h>
#include <sys/utsname.h> 
#include <mpi.h>

int main(int argc, char *argv[]) {
	//-------- INIT ---------
	MPI_Init(&argc, &argv);

	//-------- VARS --------
	int rank, size, i;
	int tmp = 1;
	MPI_Status status;
	int tmpBC = 10;

	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);

	struct utsname uts;
	uname (&uts);
	//printf("My process %d out of %d is on node %s.\n", rank, size, uts.nodename);
	
	if (rank == 0){
		MPI_Send(&rank, 1, MPI_INT,1,0,MPI_COMM_WORLD);
	}
	if (rank == 1){
		printf("tmp before send: %d\n",tmp);
		MPI_Recv(&tmp, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		printf("tmp after recv: %d\n",tmp);
	}

	if (rank == 0){
		for(i = 1; i < size; i++){	
			//SEQUENTIAL
			MPI_Send(&tmp, 1, MPI_INT, i, 0, MPI_COMM_WORLD);
		}
	}
	
	if(rank != 0){
		printf("tmp before send: %d\n",tmp);
		MPI_Recv(&tmp, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		printf("tmp after send: %d\n",tmp);
	}
	
	//BROADCAST
	if (rank==0){
		tmpBC = 20;
	}

	printf("tmpBC before broadcast: %d\n",tmpBC);
	MPI_Bcast(&tmpBC, 1, MPI_INT, 0, MPI_COMM_WORLD);
	printf("tmpBC after broadcast: %d\n",tmpBC);

	MPI_Finalize();
	return 0; 
}
