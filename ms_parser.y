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
%token <crepr> TK_INT


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


//Delimiters

%left DEL_SEMICOLON
%left DEL_LEFT_PARENTH
%left DEL_RIGHT_PARENTH
%left DEL_COMMA
%left DEL_LEFT_CURLY_BRACE
%left DEL_RIGHT_CURLY_BRACE
%left DEL_COLON
%left DEL_LEFT_BRACKET
%left DEL_RIGHT_BRACKET

%type <crepr> data_types

%type <crepr> specialExpr
%type <crepr> notExpr
%type <crepr> signExpr
%type <crepr> multpExpr
%type <crepr> additiveExpr
%type <crepr> relationalExpr

%type <crepr> logicalExpr

%type <crepr> expression


//statements
%type <crepr> __statement_list
%type <crepr> __statement_decl
%type <crepr> __statement_empty
%type <crepr> __statement
%type <crepr> __selection 
%type <crepr> __iteration
%type <crepr> __return
%type <crepr> __function
%type <crepr> func_var_list

%type <crepr> translation_unit
%type <crepr> external_declaration





%type <crepr> main_body // How a main function should look like.
%type <crepr> func_list 

%type <crepr> func_param
%type <crepr> func_ret
%type <crepr> main_func
%type <crepr> func_param_list


%type <crepr> decl
%type <crepr> const_decl_body
%type <crepr> const_decl_list
%type <crepr> const_decl_init
%type <crepr> var_decl_body
%type <crepr> var_decl_list
%type <crepr> var_decl_init
%type <crepr> decl_id
%type <crepr> type_spec

%type<crepr> program
%start program

%%

/*
	Initialization function declaration.  PWS ME GAMAEI ETSI TO LOW LEVEL?

*/

program: main_body
	{
		$$ = template("%s", $1);
		if( yyerror_count == 0)
		{
			//case everything is fine, write stuff out.
			FILE *fp = fopen("ms_parser_output.c", "w");
			

			printf("\n\t\t\t C source code:\n");
			printf("*********************************************************************************\n");
			printf("\n%s\n",$1 );
			printf("*********************************************************************************\n");
			fputs("#include <stdio.h>\n",fp);
			fputs(c_prologue, fp);
			fprintf(fp, "%s\n", $1);

			//close the damn file ptr.
			fclose(fp);


		}
		else
			printf("Error count: %d\n", yyerror_count);
	}
;

main_body:	main_func 								{ $$ = template("%s\n", $1); }
			| translation_unit main_func    { $$ = template("%s\n%s\n",$1,$2); }
  			| main_func translation_unit   { $$ = template("%s\n%s\n",$1,$2); }
  			| translation_unit main_func translation_unit   { $$ = template("%s\n%s\n%s\n",$1,$2,$3); };



translation_unit:	external_declaration                     	{ $$ = template("%s\n",$1); }
  					| translation_unit external_declaration    	{ $$ = template("%s\n%s\n",$1,$2); };  //Recursive declaration.

external_declaration: 	decl   									{ $$ = template("%s",$1); }  // Variables
  | func_list          											{ $$ = template("%s",$1); }; //	Functions
 

/*
	Declarations

*/
decl: 	KW_VAR var_decl_body { $$ = template("%s", $2); }
  		| KW_CONST const_decl_body { $$ = template("const %s", $2); };

/*
  The three function below handle const variable declaration
*/
const_decl_body
  : const_decl_list DEL_COLON type_spec DEL_SEMICOLON {  $$ = template("%s %s;", $3, $1); }
  ;

const_decl_list
  : const_decl_list DEL_COMMA const_decl_init { $$ = template("%s, %s", $1, $3 );}
  | const_decl_init
  ;

const_decl_init
  :  decl_id OP_ASSIGN data_types { $$ = template("%s = %s", $1, $3); }
  ;

var_decl_body
  : var_decl_list DEL_COLON type_spec DEL_SEMICOLON {  $$ = template("%s %s;", $3, $1); }
  ;

var_decl_list
  : var_decl_list DEL_COMMA var_decl_init { $$ = template("%s, %s", $1, $3 );}
  | var_decl_init
  ;

var_decl_init
  : decl_id
  | decl_id OP_ASSIGN data_types { $$ = template("%s = %s", $1, $3); }
  ; 

decl_id
  : TK_IDENT { $$ = template("%s", $1); }
  | TK_IDENT DEL_LEFT_BRACKET TK_INT DEL_RIGHT_BRACKET { $$ = template("%s[%s]", $1, $3); }

  ;

type_spec
  : KW_NUMBER      { $$ = template("%s", "double"); }
  | KW_BOOLEAN    { $$ = template("%s", "int"); }
  | KW_VOID		  { $$ = template("%s", "void"); }
  | KW_STRING     { $$ = template("%s", "char*"); }
  ;

/*
	Functions. Below is declared the format of any function the parser is able to distinguish and parse.
*/



func_list:	KW_FUNCTION decl_id DEL_LEFT_PARENTH func_param_list DEL_RIGHT_PARENTH DEL_COLON func_ret  DEL_LEFT_CURLY_BRACE __statement_empty DEL_RIGHT_CURLY_BRACE DEL_SEMICOLON { $$ = template("%s %s(%s) {\n%s\n};\n",$7, $2, $4, $9); }

main_func:	KW_FUNCTION KW_START DEL_LEFT_PARENTH DEL_RIGHT_PARENTH DEL_COLON type_spec DEL_LEFT_CURLY_BRACE __statement_empty  DEL_RIGHT_CURLY_BRACE { $$ = template("%s main(){\n%s}",$6,$8); }
			;
			
			

func_param_list
  : %empty              { $$ = template("");}
  | func_param DEL_COMMA func_param DEL_COLON type_spec DEL_COMMA func_param_list     { $$ = template("%s %s ,%s %s, %s",$5,$1,$5,$3,$7); }
  | func_param DEL_COMMA func_param DEL_COLON type_spec    { $$ = template("%s %s, %s %s", $5,$1,$5,$3); }       // arg0, arg1:common_type, arg4,arg5:common_type2 etc. [just to showcase]
  | func_param DEL_COLON type_spec DEL_COMMA func_param_list     { $$ = template("%s %s , %s", $3,$1,$5); }		// arg0:type, arg1:type,..argn:type						[basic multi-variable declaration]
  | func_param DEL_COLON type_spec     { $$ = template("%s %s", $3,$1); } 										// single param.										[basic single variable-declaration]	
  ;


func_param
  : TK_IDENT { $$ = template("%s", $1); }												// arg names.
  | TK_IDENT DEL_LEFT_BRACKET DEL_RIGHT_BRACKET { $$ = template("%s[]", $1); }			// array as arg.
  ;

func_ret
  : type_spec { $$ = template("%s", $1); }											//returning a variable.
  | DEL_LEFT_BRACKET DEL_RIGHT_BRACKET type_spec { $$ = template("%s*", $3); }		//returning an array.	
  ;

func_var_list
  : %empty                             		{ $$ = template("");} 					//nothing in there
  | func_var_list DEL_COMMA expression     	{ $$ = template("%s , %s", $1,$3); } 	//variables and expressions
  | expression                            	{ $$ = template("%s", $1);};         	// just logic expressions.

__function
  : TK_IDENT DEL_LEFT_PARENTH func_var_list DEL_RIGHT_PARENTH DEL_SEMICOLON            { $$ = template("%s(%s);\n",$1,$3); };
  

/*
	Statements. Below is declared the format of any valid statement, as valid can be concerned any statement the parser is able to distunghuish and parse.
*/

__statement_empty
  : %empty              						{ $$ = template("");}
  | __statement_list                            { $$ = template("%s", $1);};

__statement_list:	__statement_decl							{ $$ = template("\t%s\n", $1); }
  | 				__statement_list __statement_decl 			{ $$ = template("%s\n\t%s\n", $1, $2); };

__statement_decl
  : decl   { $$ = template("%s",$1); }
  | __statement { $$ = template("%s",$1); }
  ;

__statement
  : decl_id OP_ASSIGN expression DEL_SEMICOLON         { $$ = template("%s = %s;",$1, $3); } 
  | __selection      { $$ = template("%s",$1); }
  | __iteration           { $$ = template("%s",$1); }
  | __function        { $$ = template("%s",$1); }
  | __return         { $$ = template("%s",$1); }
  ;


 
__selection: 
  	KW_IF DEL_LEFT_PARENTH expression DEL_RIGHT_PARENTH DEL_LEFT_CURLY_BRACE __statement_empty DEL_RIGHT_CURLY_BRACE DEL_SEMICOLON                     														{ $$ = template("\tif(%s){\n%s\t}",$3,$6); } // if multi-line.
  | KW_IF DEL_LEFT_PARENTH expression DEL_RIGHT_PARENTH DEL_LEFT_CURLY_BRACE __statement_empty DEL_RIGHT_CURLY_BRACE KW_ELSE DEL_LEFT_CURLY_BRACE __statement_empty DEL_RIGHT_CURLY_BRACE DEL_SEMICOLON 	{$$  =template("if(%s){\n\t%s\t}\n\telse{\n\t%s\t}", $3, $6, $10);} //if-else multiline.
  | KW_IF DEL_LEFT_PARENTH expression DEL_RIGHT_PARENTH __statement { $$ = template("if(%s) \n\t\t%s\n\t",$3,$5); }
  | KW_ELSE __selection { $$ = template("else %s", $2);}
  | KW_ELSE DEL_LEFT_CURLY_BRACE __statement_empty DEL_RIGHT_CURLY_BRACE DEL_SEMICOLON {$$ = template("else {\n\t\n%s\n\t}", $3);};

  

__iteration
  : KW_WHILE DEL_LEFT_PARENTH expression DEL_RIGHT_PARENTH DEL_LEFT_CURLY_BRACE __statement_empty DEL_RIGHT_CURLY_BRACE DEL_SEMICOLON { $$ = template("while(%s){\n%s\n\t}",$3,$6); }
  ;

__return
  : KW_RETURN DEL_SEMICOLON               { $$ = template("return;"); }
  | KW_RETURN expression DEL_SEMICOLON { $$ = template("return %s;",$2); }
  ;


/*
	Expressions.
*/
data_types
  : TK_IDENT         		{ $$ = template("%s", $1); }
  | TK_ARITHMETIC           { $$ = template("%s", $1); }
  | TK_STRING             	{ $$ = template("%s", $1); }
  | TK_INT 					{ $$ = template("%s", $1); }
  | KW_TRUE           { $$ = "1"; }
  | KW_FALSE           { $$ = "0"; }
  ;


specialExpr
  : data_types
  | TK_IDENT DEL_LEFT_BRACKET expression DEL_RIGHT_BRACKET              { $$ = template("%s[%s]",$1,$3); }
  | DEL_LEFT_PARENTH expression DEL_RIGHT_PARENTH              { $$ = template("(%s)", $2); }
  | TK_IDENT DEL_LEFT_PARENTH  DEL_RIGHT_PARENTH              { $$ = template("%s()",$1); }
  | TK_IDENT DEL_LEFT_PARENTH expression  DEL_RIGHT_PARENTH              { $$ = template("%s(%s)",$1,$3); }
  ;


notExpr
  : specialExpr
  | KW_NOT signExpr  { $$ = template("! %s", $2); }
  ;

signExpr
  : notExpr
  | OP_PLUS notExpr    { $$ = template("+%s", $2); }
  | OP_MINUS notExpr    { $$ = template("-%s", $2); }
  ;

multpExpr
  : signExpr
  | multpExpr OP_MULT signExpr           { $$ = template("%s * %s", $1, $3); }
  | multpExpr OP_DIV signExpr           { $$ = template("%s / %s", $1, $3); }
  | multpExpr OP_MOD signExpr        { $$ = template("%s %% %s", $1, $3); }
  ;

additiveExpr
  : multpExpr
  | additiveExpr OP_PLUS multpExpr         { $$ = template("%s + %s", $1, $3); }
  | additiveExpr OP_MINUS multpExpr         { $$ = template("%s - %s", $1, $3); }
  ;

relationalExpr:		additiveExpr
  					| relationalExpr OP_EQUAL additiveExpr         { $$ = template("%s == %s", $1, $3); }
  					| relationalExpr OP_NOT_EQUAL additiveExpr   	{ $$ = template("%s != %s", $1, $3); }
  					| relationalExpr OP_LESS additiveExpr         	{ $$ = template("%s < %s", $1, $3); }
  					| relationalExpr OP_LESS_EQUAL additiveExpr   	{ $$ = template("%s <= %s", $1, $3); };



logicalExpr: 	relationalExpr
  				| logicalExpr KW_AND relationalExpr       { $$ = template("%s && %s", $1, $3); }
  				| logicalExpr KW_OR relationalExpr        { $$ = template("%s || %s", $1, $3); };

expression
  : logicalExpr  { $$ = template("%s", $1); }
  ;


%%


int main () 
{

	
	
	if ( yyparse() != 0 )
    	printf("Rejected!\n");
    else
    	printf("Accepted!\n");


}