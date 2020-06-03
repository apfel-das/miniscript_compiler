%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "ms_parser.tab.h"
#include "cgen.h"




int lineNum = 1; 
void printError();

%}

IDENT [a-zA-Z_][0-9a-zA-Z_]*
DIGIT  [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ([+-]?"."{NUMBER})|([+-]?{NUMBER}("."{NUMBER}?)?)
ARITHMETIC {DECIMAL}([eE][+-]?{NUMBER})?
STRING  \"[^'\n]*\"

%x comment
%x line_comment

%%
start         	return KW_START;
const 		  	return KW_CONST;
var			  	return KW_VAR;
void          	return KW_VOID;
number        	return KW_NUMBER;
string        	return KW_STRING;
function      	return KW_FUNCTION;
if 			  	return KW_IF;
else 		  	return KW_ELSE;
for 		  	return KW_FOR;
while		  	return KW_WHILE;
continue	  	return KW_CONTINUE;
break 			return KW_BREAK;
return 			return KW_RETURN;
boolean			return KW_BOOLEAN;
true			return KW_TRUE;
false 			return KW_FALSE;
null 			return KW_NULL;
not				return KW_NOT;
and				return KW_AND;
or 				return KW_OR;





{IDENT}  	    { yylval.crepr = strdup(yytext); return TK_IDENT; }
{ARITHMETIC}	{ yylval.crepr = strdup(yytext); return TK_ARITHMETIC; }
{STRING}		{ yylval.crepr = strdup(yytext); return TK_STRING; }

"="		        return OP_ASSIGN;
"+"				return OP_PLUS;
"-"				return OP_MINUS;
"*"				return OP_MULT;
"/"       		return OP_DIV;
"%"       		return OP_MOD;
"**"
"=="			return OP_EQUAL;
"!="			return OP_NOT_EQUAL;
"<"				return OP_LESS;
"<="			return OP_LESS_EQUAL;

":"		        return DEL_COLON;
","           	return DEL_COMMA;
";"				return DEL_SEMICOLON;
"("				return DEL_LEFT_PARENTH;
")"				return DEL_RIGHT_PARENTH;
"{"				return DEL_LEFT_CURLY_BRACE;
"}"				return DEL_RIGHT_CURLY_BRACE;
"["				return DEL_LEFT_CURLY_BRACKET;
"]"				return DEL_RIGHT_CURLY_BRACKET;

		/* Comments, Line comments, and some other stuff. [untabbing the comment will result to a flex error.hu]*/

"//"					{BEGIN(line_comment);}
<line_comment>[^\n]*  									/* eat all line comments */
<line_comment>\n 		{++lineNum; BEGIN(INITIAL);}	/* what to do when a line commnent, exceeds the line limit.*/

"/*"					{BEGIN(comment);}
<comment>[^*\n]*        								/* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   								/* eat up '*'s not followed by ')'s */
<comment>\n             ++lineNum;
<comment>"*"+"/"        {BEGIN(INITIAL);}


[ \r\t]							/* skip whitespace, return on start */
\n 					++lineNum;	/* Line count should respectivelly be increased */	
<<EOF>> 			return EOF; /* This should mark the end of a file. */

.             		{printError();}


%%


		/*Pure C code, if any..[no need for indenting here.]*/


		/*
			A function to print info about an error, if any..
		*/

void printError()
{
	printf("Line %d Lexical Error: Unrecognized literal %s\n" , lineNum, yytext); 
  	exit(-1);
}
