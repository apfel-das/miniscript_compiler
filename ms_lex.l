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
start         	{printf("TOKEN KEYWORD_START:\t%s\n", yytext); return KW_START;};
const 		  	{printf("TOKEN KEYWORD_CONST:\t%s\n", yytext); return KW_CONST;};
var			  	{printf("TOKEN KEYWORD_VAR:\t%s\n", yytext); return KW_VAR;};
void          	{printf("TOKEN KEYWORD_VOID:\t%s\n", yytext); return KW_VOID;};
number        	{printf("TOKEN KEYWORD_NUMBER:\t%s\n", yytext); return KW_NUMBER;};
string        	{printf("TOKEN KEYWORD_STRING:\t%s\n", yytext); return KW_STRING;};
function      	{printf("TOKEN KEYWORD_FUNCTION:\t%s\n", yytext); return KW_FUNCTION;};
if 			  	{printf("TOKEN KEYWORD_IF:\t%s\n", yytext); return KW_IF;};
else 		  	{printf("TOKEN KEYWORD_ELSE:\t%s\n", yytext); return KW_ELSE;};
for 		  	{printf("TOKEN KEYWORD_FOR:\t%s\n", yytext); return KW_FOR;};
while		  	{printf("TOKEN KEYWORD_WHILE:\t%s\n", yytext); return KW_WHILE;};
continue	  	{printf("TOKEN KEYWORD_CONTINUE:\t%s\n", yytext); return KW_CONTINUE;};
break 			{printf("TOKEN KEYWORD_BREAK:\t%s\n", yytext); return KW_BREAK;};
return 			return KW_RETURN;
boolean			return KW_BOOLEAN;
true			return KW_TRUE;
false 			return KW_FALSE;
null 			return KW_NULL;
not				return KW_NOT;
and				return KW_AND;
or 				return KW_OR;





{IDENT}  	    { yylval.crepr = strdup(yytext); printf("TOKEN IDENTIFIER: \t%s\n",yytext);  return TK_IDENT; }
{NUMBER}    	{ yylval.crepr = strdup(yytext); printf("TOKEN INTEGER: \t%s\n", yytext);    return TK_INT; }
{ARITHMETIC}	{ yylval.crepr = strdup(yytext); printf("TOKEN ARITHMETIC: \t%s\n", yytext); return TK_ARITHMETIC; }
{STRING}		{ yylval.crepr = strdup(yytext); printf("TOKEN STRING: \t%s\n", yytext);     return TK_STRING; }


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
"["				return DEL_LEFT_BRACKET;
"]"				return DEL_RIGHT_BRACKET;

		/* Comments, Line comments, and some other stuff. [untabbing the comment will result to a flex error.hu]*/

"//"					{BEGIN(line_comment);}
<line_comment>[^\n]*  									/* eat all line comments */
<line_comment>\n 		{++lineNum; BEGIN(INITIAL);}	/* what to do when a line commnent, exceeds the line limit.*/

"/*"					{BEGIN(comment);}
<comment>[^*\n]*        								/* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   								/* eat up '*'s not followed by '/'s */
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
