/*
mapcolor_fig3_4colors.pro used to color a map with 7 regions.
Copyright (C) 2015 Jackson Dawkins
Contact author by email: jacksod[at]g.clemson.edu

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

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

%% solve case 5. 4 colors, 7 regions
case5 :- 
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

/*
Form a new goal, case5_atmost_1green, by adding (to the coloring constraint) 
the single global constraint that a solution must contain at most one use of the 
color green. Show all solutions to this goal in the log file.
*/
case5_atmost_1green :-
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
	at_most_one(green,[R1,R2,R3,R4,R5,R6,R7]),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.

/*
Then, form a new goal, case5_exactly_1red, by adding (to the color- ing constraint) 
the single global constraint that a solution must contain at exactly one use of the 
color red. Show all solutions to this goal in the log file.
*/
case5_exactly_1red :-
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
	exactly_one(red,[R1,R2,R3,R4,R5,R6,R7]),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.


/*
Form a new goal, case5_exactly_3_green by adding (to the coloring constraint) the 
single global constraint that a coloring solution must contain exactly 3 uses of the 
color green. Show all solutions to this goal in the log file.
*/
case5_exactly_3_green :- 
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
	exactly([R1,R2,R3,R4,R5,R6,R7],3,green),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.
/*
Form a new goal, case5_exactly_2_blue_white by adding (to the coloring constraint) 
the single global constraint that a coloring solution must contain exactly 2 uses of 
blue and 2 uses of white. Show all solutions to this goal in the log file.
*/
case5_exactly_2_blue_white :-
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
	exactly_2_of_each([R1,R2,R3,R4,R5,R6,R7],blue,white),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.
/*
Form a new goal,case5_exactly_3_blue_2_white_2_green by adding (to the coloring constraint) 
the single global constraint that a solution must contain exactly 3 uses of blue and 2 
uses of white and 2 uses of green. Show all solutions to this goal in the log file.
*/
case5_exactly_3_blue_2_white_2_green :- 
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
	exactly_N_of_each([R1,R2,R3,R4,R5,R6,R7],3,blue,2,white,2,green),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.
/*
Form a newgoal,case5_exactly_4_blue_2_white_2_green by adding (to the coloring constraint) 
the single global constraint that a solution must contain exactly 4 uses of blue and 2 uses 
of white and 2 uses of green. Show all solutions to this goal in the log file.
*/
case5_exactly_4_blue_2_white_2_green :- 
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
	exactly_N_of_each([R1,R2,R3,R4,R5,R6,R7],4,blue,2,white,2,green),
	write_solns_general([R1,R2,R3,R4,R5,R6,R7]),
	nl,
	fail.
