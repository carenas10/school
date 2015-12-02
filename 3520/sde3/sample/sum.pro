/* sum elements of  a list */

/* if a list only has 1 item, the sum is that item. */
/* list format [[1],[2],[3],[4],[5]] */

%% MOST BASIC SOLUTION FIRST
sumoflist([[X]],X).

/* recursive solution */
sumoflist([A|B], Sum) :- sumoflist([A],I), sumoflist(B,J), Sum is I + J. 
