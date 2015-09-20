int yyerror(s) /* Called by yyparse */
	char *s;
{
printf("\n%s\n", s);
return(1);	
}