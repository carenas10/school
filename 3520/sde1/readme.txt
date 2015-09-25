Jackson Dawkins
CPSC 3520 - SDE 01

PLEDGE: On my honor I have neither given nor received aid on this exam.

whichclass.in —-> This is a flex file. The purpose is to analyze and tokenize the input.
	This file counts the number of each valid input character (a-e)
	
whichclass.y --> This is a bison file. The purpose of this file is to receive the
	input nonterminal and count of each token. Knowing the order and count of each 
	nonterminal makes parsing the input easy using conditionals.

whichclass.c --> This file is a simple file containing a main function with a call
	to yyparse()

whichclass.log --> This file is a log of the test of the scanner/parser and outputs.