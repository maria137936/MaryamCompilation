#include <stdio.h>
#include <stdlib.h>
#include "attribut.h"
#include "code.h"
#include "symbol_table.h"

attribut_t* tac_binary_op(attribut_t* a1, attribut_t* a2, char* op) {
    char* var = new_tmp();
    char* name1 = a1->symbole->name; 
    char* name2 = a2->symbole->name;
    char* tmp = (char*) malloc(sizeof(var) + sizeof(name1) + sizeof(name2) + sizeof(op) + 10);

    if (a1->symbole->datatype != a2->symbole->datatype) {
        return NULL;
    }

    sprintf(tmp, "%s = %s %s %s;\n", var, name1, op, name2);

    // concat_code(a1->code, a2->code);
    if (a2->code != NULL) {
        insert_code(a2->code, 1, tmp);
    } else {
        a2->code = init_code(1, tmp);
    }

    a2->symbole = insert(var, table_f);

    return a2;
}   

attribut_t* tac_unary_op(attribut_t* a1, attribut_t* a2, char* op) {
    char* var = new_tmp();
    char* name1 = a1->symbole->name;
    char* name2 = a2->symbole->name;
    char* tmp = (char*) malloc(sizeof(var) + sizeof(name1) + sizeof(name2) + sizeof(op) + 10);

    sprintf(tmp, "%s = %s %s %s", var, name1, op, name2);

    concat_code(a1->code, a2->code);
    insert_code(a1->code, 1, tmp);

    a1->symbole = insert(var, table);

    return a1;
}  

// int main (void) {
//     symbol_t* table[106];
//     char* e1 = "a = 19;";
//     char* e2 = "b = 10 + 2 * 20 / a;";
//     char* op = "+";
//     symbol_t* s1 = insert("a", table);
//     symbol_t* s2 = insert("b", table);
//     code_t* c1 = init_code(1, e1);
//     code_t* c2 = init_code(1, e2);
//     attribut_t* a1 = (attribut_t*) malloc(sizeof(attribut_t));
//     attribut_t* a2 = (attribut_t*) malloc(sizeof(attribut_t));

//     s1->name = "a";
//     s2->name = "b";
//     a1->symbole = s1;
//     a2->symbole = s2;
//     a1->code = c1;
//     a2->code = c2;

//     print_code(tac_binary_op(a1, a2, op)->code);
// }