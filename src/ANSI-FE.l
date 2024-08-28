D                       [0-9]
L                       [a-zA-Z_]

%{ 
#include <stdio.h>
#include <string.h>
#include "src/symbol_table.h"
#include "src/attribut.h"
#include "y.tab.h"

%}
%x comment

%%

"/*"                    BEGIN(comment);
<comment>.              ;
<comment>"*/"           BEGIN(INITIAL);  

"else"                  return ELSE;
"extern"                return EXTERN;
"for"                   return FOR;
"if"                    return IF;
"int"                   return INT;
"return"                return RETURN;
"sizeof"                return SIZEOF;
"struct"                return STRUCT;
"void"                  return VOID;
"while"                 return WHILE;

{L}({L}|{D})*           { 
    yylval.string = strdup(yytext); // on obtient un invalid write
    return IDENTIFIER; 
}
{D}+                    {
    yylval.string = strdup(yytext);
    return CONSTANT;
}

"->"                    return PTR_OP;
"&&"                    return AND_OP;
"||"                    return OR_OP;
"<="                    return LE_OP;
">="                    return GE_OP;
"=="                    return EQ_OP;
"!="                    return NE_OP;

[ \t\v\n\f\r]             ;
.                       return yytext[0]; 
%%