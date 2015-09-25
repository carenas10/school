%{
#include <stdio.h>
#include <ctype.h>

int yylex(void);
int yyerror(char *s);

int countA = 0;
int countB = 0;
int countC = 0;
int countD = 0;
int countE = 0;

%}

%token A
%token B
%token C
%token D
%token E
%token Q

%% /*grammar rules */
production: lang1or3or4 { 
	/*printf("counts: %d, %d, %d, %d, %d\n",countA, countB, countC, countD, countE);*/
}
| lang2 {
	/*printf("counts: %d, %d, %d, %d, %d\n",countA, countB, countC, countD, countE);*/
}
| lang5 {
	/*printf("counts: %d, %d, %d, %d, %d\n",countA, countB, countC, countD, countE);*/
};

lang1or3or4: a b c d {
	if(countA == countB && countC == countD && countB == countC){
		/*printf("found lang 3\n");*/
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\nGrammar G3 Recognized\n");
	} else if(countA == countC && countB == countD && countA != countB){
		/*printf("found lang 4\n");*/
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\nGrammar G4 Recognized\n");
	} else if(countA != countB && countB != countD){
		/*printf("found lang 1\n");*/
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\nGrammar G1 Recognized\n");
	} else printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\n’Sorry,input string not in any of the recognized grammars (None of the Above)’\n");
};

lang2: a b c {
	if(countA == countB && countB == countC){
		/*printf("found lang 2\n");*/
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\nGrammar G2 Recognized\n");
	} else {
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\n’Sorry,input string not in any of the recognized grammars (None of the Above)’\n");
	}
};

lang5: c d e {
	if(countE == countD+1 && countD == countC+1){
		/*printf("found lang 5\n");*/
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\nGrammar G5 Recognized\n");
	} else {
		printf(">>>> Grammatical Recognizer (SDE1) <<<<<<\n’Sorry,input string not in any of the recognized grammars (None of the Above)’\n");
	}
};

a: A;
b: B;
c: C;
d: D;
e: E;
