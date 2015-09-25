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
#include <math.h>
#include <unistd.h>

float sleepTime(int type);

int main(int argc, char* argv[]) {
  int wl = 1024;

  srand(time(NULL));
  
  MPI_Init(&argc, &argv);

  MPI_Status status;

  int rank, size;   
  double start, stop;
  start = MPI_Wtime();
  
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  int i, type = 0;
  
  //Master Variables
  int j, count;
  int *ptr;
  int *recvbuff, recvCount;
  int workerNum = 0;
  
  //Worker Variables
  int c, *localQueue, n, *sendbuff;
  float x = 0.0;
  
  //Statistics Variables
  int workloads[size], type0 = 0, type1 = 0, type2 = 0;
  double totalWorkTime = 0.0;
  float sleepTimeWorker[size], sleepTimeType[3] = {0, 0, 0};
  float timeSlept = 0.0;
  
  for(i = 0; i < size; i++) {
    workloads[i] = 0;
    sleepTimeWorker[i] = 0.0;
  }
  
  if(rank == 0) {
    
    //Create Queue
    int queue[wl];
    for(i = 0; i < wl; i++) {
      queue[i] = rand() % 3;
      if(queue[i] == 0) {
        type0++;
        totalWorkTime += 0.75;
      }
      else if(queue[i] == 1) { 
        type1++;
        totalWorkTime += 3.0;
      }
      else { 
        type2++;
        totalWorkTime += 5.75;
      }
    }
    
    //Send Workload
    count = wl/(size-1);
    for(i = 1; i < size; i++) {

        ptr = &queue[((i - 1) * count)];
        workloads[i] = count;      
        
        MPI_Send(&count, 1, MPI_INT, i, 0, MPI_COMM_WORLD); 
        MPI_Send(ptr, count, MPI_INT, i, 0, MPI_COMM_WORLD);
    }
  }
  
  //Worker Handle Workload
  if(rank != 0) {
    //Receive Workloads
    MPI_Recv(&c, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
    localQueue = (int *) malloc(c * sizeof(int));
    MPI_Recv(localQueue, c, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);

    //Workload
    for(i = 0; i < c; i++) {
      if(localQueue[i] == 0) {
          x = sleepTime(0);
          n = rand()%(11) + 10;
      } else if(localQueue[i] == 1) {
          x = sleepTime(1);
          n = rand()%(31) + 20;
      } else if(localQueue[i] == 2) {
          x = sleepTime(2);
          n = rand()%(51) + 50;
      }
     
      //Sleep for Designated Time
      usleep((useconds_t)(1000000 * x));     

      //Create Buffer
      /*sendbuff = (int *) malloc(n * sizeof(int));
      for(j = 0; j < n; j++) {
        sendbuff[i] = rand();
      }

      // Send Buffer Count Back to Master
      MPI_Send(&n, 1, MPI_INT, 0, 1, MPI_COMM_WORLD);
      // Send Buffer Back to Master
      MPI_Send(sendbuff, n, MPI_INT, 0, 2, MPI_COMM_WORLD);*/
      // Send Worker Number back to Master
      MPI_Send(&rank, 1, MPI_INT, 0, 3, MPI_COMM_WORLD);
      //Send Type back to Master 
      MPI_Send(&localQueue[i], 1, MPI_INT, 0, 4, MPI_COMM_WORLD); 
      //Send Time back to Master 
      MPI_Send(&x, 1, MPI_FLOAT, 0, 5, MPI_COMM_WORLD); 

      //free(sendbuff);
    }
    free(localQueue);
  }
  
  if(rank == 0) {
    //Receive Response
    count = 0;
    int cP = 1;
    for(count = 0; count < wl; count++) {
      /*MPI_Recv(&recvCount, 1, MPI_INT, cP, 1, MPI_COMM_WORLD, &status);
      recvbuff = (int *) malloc(recvCount * sizeof(int));
      // Receive Array
      MPI_Recv(recvbuff, recvCount, MPI_INT, cP, 2, MPI_COMM_WORLD, &status);
      free(recvbuff);*/
      // Receive Worker Number
      MPI_Recv(&workerNum, 1, MPI_INT, cP, 3, MPI_COMM_WORLD, &status);
      // Receive Work Type
      MPI_Recv(&type, 1, MPI_INT, cP, 4, MPI_COMM_WORLD, &status);
      // Receive Worker Time
      MPI_Recv(&timeSlept, 1, MPI_FLOAT, cP, 5, MPI_COMM_WORLD, &status);

      if(type) {
        sleepTimeType[0] += timeSlept;
      } else if(type == 1) {
        sleepTimeType[1] += timeSlept;
      } else {
        sleepTimeType[2] += timeSlept;
      }

      sleepTimeWorker[workerNum] += timeSlept;

      cP = ((cP)%(size-1)) +1;
    }

    //Print Statistics
  
    printf("Static Stats for %d Processes\n\n", size);
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
  }
  
  MPI_Finalize();

  return 0;
}

float sleepTime(int type) {
  float x = 0.0;
  
  if(type == 0) {
    x = ((float) rand() /(float) (RAND_MAX))*(1.5-.1) + .1;
  } else if(type == 1) {
    x = ((float) rand() /(float) (RAND_MAX))*(4.0-2.0) + 2.0;
  } else { 
    x = ((float) rand() /(float) (RAND_MAX))*(7.0-3.5) + 3.5;
  }
 
  return x;
}
