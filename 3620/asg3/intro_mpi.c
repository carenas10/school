#include <stdio.h>
#include <stdlib.h>
#include <sys/utsname.h> 
#include <mpi.h>

int main(int argc, char *argv[]) {
	//-------- INIT ---------
	MPI_Init(&argc, &argv);
	
	//-------- VARS --------
	int DEBUG = 1;
	int rank, size, i;
	int fromTwo = 0;
	MPI_Status status;
	int arrayZero[16];	// = {15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};

	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);

	struct utsname uts;
	uname (&uts);
	
	if (rank == 0){
		//set up random number generator
		time_t t;
		srand((unsigned) time(&t));

		//init array values
		for (i=0;i<16;i++){
			arrayZero[i] = rand();
			//printf("arrayZero[%d]: %d\n",i,arrayZero[i]);
		}

		//print out array
		printf("arrayZero:\n");
		for(i=0;i<16;i++){
			printf("\t[%d] %d\n",i,arrayZero[i]);
		}
	
		//send arrayZero[1] to process 2
		MPI_Send(&arrayZero[1], 1, MPI_INT,2,0,MPI_COMM_WORLD);
		printf("Send: %d to process with rank 2\n",arrayZero[1]);
	}

	if (rank == 2){
		MPI_Recv(&fromTwo, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		printf("fromTwo: %d recv'd from process 0. Stored in tmp\n",fromTwo);
	}	

	//broadcast received value
	MPI_Bcast(&fromTwo, 1, MPI_INT, 2, MPI_COMM_WORLD);
	printf("broadcast rcv to rank %d: %d\n",rank,fromTwo);

	//scatter from root (0)
	int fromArray[4];
	MPI_Scatter(arrayZero, 4, MPI_INT, fromArray, 4, MPI_INT, 0, MPI_COMM_WORLD);	
	printf("fromArray(rank %d) - [0] %d    [1] %d    [2] %d    [3] %d\n",rank,fromArray[0],fromArray[1],fromArray[2],fromArray[3]);

	//reduce values
	int  *maxFromReduce = malloc(4*sizeof(int));
	MPI_Reduce(fromArray, maxFromReduce, 4, MPI_INT, MPI_MAX, 3, MPI_COMM_WORLD);

	if (rank == 3){
		//find max of the 4 reduced values
		int fromArrayMax = 0;
		for (i=0;i<4;i++){
			if (maxFromReduce[i] > fromArrayMax){
				fromArrayMax = maxFromReduce[i];
			}
		}
		//print reduced max
		printf("fromArrayMax(rank%d): %d\n",rank,fromArrayMax); 
	}

	//gather arrays back to process 0
	int arrayOne[16];
	MPI_Gather(fromArray, 4, MPI_INT, arrayOne, 4, MPI_INT, 0,MPI_COMM_WORLD);

	//print gathered array
	if (rank==0){
		printf("fromArray:\n");
		for(i=0;i<16;i++){
			printf("\t[%d] %d\n",i,arrayOne[i]);
		}
	}

	MPI_Finalize();
	return 0; 
}
