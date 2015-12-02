/* 99 bottles game... */

/* recursive clauses */

bottles(1) :- write('1 bottle of beer on the wall, '),nl,
	write('1 bottle of beer...'),nl,
	write('take one down and pass it all around...'),nl,nl,
	write('Thats all, folks!').

bottles(X) :- 
	nl,
	write(X), write(' bottles of beer on the wall, '),nl,
	write(X), write(' bottles of beer...'),nl,
	write('take one down and pass it around, '),nl,
	X1 is X - 1, /* infix notation */
	write(X1), write(' bottles of beer on the wall.'),nl,nl,
	write('-------- pause --------'),nl,nl,
	bottles(X1). /* direct recursion */ 

/* The goal */

root_beer_goal :- bottles(4).
