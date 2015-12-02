/* member test of a list */

member1(X,[X|_]).
member1(X,[_|Y]) :- member1(X,Y).
