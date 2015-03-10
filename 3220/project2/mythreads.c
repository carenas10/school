#include "mythreads.h"
#include <stdlib.h>
#include <stdbool.h>

//------------------------ STRUCTS & GLOBALS ------------------------

/* 
CIRCULAR THREAD QUEUE SETUP...
+-----------------------------------------------------------------------+
|								THREADLIST 								|
+-----------+-----------+-----------+-----------+-----------+-----------+
|THREADNODE |THREADNODE |THREADNODE |THREADNODE |THREADNODE |THREADNODE |							
+-----------------------------------------------------------------------+
|main thread|			|			|			|			|			|
|prev -> end|	...		|	...		|	...		|	...		|<-----	prev|
|next------>|			|			|			|			|next-> head|
+-----------+-----------+-----------+-----------+-----------+-----------+
   OLDEST -----------------------> NEWER ---------------------> NEWEST
*/

typedef struct threadNode {
	int threadID;
	ucontext_t context;
	//int status;
	void *retval;
	struct threadNode *next;
	struct threadNode *prev;
} threadNode;

//uses a circular queue struct so there is always something to run in *curr...
typedef struct threadList {
	int currentCount;	//number of threads in list. 
	struct threadNode *head;
	struct threadNode *tail;
	struct threadNode *curr; //current running thread.
} threadList;

//Sizes and numbers of return values of functions are arbitraty. 
//Used a non-circular singly-linked list to manage them as well.
typedef struct returnNode {
	int threadID; //value of thread that returned 
	void *retVal;
	struct returnNode *next;
} returnNode;

typedef struct returnList{
	returnNode *head;
	returnNode *tail;
} returnList;

int totalCount = 0; //number of threads since initialization.
int interruptsAreDisabled = 0; 
threadList *queue;	//list of all running threads, or unjoined threads.
returnList *returns;	//list of all return values.

//------------------------ LIST MANAGEMENT FUNCTIONS ------------------------
/*
//removes thread from circular thread queue.
void removeThread(threadNode *thread){
	//front of queue is main. Will never be removed this way. Doesn't need to be removed here...
	if(queue->tail == thread){ //removing back thread
		queue->head->prev = queue->tail->prev;
		queue->tail = queue->tail->prev;
		queue->curr = queue->head;
	} else { //removing any other
		thread->prev->next = thread->next;
		thread->next->prev = thread->prev;
	}
	//free memory??

	queue->currentCount--; //decrememnt current thread count in queue.
}
*/

//------------------------ THREAD MANAGEMENT (LIBRARY) FUNCTIONS ------------------------

//run a thread with function pointer and args and exit with threadExit to handle returns 
void runThread(thFuncPtr func, void *args){
	void *result = func(args);
	threadExit(result);
}

//initialize threading library
extern void threadInit(){
	interruptsAreDisabled = 1;

	//set up thread queue
	queue = malloc(sizeof(threadList));
	ucontext_t *current = malloc(sizeof(ucontext_t));
	getcontext(current);
	
	//new thread (main)
	threadNode *newThread = (threadNode *)malloc(sizeof(threadNode));
	newThread->threadID = 0; //main thread ID = 0
	newThread->context = *current;

	//set up thread queue with the new thread.
	queue->head = newThread;
	queue->tail = queue->head;
	queue->curr = queue->head;
	queue->currentCount = 1; //first thread

	returns = malloc(sizeof(returnList)); //set up return list
		returns->head = NULL;
		returns->tail = NULL;	

	totalCount++; //total threads since library init.
}

//Creates a new context & threadNode... Adds threadNode to back of queue.
int threadCreate(thFuncPtr funcPtr, void *argPtr){
	interruptsAreDisabled = 1; //entering critical section

	//context info
	ucontext_t *newContext = malloc(sizeof(ucontext_t));
	ucontext_t *prevContext = &(queue->curr->context); //for swap...

	//set up new context with thFuncPtr, argPtr and STACK_SIZE
	getcontext(newContext);
	newContext->uc_stack.ss_sp = malloc(STACK_SIZE); //allocate stack 
	newContext->uc_stack.ss_size = STACK_SIZE; //set stack size 
	newContext->uc_stack.ss_flags = 0; //no flags for context
	makecontext(newContext,(void(*)(void))runThread,2,funcPtr,argPtr);

	//make a new threadNode
	threadNode *newThread = (threadNode *)malloc(sizeof(threadNode));
	newThread->threadID = totalCount++; //inc totalCount after setting the thread ID.
	newThread->context = *newContext;

	//add newThread to BACK of queue.
	queue->currentCount++;
	queue->tail->next = newThread;
	newThread->prev = queue->tail;
	queue->tail = newThread;
	queue->tail->next = queue->head;
	queue->head->prev = queue->tail;
	queue->curr = queue->tail; //newThread is now current.

	interruptsAreDisabled = 0; //exiting critical section.
	swapcontext(prevContext,newContext);

	return newThread->threadID;
}

//yield process to next in queue.
//save context and prepare next context. 
//DOES NOT RETURN UNTIL SELECTED AGAIN TO RUN.
void threadYield(){
	//only yield if in noncritical section!
	if(!interruptsAreDisabled){
		ucontext_t *prevContext = &(queue->curr->context); 
		queue->curr = queue->curr->next;
		ucontext_t *nextContext = &(queue->curr->context);
		swapcontext(prevContext,nextContext);
	}
	//else do nothing... cannot interrupt. 
}

//wait for thread to return.
void threadJoin(int thread_id, void **result){
	bool foundReturn = false;
	while (!foundReturn){
		interruptsAreDisabled = 1; //entering critical section

		//iterate thru return values, matching threadID
		returnNode *search = NULL; //for now.
		if(returns->head != NULL){
			search = returns->head;
			while(search != NULL && foundReturn == false){ //break when find return or run out.
				if(search->threadID == thread_id){
					*result = (search->retVal);
					foundReturn = true;
				}
				search = search->next;
			}//while 
		}//if (search)
	}//while
	interruptsAreDisabled = 0; //out of critical section.
}

//exits the current thread -- closing the main thread will terminate the program
void threadExit(void *result){
	interruptsAreDisabled = 1; //entering critical section

	if(queue->curr->threadID == 0) exit(0); //exiting main thread.
	else{ //not main thread

		//create new return type node
		returnNode *newReturnNode = malloc(sizeof(returnNode));
		newReturnNode->threadID = queue->curr->threadID;
		newReturnNode->retVal = result;

		//add to return list
		if(returns->head == NULL){ //returns list is empty
			returns->head = newReturnNode;
			returns->tail = newReturnNode;
		} else {
			returns->tail->next = newReturnNode;
			returns->tail = newReturnNode;
		}//added return val node

		//remove current thread from thread queue
		if(queue->tail == queue->curr){ //removing back thread
			queue->head->prev = queue->tail->prev;
			queue->tail = queue->tail->prev;
			queue->curr = queue->head;
		} else { //removing any other
			threadNode *nextThread = queue->curr->next;
			queue->curr->prev->next = queue->curr->next;
			queue->curr->next->prev = queue->curr->prev;
			queue->curr = nextThread;
		}//removed thread.
		//free memory from threadNode?

		queue->currentCount--;
	}//else (not main thread)
}

//------------------------ SYNCHRONIZATION FUNCTIONS (LIBRARY) ------------------------

void threadLock(int lockNum){
	//TODO
}

void threadUnlock(int lockNum){
	//TODO
}

void threadWait(int lockNum, int conditionNum){
	//TODO
}

void threadSignal(int lockNum, int conditionNum){
	//TODO
}
