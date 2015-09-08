#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h> 
#include <time.h>
#include <mpi.h>

#define DEBUG 1

int main(int argc, char *argv[]){
	
	//if(argc < 2) printf("usage %s <NUM POINTS>",argv[0]);

	MPI_Init(&argc, &argv);

	int p = atoi(argv[1]); //number of random points to test
	//if(DEBUG) printf("Random Points: %d\n",p);

	int i, rank, size, numNodes; //i->for loops
	float test_x, test_y, pi; //test points	
	float split_x, split_y; //local sub-block origin
	int in=0; //num rand points that lie in circle
	time_t t; //for rand
	double start, stop; //timing vars   
	MPI_Status status;
	int numToTest; //num points for each node to test

	//set size/rank info
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	struct utsname uts;
	uname (&uts);

	// Intializes random number generator
   	srand((unsigned) time(&t));

	//get start time of program
	start = MPI_Wtime();

	//find number of processes
	MPI_Comm_size(MPI_COMM_WORLD, &numNodes);	
	//if(DEBUG) printf("size: %d\n",numNodes);

	/*
		METHOD: I'd rather have processes not doing anything than 
				processes calculating more than one block.
		n = 1,2,3 	split 1x1, n = 4-8 		split 2x2
		n = 9-15	split 3x3, n = 16-24	split 4x4
		n = 25-35	split 5x5
		...
		total blocks = floor(sqrt(n))^2
		division = floor(sqrt(n))
	*/

	//find number of blocks across
	int numAcross = (int)floor(sqrt((double)numNodes));
	//if(DEBUG) printf("num of divisions: %d\n",numAcross);

	//find width/height of each block
	double blockSize = 1/(double)numAcross;
	//if(DEBUG) printf("Size of divisions: %lf\n",blockSize);

	//find number of points for each node to test
	numToTest = (int)ceil((float)p/(float)(numAcross*numAcross));
	//if (DEBUG) printf("numToTest: %d\n",numToTest);

	//------------------------ PAR ------------------------
	/*
		find sub-block origin
		-	node/numAcross == y - cell
		-	node%numAcross == x - cell
	*/
	split_x = (rank % numAcross) * blockSize;
	split_y = (rank / numAcross) * blockSize;
	//if(DEBUG) printf("Node %d: (%lf,%lf)\n",rank,split_x,split_y);

	//test numToTest points
	for(i=0;i<numToTest;i++){
		//choose a random point in the square

		//find num in range of 0-blockSize
		//add to sub-block origin
		test_x = (float)rand()/(float)(RAND_MAX/(float)blockSize) + split_x;
		test_y = (float)rand()/(float)(RAND_MAX/(float)blockSize) + split_y;
		//if(DEBUG) printf("rand in range %lf\n",x);
		
		//center of unit circle is (0.5,0.5)
		//(x - center_x)^2 + (y - center_y)^2 < radius^2
		if((test_x - 0.5)*(test_x - 0.5) + (test_y - 0.5)*(test_y - 0.5) <= 0.25){
			//in circle
			in++;
		}
	}

	float localPI = (float)in/(float)numToTest * 4;
	//if(DEBUG) printf("local pi: %lf\n", localPI);

	//only send local pi back for reduction if test region is in unit square
	if(rank < numAcross*numAcross){
		MPI_Send(&localPI, 1, MPI_FLOAT, 0, 0, MPI_COMM_WORLD);
	}

	if (rank == 0){
		//recv from all other nodes
		float locals[numAcross*numAcross];
		for (i=0;i<(numAcross*numAcross);i++){
			MPI_Recv(&locals[i], 1, MPI_FLOAT, i, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		}
		
		//avg all nodes
		pi = 0;
		for (i=0;i<(numAcross*numAcross);i++){
			pi += locals[i];
		}

		pi = pi / (numAcross*numAcross); //calculate final pi

		stop = MPI_Wtime();
		double runtime = stop-start;

		printf("Calculated PI = %lf\n",pi);		
		printf("runtime: %lf sec\n",runtime);	
	}

	MPI_Finalize();
	return 0;
}
