#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int main(int argc, char *argv[]){

	//p -> number of random points to test
	int p = atoi(argv[1]);
	printf("Random Points: %d\n",p);

	// VARS 
	int i; //for looping
	float test_x, test_y; 	
	int in=0; // # of rand points that lie in circle
	time_t t;
	double start, stop;
	float pi;   

	// Intializes random number generator
   	srand((unsigned) time(&t));

	MPI_Init(&argc, &argv);
	start = MPI_Wtime();

	for (i=0;i<p;i++){
		//choose a random point in the square
		//([0,1],[0,1])
		
		test_x = ((float) rand()) / (float) RAND_MAX;
		test_y = ((float) rand()) / (float) RAND_MAX;
		//printf("%lf, %lf", test_x, test_y);
		
	//center of unit circle is (0.5,0.5)
	//(x - center_x)^2 + (y - center_y)^2 < radius^2
	if((test_x - 0.5)*(test_x - 0.5) + (test_y - 0.5)*(test_y - 0.5) <= 0.25){
			//in circle
			//printf("\tYES\n");
			in++;
		} else {
			//not in circle
			//printf("\tNO\n");
			out++;
		}
	}

	pi = (float)in/(float)p * 4;
	stop = MPI_Wtime();
	printf("Calculated PI = %lf\n",pi);
	
	MPI_Finalize();

	return 0;
}
