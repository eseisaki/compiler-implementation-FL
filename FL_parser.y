%{
#include <stdarg.h>
#include <stdio.h>	
#include <stdlib.h>
#include <string.h>
#include "cgen.h" 

extern int yylex(void);
extern int line_num;
char *token;
char *token_func;
char*token_buffer;

%}

%union
{
	char* crepr;
}


%token <crepr> IDENT
%token <crepr> POSINT 
%token <crepr> REAL 
%token <crepr> STRING

%token KW_PROGRAM 
%token KW_BEGIN 
%token KW_END
%token KW_FUNCTION
%token KW_PROCEDURE
%token KW_RESULT
%token KW_ARRAY
%token KW_DO
%token KW_GOTO
%token KW_RETURN
%token KW_BOOLEAN
%token KW_ELSE
%token KW_IF
%token KW_OF
%token KW_REAL
%token KW_THEN
%token KW_CHAR
%token KW_FOR
%token KW_INTEGER
%token KW_REPEAT
%token KW_UNTIL
%token KW_VAR
%token KW_WHILE
%token KW_TO
%token KW_DOWNTO
%token KW_TYPE
%token TK_ASSIGN
%token BOOLEAN_TRUE
%token BOOLEAN_FALSE

%precedence CAST
%precedence KW_THEN
%precedence KW_ELSE

%left KW_OR OP_LOG_OR
%left KW_AND OP_LOG_AND
%left '=' OP_NEQ '<' '>' OP_LEQT OP_GEQT
%left '+' '-'
%left '*' '/' KW_DIV KW_MOD
%right KW_NOT OP_LOG_NOT



%start program

%type<crepr> sec_header
%type<crepr> subprogram
%type<crepr> procedure function
%type<crepr> procedure_decl function_decl
%type<crepr>  function_body 
%type<crepr> declaration
%type<crepr> program_decl  statements statement_list func_statements  statement_list2
%type<crepr> statement  function_stmt
%type<crepr> declaration_comp
%type<crepr> var_decl
%type<crepr> special_type
%type<crepr> var_decl_comp 
%type<crepr> types 
%type<crepr> dimensions 
%type<crepr> data_type
%type<crepr> basic_data_type
%type<crepr> var_id
%type<crepr> complex_cmd
%type<crepr> cmd_list
%type<crepr> if_stmt while_stmt for_stmt goto_cmd return_cmd repeat_stmt return_cmd2
%type<crepr> stmt_comp
%type<crepr> assign_cmd
%type<crepr> result_cmd 
%type<crepr> func_cmd 	
%type<crepr> func_cmd_arg
//%type<crepr> label_cmd

%type<crepr> expr
%type<crepr> unary
%type<crepr> element
%type<crepr> hooks_custom

%%
/*
Program structure
--------------------------------------------------------------------------------
*/
program:  program_decl sec_header  complex_cmd  '.'   		
{ 
	/* We have a successful parse! 
		Check for any errors and generate output. 
	*/
	if(yyerror_count==0) {
		puts(c_prologue);
		printf("/* program  %s */ \n\n", $1);
		printf("%s\n\n",$2);
		printf("int main() %s \n\n", $3);
	}
};


program_decl : KW_PROGRAM IDENT ';'  		{ $$ = $2; };

sec_header: 								{ $$ = ""; }
		  |sec_header  var_decl				{ $$ = template("%s %s\n", $1, $2); }
		  |sec_header  subprogram			{ $$ = template("%s %s", $1, $2); }
		  |sec_header ';' var_decl			{ $$ = template("%s %s\n", $1, $3); }
		  |sec_header ';' subprogram		{ $$ = template("%s %s", $1, $3); }
		  ;

complex_cmd: KW_BEGIN statements KW_END 	{ $$ = template("{\n%s}\n", $2); };

statements: 								{ $$ = ""; };
statements: statement_list 					{ $$ = $1; };

statement_list: statement 					{ $$ = template("%s\n", $1); } 
			  | statement_list ';' statement { $$ = template("%s%s\n", $1,$3); }                  
			  | statement_list  statement 	{ $$ = template("%s%s\n", $1, $2); }
			  ; 

statement: cmd_list							{ $$ = $1; }
		 | return_cmd						{ $$ = $1; }
		 | result_cmd						{ $$ = template("%s;",$1); }
		 ;	

subprogram: procedure						{ $$ = $1; }
		  | function 						{ $$ = $1; }
		  ;

/*
Variables declarations
--------------------------------------------------------------------------------
*/
basic_data_type:KW_INTEGER 					{ $$=template("int"); }					
         	   |KW_BOOLEAN					{ $$=template("int"); }				
          	   |KW_CHAR						{ $$=template("char"); }		
          	   |KW_REAL 					{ $$=template("double"); } 
			   ;
          						
dimensions: '[' POSINT ']'					{ $$ = template("[%s]",$2); } 		
		  | dimensions '[' POSINT ']'		{ $$ = template("%s[%s]",$1,$3); } 
		  ;	
			
var_decl: KW_VAR var_decl_comp 				{ $$ = template("%s;",$2); }	
		| var_decl_comp						{ $$ = template("%s;",$1); }
		| special_type						
		;
		 
var_decl_comp: var_id ':' basic_data_type ';'							{ $$ = template("%s %s",$3,$1); }
			 | var_id ':' KW_ARRAY KW_OF basic_data_type ';'			{ $$ = template("%s* %s",$5,$1); }	
			 | var_id ':' KW_ARRAY dimensions KW_OF basic_data_type ';'	{ $$ = template("%s %s%s",$6,$1,$4); }
			 | var_id ':' IDENT ';'										{ $$ = template("%s %s",$3,$1); }
			 ;


special_type: KW_TYPE types 				{ $$ = template("typedef %s;\n", $2);}
			| types 						{ $$ = template("typedef %s;\n", $1);}
			;

types: var_id '=' data_type ';' 										{ $$ = template("%s %s",$3,$1);}
	 | var_id '=' KW_FUNCTION '('declaration')' ':' data_type ';' 		{ $$ = template("%s %s(%s)",$8,$1,$5);} 
	 ;
	
var_id: IDENT
	  |var_id  ',' IDENT  					{ $$ = template("%s,%s",$1,$3); }
	  ;
	
/*
Procedures
--------------------------------------------------------------------------------
*/

procedure: procedure_decl sec_header complex_cmd ';'  					{ $$ = template("\n%s\n%s%s", $2, $1, $3); };

procedure_decl: KW_PROCEDURE IDENT '(' declaration ')' ';' 				{ $$ = template("\nvoid %s(%s)", $2, $4); };

declaration: 									{ $$ = ""; }
		   | declaration_comp					{ $$ = template("%s", $1); }
		   | declaration ';' declaration_comp	{ $$ = template("%s, %s", $1, $3); }
		   ;

declaration_comp: var_id ':' basic_data_type 	{ 	token_buffer=(char*)malloc(sizeof(char));
													token_buffer[0]='\0';
													while ((token = strsep(&$1, ",")) != NULL)
														token_buffer=concat(token_buffer,template("%s %s,",$3,token));

													trimEnd(token_buffer);
													$$=template("%s",token_buffer); 
												}
				|var_id ':' IDENT 				{	token_buffer=(char*)malloc(sizeof(char));
													token_buffer[0]='\0';
													while ((token = strsep(&$1, ",")) != NULL)
														token_buffer=concat(token_buffer,template("%s %s,",$3,token));
	
													trimEnd(token_buffer);
													$$=template("%s",token_buffer);
												 }	
				| var_id ':' KW_ARRAY KW_OF basic_data_type  {	
													token_buffer=(char*)malloc(sizeof(char));
													token_buffer[0]='\0';
													while ((token = strsep(&$1, ",")) != NULL)
														token_buffer=concat(token_buffer,template("%s* %s,",$5,token));
	
													trimEnd(token_buffer);
													$$=template("%s",token_buffer);
												 }	
				| var_id ':'  KW_ARRAY dimensions KW_OF basic_data_type  {	
													token_buffer=(char*)malloc(sizeof(char));
													token_buffer[0]='\0';
													while ((token = strsep(&$1, ",")) != NULL)
														token_buffer=concat(token_buffer,template("%s %s%s,",$6,token,$4));
	
													trimEnd(token_buffer);
													$$=template("%s",token_buffer);
												 }	;

/*
Functions
--------------------------------------------------------------------------------
*/

function: function_decl sec_header function_body  	{ $$ = template("\n%s\n%s%s", $2,$1,$3); };

function_decl: KW_FUNCTION IDENT '(' declaration ')' ':' data_type ';' 	{ $$ = template("%s %s(%s)", $7, $2, $4);
																		token_func=$7;}
			 | KW_FUNCTION IDENT '(' declaration ')' ':' IDENT ';' 		{ $$ = template("%s %s(%s)", $7, $2, $4);
																		token_func=$7;}
			 ;

data_type: basic_data_type
		 | KW_ARRAY KW_OF basic_data_type	 		{ $$=template("%s*",$3); }
		 | KW_ARRAY dimensions KW_OF basic_data_type{ $$=template("%s %s",$4,$2); }
		 ;
		
function_body:  KW_BEGIN func_statements KW_END ';'	{$$ = template("{\n%s result;\n%s}\n",token_func, $2);};

func_statements: 									{ $$ = ""; };
func_statements: statement_list2 					{ $$ = $1; };

statement_list2: function_stmt 						{ $$ = template("%s\n", $1); } 
			  | statement_list2 ';' function_stmt 	{ $$ = template("%s%s\n", $1,$3); }                  
			  | statement_list2  function_stmt 		{ $$ = template("%s%s\n", $1, $2); }; 	
	
function_stmt:  cmd_list
			 | return_cmd2
			 | result_cmd							{ $$ = template("%s;", $1); } 
			 ;

/*
Expressions
--------------------------------------------------------------------------------
*/

expr: unary
	| KW_NOT unary				{  $$ = template("not(%s)", $2); }
	| OP_LOG_NOT unary			{  $$ = template("!(%s)", $2); }
	| expr KW_MOD unary			{  $$ = template("%s %s %s", $1,"%",$3); }
	| expr KW_DIV unary			{  $$ = template("%s/%s",$1, $3); }
	| expr '/' unary			{  $$ = template("%s/%s", $1, $3); }
	| expr '*' unary			{  $$ = template("%s*%s",$1, $3); }
	| expr '+' unary			{  $$ = template("%s+%s", $1, $3); }
	| expr '-' unary			{  $$ = template("%s-%s", $1, $3); }
	| expr '=' unary			{  $$ = template("%s==%s", $1, $3); }
	| expr OP_NEQ unary			{  $$ = template("%s!=%s", $1, $3); }
	| expr '<' unary			{  $$ = template("%s<%s", $1, $3); }
	| expr '>' unary			{  $$ = template("%s>%s", $1, $3); }
	| expr OP_LEQT unary		{  $$ = template("%s<=%s", $1, $3); }
	| expr OP_GEQT unary		{  $$ = template("%s<=%s", $1, $3); }
	| expr KW_AND unary			{  $$ = template("%s &&  %s", $1, $3); }
	| expr OP_LOG_AND unary		{  $$ = template("%s && %s", $1, $3); }
	| expr KW_OR unary			{  $$ = template("%s or %s", $1, $3); }
	| expr OP_LOG_OR unary		{  $$ = template("%s || %s", $1, $3); }
	;

unary: element
	 | '-' element 				{  $$ = template("-(%s)", $2); }
	 | '+' element	 			{  $$ = template("+(%s)", $2); }
	 ;

element: POSINT
	   | REAL
	   | IDENT
	   | STRING									{ $$ = string_fl2c($1); }
	   | BOOLEAN_TRUE							{ $$ = template("%s", "1"); }	
	   | BOOLEAN_FALSE							{ $$ = template("%s", "0"); }
	   | '(' expr ')' 							{ $$ = template("(%s)", $2); }
	   | '(' basic_data_type ')'expr %prec CAST { $$ = template("(%s)%s",$2,$4); }
	   | IDENT hooks_custom 	 				{ $$ = template( "%s%s", $1, $2); }
	   | func_cmd 
	   ;

hooks_custom: '[' expr ']' 						{ $$ = template( "[%s]", $2); }
  			| hooks_custom '[' expr ']' 		{ $$ = template( "%s [%s]", $1, $3); }
			;

/*
Commands
--------------------------------------------------------------------------------
*/
cmd_list: if_stmt 						
		| assign_cmd  	         		
		| while_stmt					
		| for_stmt 						
		| goto_cmd 						
		| repeat_stmt 					
		| func_cmd 							{ $$ = template("%s;", $1); }
		//|label_cmd    		
		;

stmt_comp: return_cmd ';'					{ $$ = template("%s", $1); }
		 | assign_cmd 						{ $$ = template("%s", $1); }
		 | complex_cmd ';'					{ $$ = template("%s", $1); }
		 | result_cmd 						{ $$ = template("%s;", $1); }
		 | if_stmt
		 | while_stmt
		 | for_stmt
		 ;
		
assign_cmd: IDENT TK_ASSIGN expr  							{ $$ = template( "%s = %s;", $1, $3); }
		  | IDENT hooks_custom TK_ASSIGN expr  				{ $$ = template( "%s%s = %s;", $1,$2, $4); }
		  ;

if_stmt: KW_IF expr KW_THEN stmt_comp 						{ $$ = template( "if (%s)\n%s", $2, $4); }
  	   | KW_IF expr KW_THEN stmt_comp KW_ELSE stmt_comp 	{ $$ = template( "if (%s) \n%s\nelse\n%s",$2,$4,$6); }
	   ;

while_stmt: KW_WHILE expr KW_DO stmt_comp 					{ $$ = template( "while (%s)\n%s", $2, $4); };

repeat_stmt: KW_REPEAT stmt_comp KW_UNTIL expr 				{ $$ = template("do\n%swhile (%s);\n", $2, $4); };
  
for_stmt: KW_FOR IDENT TK_ASSIGN expr KW_TO expr KW_DO stmt_comp 		{ $$ = template("for(%s=%s;%s<=%s;%s++)\n%s", $2, $4, $2, $6, $2, $8); }
  		| KW_FOR IDENT TK_ASSIGN expr KW_DOWNTO expr KW_DO stmt_comp 	{ $$ = template("for(%s=%s;%s>=%s;%s--)\n%s", $2, $4, $2, $6, $2, $8); }
		;

goto_cmd: KW_GOTO IDENT ';' 				{ $$ = template(" %s;", $2); };

/*label_cmd: IDENT ':' stmt_comp 			{ $$ = template( "label: %s", $3); }*/


return_cmd:  KW_RETURN  					{ $$ = template( "return;"); };

return_cmd2:  KW_RETURN  					{ $$ = template( "return result;"); };

result_cmd: KW_RESULT TK_ASSIGN expr  		{ $$ = template( "result = %s", $3); };


func_cmd: IDENT '(' func_cmd_arg ')' 		{ $$ = template( "%s(%s)", $1, $3); };

func_cmd_arg:								{ $$ = template(""); }
			| expr 							{ $$ = template( "%s", $1); }
			| KW_RESULT						{ $$ = template( "result"); }
			| func_cmd_arg ',' expr         { $$ = template( "%s, %s", $1, $3); }
			;


%%
