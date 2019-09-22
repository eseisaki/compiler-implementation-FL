#include <stdio.h>
#include "FL_parser.tab.h"

int main () {
  if ( yyparse() == 0 )
		printf("\n//Syntax Accepted!\n");
	else
		printf("\n//Syntax Rejected!\n");
  
}
