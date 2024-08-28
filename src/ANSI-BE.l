D                           [0-9]
L                           [a-zA-Z_]

%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}

%x comment

%%
"/*"                    BEGIN(comment);
<comment>.              ;
<comment>"*/"           BEGIN(INITIAL);  

"extern"                return EXTERN;
"goto"                  return GOTO;
"if"                    return IF;
"int"                   return INT;
"return"                return RETURN;
"void"                  return VOID;

{L}({L}|{D})*           yylval.string = strdup(yytext); return IDENTIFIER; 
{D}+                    yylval.number = atoi(yytext); return CONSTANT;

"<="                    return LE_OP;
">="                    return GE_OP;
"=="                    return EQ_OP;
"!="                    return NE_OP;

[ \t\v\n\f]             ;
.                       return yytext[0]; 
%%