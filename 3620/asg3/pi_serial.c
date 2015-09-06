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
	int out=0; // # of rand points that lie outside of circle

	time_t t;
   
	// Intializes random number generator
   	srand((unsigned) time(&t));

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

	float pi = (float)in/(float)p * 4;
	printf("Calculated PI = %lf\n",pi);
	
	return 0;
}
