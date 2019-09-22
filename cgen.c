#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "cgen.h"

extern int line_num;

void ssopen(sstream* S)
{
	S->stream = open_memstream(& S->buffer, & S->bufsize);
}

char* ssvalue(sstream* S)
{
	fflush(S->stream);
	return S->buffer;
}

void ssclose(sstream* S)
{
	fclose(S->stream);
}


char* template(const char* pat, ...)
{
	sstream S;
	ssopen(&S);

	va_list arg;
	va_start(arg, pat);
	vfprintf(S.stream, pat, arg );
	va_end(arg);

	char* ret = ssvalue(&S);
	ssclose(&S);
	return ret;
}

/* Helper functions */

char* string_fl2c(char* P)
{
	/*
		This implementation is 
		***** NOT CORRECT ACCORDING TO THE PROJECT ******
	*/

	/* Just chech and change the first and last characters */
	int Plen = strlen(P);
	assert(Plen>=2);
	P[0] = '"';
	P[Plen-1] = '"';

	return P;
}

char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1)+strlen(s2)+1);//+1 for the null-terminator
    //in real code you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

char* trimEnd(char* name)
{
    int i = 0;
    while(name[i] != '\0')
    {
        i++;
         
    }
    name[i-1] = '\0';
    return name;
}



/*
	Report errors 
*/
 void yyerror (char const *pat, ...) {
	
	fprintf (stderr,"\n");
 	va_list arg;
	va_start(arg, pat);
    vfprintf(stderr, pat, arg);
    va_end(arg);

    fprintf (stderr, " in line: %d \n ", line_num);

	fprintf(stderr,"\n");

    yyerror_count++;
	fprintf (stderr, "num of errors: %d \n ", yyerror_count);
	fprintf(stderr,"\n\n");
 }

int yyerror_count = 0;

const char* c_prologue = 
"#include \"FLlib.h\"\n"
"\n"
;





