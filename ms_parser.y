%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>		
#include "cgen.h"

extern int yylex(void);
extern int line_num;
%}

%union
{
	char* crepr;
}


%token <crepr> IDENT
%token <crepr> REAL 
%token <crepr> STRING

%token KW_START
%token KW_CONST
%token KW_VAR
%token KW_VOID
%token KW_NUMBER
%token KW_STRING
%token KW_FUNCTION

%token ASSIGN

%start program

%type <crepr> decl_list body decl decl_list_item_id
%type <crepr> const_decl_list const_decl_list_item 
%type <crepr> type_spec
%type <crepr>  expr

%%

program: decl_list KW_FUNCTION KW_START '(' ')' ':' KW_VOID '{' body '}' { 
/* We have a successful parse! 
  Check for any errors and generate output. 
*/
	if (yyerror_count == 0) {
    // include the mslib.h file
	  puts(c_prologue); 
	  printf("/* program */ \n\n");
	  printf("%s\n\n", $1);
	  printf("int main() {\n%s\n} \n", $9);
	}
}
;

decl_list: 
decl_list decl { $$ = template("%s\n%s", $1, $2); }
| decl { $$ = $1; }
;

decl: 
KW_CONST const_decl_list ':' type_spec ';' { $$ = template("const %s %s;", $4, $2); }
;

const_decl_list: 
const_decl_list ',' const_decl_list_item { $$ = template("%s, %s", $1, $3); }
| const_decl_list_item { $$ = template("%s", $1); }
;

const_decl_list_item: 
decl_list_item_id ASSIGN expr { $$ = template("%s =%s", $1, $3);}
;

decl_list_item_id: IDENT { $$ = $1; } 
| IDENT '['']' { $$ = template("*%s", $1); }
;

type_spec: KW_NUMBER { $$ = "double"; }
| KW_STRING { $$ = "char" ;}
| KW_VOID { $$ = "void"; }
;

expr:  { $$=""; }
;

body: { $$="";}
;

%%
int main () {
  if ( yyparse() != 0 )
    printf("Rejected!\n");
}