:- ['sde3_auxiliary_predicates.pro'].

/* allowed adjacencies */
adj_to(red,green).
adj_to(red,blue).
adj_to(blue,green).

/* transitive property of adjacency */
adjacent_to(R1,R2) :- adj_to(R1,R2).
adjacent_to(R1,R2) :- adj_to(R2,R1).

%% solve case 2. 3 colors, 4 regions
case2 :- 
	adjacent_to(R1,R2),
	adjacent_to(R1,R3),
	adjacent_to(R2,R3),
	adjacent_to(R2,R4),
	write_solns_general([R1,R2,R3,R4]),
	nl,
	fail.