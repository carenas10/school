#include "whichclass.tab.c"
#include "lex.yy.c"
#include "yyerror.c"

int main(){
	yyparse();
	return(1);
}
