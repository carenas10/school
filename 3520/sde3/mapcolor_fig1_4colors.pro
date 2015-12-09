:- ['sde3_auxiliary_predicates.pro'].

/* allowed adjacencies */
adj_to(red,green).
adj_to(red,blue).
adj_to(red,white).
adj_to(blue,green).
adj_to(blue,white).
adj_to(green,white).

/* transitive property of adjacency */
adjacent_to(R1,R2) :- adj_to(R1,R2).
adjacent_to(R1,R2) :- adj_to(R2,R1).

%% solve case 3. 4 colors, 3 regions
case3 :- 
	adjacent_to(R1,R2),
	adjacent_to(R1,R3),
	adjacent_to(R2,R3),
	write_solns_general([R1,R2,R3]),
	nl,
	fail.