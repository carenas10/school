/* a simple fact. factorial(1)=1 */

factorial(1,1).

/* rule to recursively define factorial */

factorial(N,Result) :- Imin1 is N-1, factorial(Imin1, Fmin1), Result is N*Fmin1.
