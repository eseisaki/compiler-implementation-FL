/*
Another common problem is that a header file is required in multiple other header files that are later included into a source code file, with the result often being that variables, structs, classes or functions appear to be defined multiple times (once for each time the header file is included). This can result in a lot of compile-time headaches. Fortunately, the preprocessor provides an easy technique for ensuring that any given file is included once and only once. 
*/
#ifndef CGEN_H
#define CGEN_H

/*
	String streams are handy for using standard C-library
	functions to produce formatted strings.
*/
typedef struct sstream
{
	char *buffer;
	size_t bufsize;
	FILE* stream;
} sstream;

void ssopen(sstream* S);
char* ssvalue(sstream* S);
void ssclose(sstream* S);


/*
 	This function takes the same arguments as printf,
 	but returns a new string with the output value in it.
 */
char* template(const char* pat, ...);

/*
	This is the function used to report errors in the translation.
*/
void yyerror(char const* pat, ...);

/*
	This is set to the number of calls to yyerror
 */
extern int yyerror_count;


/* This is output at the head of a c program. */
extern const char* c_prologue;

/*
 Make a C string literal out of a FL string literal.
 Return the corrected string (maybe the same as P).
*/
char* string_fl2c(char* P);


char* concat(const char *s1, const char *s2);

char* trimEnd(char* name);

#endif
