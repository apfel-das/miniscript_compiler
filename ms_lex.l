%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "ms_parser.tab.h"
#include "cgen.h"

int line_num = 1;

%}

IDENT [a-zA-Z_][0-9a-zA-Z_]*
DIGIT  [0-9]
NUM  {DIGIT}{DIGIT}*
DECIMAL ("."{NUM})|({NUM}("."{NUM}?)?)
STRING  '[^'\n]*'

%x comment

%%
start         return KW_START;
const 				return KW_CONST;
var						return KW_VAR;
void          return KW_VOID;
number        return KW_NUMBER;
string        return KW_STRING;
function      return KW_FUNCTION;

{IDENT}  	    { yylval.crepr = strdup(yytext); return IDENT; }

{STRING}			{ yylval.crepr = strdup(yytext); return STRING; }

"="		        return ASSIGN;
":"		        return ':';
","           return ',';
";"						return ';';
"."						return '.';
"("						return '(';
")"						return ')';

"{"						return '{';
"}"						return '}';

"//"[^\n]*  	/* eat line comments */

"/*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++line_num;
<comment>"*"+"/"        BEGIN(INITIAL);


[ \r\t]				/* skip whitespace */
\n 						++line_num;
<<EOF>> 			return EOF;

.             { yyerror("lexical error: unrecognized literal '%s'\n", yytext); }


%%


