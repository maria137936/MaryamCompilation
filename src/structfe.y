%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "src/symbol_table.h"
#include "src/code.h"
#include "src/attribut.h"


int yylex();
extern int yylineno;

int yyerror ( const char *s ) {
    printf("Yacc, erreur:%s\n", s);

    return 0;
}
%}


%define parse.error verbose

%union
{
    int number;
    char* string;
    symbol_t* symbol;
    code_t* code;

    type_t type;
    datatype_t datatype;

    attribut_t* attribut;
}

%token <string>IDENTIFIER 
%token <string>CONSTANT 
%token <string>SIZEOF

%token PTR_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token EXTERN
%token <datatype> INT VOID
%token <datatype> STRUCT 
%token IF ELSE WHILE FOR RETURN 

%precedence THEN
%precedence ELSE

%type <attribut> primary_expression
%type <attribut> postfix_expression
%type <attribut> unary_expression
%type <attribut> expression
%type <attribut> direct_declarator declarator
%type <attribut> logical_and_expression logical_or_expression
%type <attribut> equality_expression relational_expression
%type <attribut> additive_expression multiplicative_expression
%type <attribut> program
%type <attribut> argument_expression_list
%type <attribut> expression_statement
%type <attribut> struct_declaration_list struct_declaration struct_specifier
%type <attribut> type_specifier declaration_specifiers


%type <string> unary_operator

%type <code> function_definition external_declaration declaration
%type <code> compound_statement declaration_list statement_list
%type <code> statement 
%type <code> selection_statement iteration_statement jump_statement
%type <code> parameter_declaration parameter_list

%start program
%%

primary_expression
        : IDENTIFIER
        {       
                $$->symbole = lookup($1, table);

                if ($$->symbole == NULL) {
                        yyerror("La variable n'a pas été défini\n");
                } 
                $$->code = init_code(1, "");
                $$->symbole->is_constant = 1;
        }
        | CONSTANT
        {
                char* tmp = strdup($1);
                
                $$->symbole = (symbol_t*) malloc(sizeof(symbol_t));
                $$->symbole->datatype = INTEGER;
                $$->symbole->name = tmp;
                $$->code = init_code(1, "");
                $$->symbole->is_constant = 1;
        }
        | '(' expression ')'
        {
                $$ = $2;
        }
        ;

postfix_expression
        : primary_expression
        | postfix_expression '(' ')'
        {
                $$ = $1;
                insert_code($$->code, 1, "()");
                $$->symbole->is_constant = 0;
        }
        | postfix_expression '(' argument_expression_list ')'
        {
                $$ = $1;
                print_code($1->code);
                concat_code($$->code, $3->code);
                insert_code($$->code, 4, $1->symbole->name, "(", $3->symbole->name, ")");
        }
        | postfix_expression '.' IDENTIFIER
        | postfix_expression PTR_OP IDENTIFIER

argument_expression_list
        : expression
        {
                $$ = $1;
                if ($1->symbole->is_constant) {
                        insert_code($$->code, 1, $$->symbole->name);
                }
        }
        | argument_expression_list ',' expression
        {
                $$ = $1;
                if ($1->symbole->is_constant) {
                        insert_code($$->code, 2, ", ", $3->symbole->name);
                }
        }
        
unary_expression
        : postfix_expression
        | unary_operator unary_expression
        {
                $$ = $2;
                if ($$->symbole->is_constant) {
                        insert_code($$->code, 2, $1, $2->symbole->name);
                } else {
                        insert_code($$->code, 1, $1);
                }
                $$->symbole->is_constant = 0;
        }        
        | SIZEOF unary_expression
        {
                $$ = (attribut_t*) malloc(sizeof(attribut_t));
                if ($2->symbole->datatype == STRUCTURE){
                        char* tmp = malloc(sizeof(int));
                        sprintf(tmp, "%d", $2->taille);
                        $$->code = init_code(1, tmp);
                }
                else{
                        char* sizeoff = malloc(sizeof(dttostr($2->symbole->datatype)));
                        sprintf(sizeoff, "%ld", sizeof(dttostr($2->symbole->datatype)));
                        $$->code = init_code(1, sizeoff);
                }
                $$->symbole = $2->symbole;
                $$->symbole->is_constant = 0;
        }
        | SIZEOF '(' type_specifier ')'
        {
                $$ = (attribut_t*) malloc(sizeof(attribut_t));
                symbol_t* tmp = (symbol_t*) malloc(sizeof(symbol_t));
                tmp->name = "";
                char* sizeoff = malloc(sizeof(dttostr($3->symbole->datatype)));
                sprintf(sizeoff, "%ld", sizeof(dttostr($3->symbole->datatype)));
                $$->code = init_code(1, sizeoff);
                $$->symbole = tmp;
                $$->symbole->is_constant = 0;
        }
        ;

unary_operator
        : '&'   {$$ = "&";}
        | '*'   {$$ = "*";}
        | '-'   {$$ = "-";}
        ;

multiplicative_expression
        : unary_expression
        | multiplicative_expression '*' unary_expression
        {
                $$ = tac_binary_op($1, $3, "*");
                if ($$ == NULL) yyerror("Incompatible type");
                // $$->symbole->type = $1->symbole->type;
        }
        | multiplicative_expression '/' unary_expression
        {
                $$ = tac_binary_op($1, $3, "/");
                if ($$ == NULL) yyerror("Incompatible type");
        }
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression
        {       
                $$ = tac_binary_op($1, $3, "+");
                if ($$ == NULL) yyerror("Incompatible type");
        }
        | additive_expression '-' multiplicative_expression
        {
                $$ = tac_binary_op($1, $3, "-");
                if ($$ == NULL) yyerror("Incompatible type");
        }
        ;

relational_expression
        : additive_expression
        | relational_expression '<' additive_expression
        {
                $$ = tac_binary_op($1, $3, "<");
                if ($$ == NULL) yyerror("Incompatible type");
        }
        | relational_expression '>' additive_expression
        {
                $$ = tac_binary_op($1, $3, ">");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        | relational_expression LE_OP additive_expression
        {
                $$ = tac_binary_op($1, $3, "<=");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        | relational_expression GE_OP additive_expression
        {
                $$ = tac_binary_op($1, $3, ">=");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        ;

equality_expression
        : relational_expression
        | equality_expression EQ_OP relational_expression
        {
                $$ = tac_binary_op($1, $3, "==");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        | equality_expression NE_OP relational_expression
        {
                $$ = tac_binary_op($1, $3, "!=");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        ;

logical_and_expression
        : equality_expression
        | logical_and_expression AND_OP equality_expression
        {
                $$ = tac_binary_op($1, $3, "&&");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        ;

logical_or_expression
        : logical_and_expression
        | logical_or_expression OR_OP logical_and_expression
        {
                $$ = tac_binary_op($1, $3, "||");
                if ($$ == NULL) yyerror("Incompatible type");

        }
        ;

expression
        : logical_or_expression
        | unary_expression '=' expression
        {
                char* tmp = (char*) malloc(sizeof($1->symbole->name) + sizeof($3->symbole->name) + 5);
                
                $$ = $1;
                if ($3->symbole->is_constant) {
                        insert_code($$->code, 3, $1->symbole->name, "=", $3->symbole->name);
                } else {
                        insert_code($$->code, 2, $1->symbole->name, "=");
                }
                concat_code($$->code, $3->code);
        }
        ;

declaration
        : declaration_specifiers declarator ';'
        {       
                if ($1->symbole->is_extern) {
                        $$ = init_code(3, "extern ", dttostr($1->symbole->datatype), " ");
                } else {
                        $$ = init_code(2, dttostr($1->symbole->datatype), " ");
                }

                insert_code($2->code, 1, ";\n");
                concat_code($$, $2->code);
        }
        | struct_specifier ';'
        {
                $$ = init_code(1, ";\n");
        }
        ;

declaration_specifiers
        : EXTERN type_specifier
        {
                $$ = $2;
                $$->symbole->is_extern = 1;
        }
        | type_specifier
        {
                $$ = $1;
                $$->symbole->is_extern = 0;
        }
        ;

type_specifier
        : VOID
        {
                $$ = (attribut_t*) malloc(sizeof(attribut_t));
                symbol_t* tmp = (symbol_t*) malloc(sizeof(symbol_t));
                tmp->datatype = V;
                $$->symbole = tmp;
        }
        | INT
        {
                $$ = (attribut_t*) malloc(sizeof(attribut_t));
                symbol_t* tmp = (symbol_t*) malloc(sizeof(symbol_t));
                tmp->datatype = INTEGER;
                $$->symbole = tmp;
        }
        | struct_specifier
        {
                $$ = $1;
                $$->symbole->datatype = STRUCTURE;
        }
        ;

struct_specifier
        : STRUCT IDENTIFIER '{' struct_declaration_list '}'
        {
                $$ = $4;
        }
        | STRUCT '{' struct_declaration_list '}'
        {
                $$ = $3;
        }
        | STRUCT IDENTIFIER
        {
                $$ = (attribut_t*) malloc(sizeof(symbol_t));
                symbol_t* tmp = (symbol_t*) malloc(sizeof(symbol_t));
                tmp->name = strdup($2);

                $$->code = init_code(2, "void *", strdup($2));
                $$->symbole = tmp;
        }
        ;

struct_declaration_list
        : struct_declaration
        | struct_declaration_list struct_declaration
        {
                $$->taille += $2->taille;
        }
        ;

struct_declaration
        : type_specifier declarator ';'
        {
                $$->taille = sizeof(dttostr($1->symbole->datatype)) + sizeof($2->code);
        }
        ;

declarator
        : '*' direct_declarator
        {
                code_t* tmp;
                tmp = (code_t*) malloc(sizeof($2->code));
                tmp->string = "*";
                concat_code(tmp, $2->code);
                $2->code = tmp;
                $$ = $2;
                $$->symbole->type = POINTER;
        }
        | direct_declarator
        ;

direct_declarator
        : IDENTIFIER
        {       
                char* tmp = strdup($1);

                $$->symbole = insert($1, table);
                $$->symbole->is_constant = 1;
                $$->code = init_code(1, tmp);
        }
        | '(' declarator ')'
        {
                $$ = $2;
        }
        | direct_declarator '(' parameter_list ')'
        {
                $$ = $1;
                insert_code($$->code, 1, "(");
                concat_code($$->code, $3);
                insert_code($$->code, 1, ")");
        }
        | direct_declarator '(' ')'
        {
                $$ = $1;
                insert_code($$->code, 1, "()");
        }
        ;

parameter_list
        : parameter_declaration
        | parameter_list ',' parameter_declaration
        {
                $$ = $1;
                insert_code($$, 1, ", ");
                concat_code($$, $3);
        }
        

parameter_declaration
        : declaration_specifiers declarator
        {
                $2->symbole->datatype = $1->symbole->datatype;

                if ($1->symbole->is_extern) {
                        yyerror("Invalid syntax");
                } 

                $$ = init_code(1, dttostr($1->symbole->datatype));
                insert_code($$, 1, " ");
                concat_code($$, $2->code);
        }
        ;

statement
        : compound_statement
        | expression_statement
        {
                $$ = $1->code;
        }
        | selection_statement
        | iteration_statement
        | jump_statement 
        ;

compound_statement
        : '{' '}'
        {
                $$ = init_code(1, "");
        }
        | '{' statement_list '}'
        {
                $$ = init_code(1, "\n");
                // concat_code($$, declare_var(table));
                concat_code($$, $2);
                insert_code($$, 1, "\n");
        }
        | '{' declaration_list '}'
        {
                $$ = init_code(1, "\n");
                // concat_code($$, declare_var(table));
                concat_code($$, $2);
                insert_code($$, 1, "\n");
        }
        | '{' declaration_list statement_list '}'
        {
                $$ = init_code(1, "\n");
                // concat_code($$, declare_var(table));
                concat_code($$, $2);
                concat_code($$, $3);
                insert_code($$, 1, "\n");
        }
        ;

declaration_list
        : declaration
        | declaration_list declaration
        {
                concat_code($1, $2);
                $$ = $1;
        }
        ;

statement_list
        : statement
        | statement_list statement
        {
                concat_code($1, $2);
                $$ = $1;
        }
        ;

expression_statement
        : ';'
        {
                $$->code = init_code(1, ";\n");
        }
        | expression ';'
        {
                insert_code($1->code, 1, ";\n");
                $$ = $1;
        }
        ;

selection_statement
        : IF '(' expression ')' statement %prec THEN // On créé le THEN afin d'éviter probleme de shift/reduce.
        {
                char* etq_if = new_et();
                char* etq_else = new_et();
                
                if ($3->symbole->datatype != INT) {
                        yyerror("Condition must be an INT !");
                }
                $$ = $3->code;
                insert_code($$, 7, "if (!", $3->symbole->name, ") goto ", etq_else, "\n", etq_if, ":\n");
                concat_code($$, $5);
                insert_code($$, 2, etq_else, ":\n");
        }
        | IF '(' expression ')' statement ELSE statement
        {
                char* etq_true = new_et();
                char* etq_false = new_et();
                char* etq_def = new_et();
                
                if ($3->symbole->datatype != INT) {
                        yyerror("Condition must be an INT !");
                }
                $$ = $3->code;
                insert_code($$, 7, "if (!", $3->symbole->name, ") goto ", etq_false, "\n", etq_true, ":\n");
                concat_code($$, $5);
                insert_code($$, 5, "goto ", etq_def, "\n", etq_false, ":\n");
                concat_code($$, $7);
                insert_code($$, 5, "goto ", etq_def, "\n", etq_def, ":\n");
        }
        ;

iteration_statement
        : WHILE '(' expression ')' statement
        {
                char* etq1 = new_et();
                char* etq2 = new_et();
                char* condition = (char*) malloc(sizeof($3->code->string));
                char* boucle = (char*) malloc(sizeof($5->string));
                
                $$ = $3->code;
                sprintf(condition, "if !%s goto %s\n", $3->symbole->name, etq2);
                sprintf(boucle, "goto %s\n%s:\n", etq1, etq2);

                insert_code($$, 3, etq1, ":\n", condition);
                concat_code($$, $5);
                insert_code($$, 4, boucle, "\n", etq2, ":\n");
        }
        | FOR '(' expression_statement expression_statement expression ')' statement
        {
                char* etq1 = new_et();
                char* etq2 = new_et();
                char* condition = (char*) malloc(sizeof(100));
                char* increment = (char*) malloc(sizeof(100));
                char* boucle = (char*) malloc(sizeof(100));
                
                $$ = $3->code;
                sprintf(condition, "if !%s goto %s\n", $4->symbole->name, etq2);
                sprintf(boucle, "goto %s", etq1);

                concat_code($$, $4->code);
                insert_code($$, 3, etq1, ":\n", condition);
                concat_code($$, $7);
                concat_code($$, $5->code);
                insert_code($$, 4, boucle, "\n", etq2, ":\n");
        }
        ;

jump_statement
        : RETURN ';'
        {
                $$ = init_code(1, "return ;\n");
        }
        | RETURN expression ';'
        {
                char* tmp = malloc(sizeof(100));
                
                sprintf(tmp, "return %s;\n", $2->symbole->name);

                insert_code($2->code, 1, tmp);
                $$ = $2->code;
        }
        ;

program
        : external_declaration
        {
                print_code($1);
                free_code($1);
        }
        | program external_declaration
        {
                print_code($2);
                free_code($2);
        }
        ;

external_declaration
        : function_definition
        | declaration
        ;

function_definition
        : declaration_specifiers declarator compound_statement
        {
                if ($1->symbole->is_extern) {
                        $$ = init_code(3, "\nextern ", dttostr($1->symbole->datatype), " ");
                } else {
                        $$ = init_code(3, "\n", dttostr($1->symbole->datatype), " ");
                }

                concat_code($$, $2->code);
                insert_code($$, 1, "{\n");
                concat_code($$, declare_var(table_f));
                concat_code($$, $3);
                insert_code($$, 1, "}\n");
                reset_table(table_f);
        }
        ;

%%
/* 
                                    ___,,___
                                ,d8888888888b,_
                            _,d889'        8888b,
                        _,d8888'          8888888b,
                    _,d8889'           888888888888b,_
                _,d8889'             888888889'688888, /b
            _,d8889'               88888889'     `6888d 6,_
         ,d88886'              _d888889'           ,8d  b888b,  d\
       ,d889'888,             d8889'               8d   9888888Y  )
     ,d889'   `88,          ,d88'                 d8    `,88aa88 9
    d889'      `88,        ,88'                   `8b     )88a88'
   d88'         `88       ,88                   88 `8b,_ d888888
  d89            88,      88                  d888b  `88`_  8888
  88             88b      88                 d888888 8: (6`) 88')
  88             8888b,   88                d888aaa8888, `   'Y'
  88b          ,888888888888                 `d88aa `88888b ,d8
  `88b       ,88886 `88888888                 d88a  d8a88` `8/
   `q8b    ,88'`888  `888'"`88          d8b  d8888,` 88/ 9)_6
     88  ,88"   `88  88p    `88        d88888888888bd8( Z~/
     88b 8p      88 68'      `88      88888888' `688889`
     `88 8        `8 8,       `88    888 `8888,   `qp'
       8 8,        `q 8b       `88  88"    `888b
       q8 8b        "888        `8888'
        "888                     `q88b
                                  "888 
                                  
*/