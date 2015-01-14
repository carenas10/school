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
    int guess;
    int result= -1;

    if(argc != 3){
        printf("Usage: valueGuesser <serverName> <serverPort>\n");
        return 0;
    }

    //guess number
    guess = generateRand();
    printf("%d\n",r);

    /*
    TODO -- Once the client has a guess, it sends a message
    to the server asking if the value is correct.
    */

    /*
    The server replies with a message of 0, 1, or 2.
    Zero is returned if the guess is correct,
    1 if the guess is too high, and 2 if the guess is too low.

    At the server, if the value is guessed, the server randomly
    comes up with a new value and loops to play the game again.
    */


    //loop until correct guess
    while(result != 0){
        /*
        TODO -- At the client, if it successfully guesses the value
        it terminates displaying an appropriate message to the user.
        */
    }

return 0;
}
