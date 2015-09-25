// CLOUDLAB LOGINS
// NODE 0:
// ssh -p 22 mpiuser@clnode001.clemson.cloudlab.us
// NODE 1:
// ssh -p 22 mpiuser@pc-c220m4-r01-17.wisc.cloudlab.us
// PASSWORD FOR BOTH: "redfrog"

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char* argv[]){
	srand(time(NULL));

	MPI_Init(&argc, &argv);

	MPI_Status status;

	int rank, size;   
	double start, stop;
	start = MPI_Wtime();

	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	int done = 0; //per-node status

	//Master Variables
	int i;

	//Statistics Variables
	int workloads[size], type0 = 0, type1 = 0, type2 = 0, jobdone = -1;
	float sleepTimeWorker[size], sleepTimeType[3] = {0.0, 0.0, 0.0}, timeSlept = 0.0;
    
    for(i = 0; i < size; i++) {
    	workloads[i] = 0;
    	sleepTimeWorker[i] = 0;
    }


  	if(rank == 0) { //------------------------ MASTER ------------------------
	    //Create Queue
	    int queue[1024];
	    for(i = 0; i < 1024; i++) {
			queue[i] = rand() % 3;
			if(queue[i] == 0) type0++;
			else if(queue[i] == 1) type1++;
			else type2++;
		} //queue should be constructed here.
	    
	    //------------------------ READY TO START ------------------------
	    /*
	    send one workload to all processes to begin

		LOOP for 0 -> 1024-(size-1)
			recv from a finished worker
			send new task to worker
		*/

    	int nextReady;
    	int *acceptArray = NULL;
    	int acceptArrayLen;

    	//send initial task to all workers
    	//i -> process # 
    	for(i=1;i<size;i++){
    		// TAG 1 SEND -> SEND TASK
    		MPI_Send(&queue[i-1], 1, MPI_INT, i, 1, MPI_COMM_WORLD);
    	}

    	//i -> queue item #
    	for(i=size-1;i<1024;i++){
    		//get the next ready process
    		//TAG 2 RECV -> NEXT READY
    		MPI_Recv(&nextReady, 1, MPI_INT, MPI_ANY_SOURCE, 2, MPI_COMM_WORLD, &status);

			//find out how long the recv array is
			//TAG 3 RECV
    		MPI_Recv(&acceptArrayLen, 1, MPI_INT, nextReady, 3, MPI_COMM_WORLD, &status);
    		
    		//accept array
    		//TAG 4 RECV
    		acceptArray = (int *)malloc(sizeof(int) * acceptArrayLen);
    		MPI_Recv(acceptArray, acceptArrayLen, MPI_INT, nextReady, 4, MPI_COMM_WORLD, &status);
    		free(acceptArray); //dump array...

    		//Receive Time and Type
			MPI_Recv(&timeSlept, 1, MPI_FLOAT, nextReady, 5, MPI_COMM_WORLD, &status);
			MPI_Recv(&jobdone, 1, MPI_INT, nextReady, 6, MPI_COMM_WORLD, &status);
			sleepTimeWorker[nextReady] += timeSlept;
			sleepTimeType[jobdone] += timeSlept;
			workloads[nextReady]++;

    		//send workload to process
    		//TAG 1 SEND -> SEND TASK
    		MPI_Send(&queue[i], 1, MPI_INT, nextReady, 1, MPI_COMM_WORLD);
    	}//end for

    	//DONE. END WORKERS
    	//i -> process # 
    	for(i=1;i<size;i++){
    		// TAG 1 SEND -> SEND TASK
    		int msg = -1;
    		MPI_Send(&msg, 1, MPI_INT, i, 1, MPI_COMM_WORLD);
    	}
	} else { //------------------------ WORKER ------------------------
		/*
		LOOP
			recv from master
			process workload (wait)
			send back to master
		*/
		float sleepTime; //number of seconds to wait
		int count; //number of items to return to master
		int *sendBuf; //to send back to master
		int job; //workload

		while(!done){
			//Receive Workloads (blocking)
			// TAG 1 RECV -> TASK
			MPI_Recv(&job, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
			//printf("RANK: %d, JOB: %d\n",rank,job);

			//------------------------ PROCESS ------------------------
			if(job == 0) {
				sleepTime = (float)rand()/(float)(RAND_MAX/1.4) + 0.1;
				count = rand()%(11) + 10;
			} else if(job == 1) {
				sleepTime = (float)rand()/(float)(RAND_MAX/2.0) + 2.0;
				count = rand()%(31) + 20;
			} else if(job == 2) {
				sleepTime = (float)rand()/(float)(RAND_MAX/3.5) + 3.5;
				count = rand()%(51) + 50;
			} else if(job == -1){
				done = 1;
				break;
			}

			//Sleep for Designated Time
			//usleep(sleepTime*1000000);
			//printf("[%d]: sleeping for %d microseconds\n",rank,(int)sleepTime*1000);
			usleep((useconds_t)(1000000*sleepTime));

			//printf("rank: %d, sleepTime: %lf, count: %d\n",rank,sleepTime,count);

			//------------------------ RESPOND ------------------------
			//Create Buffer
			sendBuf = (int *) malloc(count * sizeof(int));
			for(i = 0; i < count; i++) sendBuf[i] = rand();

			//tell master which rank this is
			//TAG 2 SEND
			MPI_Send(&rank, 1, MPI_INT, 0, 2, MPI_COMM_WORLD);

			//tell master how many we're sending
			//TAG 3 SEND
			MPI_Send(&count, 1, MPI_INT, 0, 3, MPI_COMM_WORLD);

			//send back to master
			//TAG 4 SEND
			MPI_Send(sendBuf, count, MPI_INT, 0, 4, MPI_COMM_WORLD);

			//send time to master
			//TAG 5 SEND
			MPI_Send(&sleepTime, 1, MPI_FLOAT, 0, 5, MPI_COMM_WORLD);
			MPI_Send(&job, 1, MPI_INT, 0, 6, MPI_COMM_WORLD);
			
			free(sendBuf);
		}//while not done
	} //end rank != 0

	//------------------------ DONE WORKING. STATS NOW ------------------------
	if(rank == 0) {

		//Print Statistics
		printf("Dynamic Stats for %d Processes\n\n", size);
		printf("Number of Workloads -\n"); 
		printf("  Type0: %d\n", type0);
		printf("  Type1: %d\n", type1);
		printf("  Type2: %d\n", type2);

		//avg processing time per type
		printf("Avg Processing Time -\n");
		printf("  Type 0: %f\n", (sleepTimeType[0]/type0));
		printf("  Type 1: %f\n", (sleepTimeType[1]/type1));
		printf("  Type 2: %f\n", (sleepTimeType[2]/type2));

		//total processing time per type
		printf("Total Processing Time -\n");
		printf("  Type 0: %f\n", sleepTimeType[0]);
		printf("  Type 1: %f\n", sleepTimeType[1]);
		printf("  Type 2: %f\n", sleepTimeType[2]);

		//num workloads per worker
		printf("Number of Workloads -\n");
		for(i = 1; i < size; i++) {
		  printf("  Worker %i: %i\n", i, workloads[i]);
		}

		//avg processing time per worker
		printf("Avg Processing Time -\n");
		for(i = 1; i < size; i++) {
		  printf("  Worker %i: %f\n", i, (sleepTimeWorker[i]/(double)workloads[i]));
		}

		//total processing time per worker
		printf("Total Processing Time -\n");
		for(i = 1; i < size; i++) {
		  printf("  Worker %i: %f\n", i, sleepTimeWorker[i]);
		}

		//total execution time
		stop = MPI_Wtime();
		printf("Total execution time: %f\n", stop-start);
		printf("\n\n");
	} //end rank 0

  	MPI_Finalize();

  	return 0;
}

