/*
file: sde3_auxiliary_predicates.pro
Jackson Dawkins
*/

/* 
is_member/2
	is_member(+X,+RS): Succeeds if X is a member of the list RS 
*/
%% USE INSTEAD? memberchk(?Elem, +List)
is_member(X, [X|_]).
is_member(X, [_|Y]) :- is_member(X,Y), !.

/*
print_list/1
	print_list(+L): Succeeds.
	side effects: prints elements of the list with a space breaking each one
*/
print_list([]).
print_list([H|T]) :- write(H), write(' '), print_list(T), !.

/*
repeated_in/2
	repeated_in(+L,+RS): Succeeds if L is repeated in list RS.
	L: Item
	RS: List
	method: check if repeated in tail OR head is L and L is member of Tail
	method: check if L is Head and if member of tail OR repeated in tail
*/
repeated_in(L,RS) :- [H|T] = RS, (repeated_in(L,T); (L = H, is_member(L,T))),!. 

/*
at_most_one/2
	at_most_one(+L,+RS): Succeeds if L is contained at most once in list RS.
*/
at_most_one(L,RS) :- not(repeated_in(L,RS)),!.

/*
at_least_one/2
	at_least_one(+L,+RS): Succeeds if L is contained at least once in list RS.
*/
at_least_one(L,RS) :- is_member(L,RS),!. 

/*
exactly_one/2
	exactly_one(+L,+RS): Succeeds if L is contained exactly once in list RS.
	L is a member of RS, but not repeated in RS.
*/
exactly_one(L,RS) :- is_member(L,RS), not(repeated_in(L,RS)),!.

/*
write_solns_general/1
	write_solns_general(+L): Given a list of regions bound to colors, displays these colors in one line. Used for solution display (also see examples #1 and #2 above).
*/
write_solns_general(L) :- write('A coloring solution with colors in order of regions (Ri, i=1,2...) is:'), nl, print_list(L), !.

/*
exactly/3
	exactly(+L,+N,+C): Succeeds if in L there are exactly N occurrences of C.
	L: List
	N: Number of Occurrences
	C: Element to count occurrences of
*/
exactly(L,N,C) :- [] = L, C = C, N is 0,!. 								%% CASE: empty list
exactly(L,N,C) :- [H|T] = L, H = C, exactly(T,NUM,C), N is 1 + NUM,!. 	%% CASE: head is C
exactly(L,N,C) :- [H|T] = L, not(H = C), exactly(T,NUM,C), N is NUM,!. 		%% CASE: head is not C

/*
exactly_2_of_each/3
	exactly_2_of_each(+L,+C1,+C2): Succeeds if L contains exactly 2 C1 and exactly 2 C2.
*/
exactly_2_of_each(L,C1,C2) :- exactly(L,2,C1), exactly(L,2,C2), !.

/*
exactly_N_of_each/7 
	exactly_N_of_each(+L,N1,+C1,+N2,+C2,+N3,+C3): Succeeds if L contains exactly N1 C1 and exactly N2 C2 and exactly N3 C3.
*/
exactly_N_of_each(L,N1,C1,N2,C2,N3,C3) :- exactly(L,N1,C1), exactly(L,N2,C2), exactly(L,N3,C3), !.

