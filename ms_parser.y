%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>		
#include "cgen.h"

extern int yylex(void);
extern char*  yytext;
extern int lineNum;

%}

%union
{
	char* crepr;
}


%token <crepr> TK_IDENT
%token <crepr> TK_ARITHMETIC 
%token <crepr> TK_STRING


//Keywords

%token KW_START
%token KW_CONST
%token KW_VAR
%token KW_VOID
%token KW_NUMBER
%token KW_STRING
%token KW_FUNCTION
%token KW_IF
%nonassoc KW_ELSE
%token KW_WHILE
%token KW_FOR
%token KW_CONTINUE
%token KW_BREAK
%token KW_RETURN
%token KW_BOOLEAN
%token KW_TRUE
%token KW_FALSE
%token KW_NULL
%right KW_NOT
%token KW_AND
%token KW_OR

//Operators

%left OP_ASSIGN
%left OP_PLUS
%left OP_MINUS;
%left OP_MULT;
%left OP_DIV;
%left OP_MOD;
%left OP_EQUAL;
%left OP_NOT_EQUAL;
%left OP_LESS;
%left OP_LESS_EQUAL;

%left DEL_SEMICOLON
%left DEL_LEFT_PARENTH
%left DEL_RIGHT_PARENTH
%left DEL_COMMA
%left DEL_LEFT_CURLY_BRACE
%left DEL_RIGHT_CURLY_BRACE
%left DEL_COLON


%left DEL_LEFT_CURLY_BRACKET
%left DEL_RIGHT_CURLY_BRACKET


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
decl_list_item_id OP_ASSIGN expr { $$ = template("%s =%s", $1, $3);}
;

decl_list_item_id: TK_IDENT { $$ = $1; } 
| TK_IDENT '['']' { $$ = template("*%s", $1); }
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


int main () 
{

	int token;
	while ( (token = yylex()) != EOF )
	printf("\tLine %d Token %d: %s\n", lineNum, token, yytext);
	
	if ( yyparse() != 0 )
    	printf("Rejected!\n");


}