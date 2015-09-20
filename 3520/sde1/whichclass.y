%{
#include <stdio.h>
#include <ctype.h>
int yylex(void);
int yyerror(char *s);
%}

%token A
%token B
%token C
%token D

%% /*grammar rules */
/*
lettera: A
	{printf("recognized A\n");}
;
letterb: B
	{printf("recognized B\n");}
;
letterc: C
	{printf("recognized C\n");}
;
letterd: D
	{printf("recognized D\n");}
; */