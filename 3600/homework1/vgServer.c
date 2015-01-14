#include <stdio.h>
#include <time.h>
#include <stdlib.h>

//returns a random int value
//TODO -- find better random generator
int generateRand(){
    srand(time(NULL));
    int r = rand();
    return r;
}

int main (int argc, char *argv[]){

    /*
    Once the client has a guess, it sends a message
    to the server asking if the value is correct.
    */

    /*
    TODO -- The server replies with a message of 0, 1, or 2.
    Zero is returned if the guess is correct,
    1 if the guess is too high, and 2 if the guess is too low.
    */

    /*
    TODO -- At the server, if the value is guessed, the server randomly 
    comes up with a new value and loops to play the game again.
    */

    /*
    At the client, if it successfully guesses the value
    it terminates displaying an appropriate message to the user.
    */





}
