:- ['sde3_auxiliary_predicates.pro'].

/* allowed adjacencies */
adj_to(red,green).
adj_to(red,blue).
adj_to(blue,green).

/* transitive property of adjacency */
adjacent_to(R1,R2) :- adj_to(R1,R2).
adjacent_to(R1,R2) :- adj_to(R2,R1).

%% solve case 4. 3 colors, 7 regions
case4 :- 
	adjacent_to(R1,R2),
	adjacent_to(R1,R3),
	adjacent_to(R1,R4),
	adjacent_to(R2,R3),
	adjacent_to(R2,R6),
	adjacent_to(R2,R7),
	adjacent_to(R3,R4),
	adjacent_to(R3,R5),
	adjacent_to(R3,R6),
	adjacent_to(R4,R6),
	adjacent_to(R4,R7),
	adjacent_to(R5,R6),
	adjacent_to(R6,R7),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.