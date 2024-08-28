#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "code.h"

int cpt_tmp = 0; // Compteur pour les variables temporaire ti
int cpt_etq = 0; // Compteur pour les étiquettes du code 3 adresses

code_t* liste(int nargs, char* string, ...) {
    code_t* code;
    char *tmp, *next_args;
    va_list lst;

    code = malloc(sizeof(code_t));
    // tmp = (char*) malloc(sizeof(string));
    next_args = string;

    va_start(lst, string);
    for (int i = 0; i < nargs; i++) {
        // tmp = (char*) realloc(tmp, sizeof(tmp) + sizeof(next_args));
        // strcat(tmp, next_args);

        printf("next args : %s\n", next_args);

        next_args = va_arg(lst, char*);
    }
    va_end(lst);

    code->string = string;
    code->next = NULL;

    return code;
}

code_t* concat_code(code_t* c1, code_t* c2) {
    code_t* first_code;

    /* On cherche le dernier élément de c1 */
    first_code = c1;
    while (c1->next != NULL) {
        c1 = c1->next;
    }

    /* On ajoute a la fin de notre liste la deuxième liste */
    c1->next = c2;

    return first_code;
}

// Pour les nargs = 1, ça génére un code de 2 éléments avec le deuxième éléments a (null)
code_t* init_code(int nargs, char* string, ...) {
    code_t* code;
    code_t* tmp_code;
    va_list lst;

    /* On initilialise les données */
    code = (code_t*) malloc(sizeof(code_t));
    tmp_code = (code_t*) malloc(sizeof(code_t));
    code->string = strdup(string);
    code->next = tmp_code;

    /* On parcours la liste de paramètre */
    va_start(lst, string);
    for (int i = 1; i < nargs; i++) {
        tmp_code->string = va_arg(lst, char*);
        tmp_code->next = (code_t*) malloc(sizeof(code_t));
        tmp_code = tmp_code->next;
    }
    va_end(lst);

    tmp_code = NULL; // Permet d'avoir le dernier pointeur sur NULL

    return code;
}

// code_t* init_code(int nargs, char* string, ...) {
//     code_t* code;
//     code_t* tmp_code;
//     va_list lst;

//     /* On initilialise les données */
//     code = (code_t*) malloc(sizeof(code_t));
//     tmp_code = (code_t*) malloc(sizeof(code_t));
//     code->string = "";

//     /* On parcours la liste de paramètre */
//     va_start(lst, string);
//     for (int i = 0; i < nargs; i++) {
//         tmp_code->string = va_arg(lst, char*);
//         tmp_code->next = (code_t*) malloc(sizeof(code_t));
//         tmp_code = tmp_code->next;
//     }
//     va_end(lst);

//     tmp_code = NULL; // Permet d'avoir le dernier pointeur sur NULL

//     return code;
// }

code_t* insert_code(code_t* code, int nargs, char* string, ...) {
    code_t* first_code;
    char* nextarg;
    va_list lst;

    /* On cherche le dernier élément de code */
    first_code = code;
    while (code->next != NULL) {
        code = code->next;
    }

    nextarg = string;

    /* On parcours la liste de paramètre pour mettre à jour le dernier élément de la liste */
    va_start(lst, string);
    for (int i = 0; i < nargs ; i++) {
        code->next = (code_t*) malloc(sizeof(code_t));
        code->string = nextarg;
        code = code->next;

        nextarg = va_arg(lst, char*);
    } 
    va_end(lst);

    /* Lorsqu'on a parcouru toute la liste, on peux faire pointer le dernier
    élément de code sur NULL */
    code->next = NULL;

    return first_code; // On retourne si besoin mais pas nécessaire
}

code_t* union_code(code_t* code) {
    code_t* first_elmt = code;

    while( code->next != NULL ) {
        first_elmt->string = realloc(first_elmt->string, sizeof(code->next->string));
        strcat(first_elmt->string, code->next->string);

        code = code->next;
    }

    free_code(first_elmt->next);

    return first_elmt;
}

void print_code(code_t* ll) {
    while (ll->next != NULL) {
        if (ll->string != NULL ) {
            printf("%s", ll->string);
            fprintf(dst_file, "%s", ll->string);
        }
        // printf("Pointeur : %p, string : %s, next : %p\n", ll, ll->string, ll->next);
        ll = ll->next;
    }
}

void free_code(code_t* ll) {
    code_t* tmp;
    code_t* next_tmp;
    
    tmp = ll;

    do {
        next_tmp = tmp->next;
        free(tmp);
        tmp = next_tmp;
    } while ( tmp );
}

char* new_tmp() {
    char* letter = "_t";
    char* index;
    char* tmp;

    index = malloc(sizeof(int));
    tmp = malloc(sizeof(letter) + sizeof(index));

    sprintf(index, "%d ", cpt_tmp);
    strcat(tmp, letter);
    strcat(tmp, index);
    cpt_tmp++;

    free(index);
    return tmp;
}

char* new_et() {
    char* letter = "etq";
    char* index;
    char* etq;

    index = malloc(sizeof(int));
    etq = malloc(sizeof(letter) + sizeof(index));

    sprintf(index, "%d ", cpt_etq);
    strcat(etq, letter);
    strcat(etq, index);
    cpt_etq++;

    free(index);
    return etq;
}

code_t* declare_var(symbol_t** table) {
    code_t* code = init_code(1, ""); 
    code_t* first_code = code;

    for(int i = 0; i < 127; i++){
        if(table[i] != NULL && table[i]->name[0] == '_'){
            insert_code(code, 4, dttostr(table[i]->datatype), " ", table[i]->name, ";\n");
        }
    } 

    return first_code;
}

// int main(void) {
//     code_t* code;

//     code = init_code(3, "t0 = 1;\n", "t1 = 2 * t0;\n", "t2 = t0 + t1;\n");
//     insert_code(code, 1, "a = t2;\n");
//     // code = init_code(1, "a = t2;\n");
//     // code = init_code(1, ";");

//     // while (code->next != NULL ) {
//     //     printf("%s", code->string);
//     //     code = code->next;
//     // }

//     print_code(code);

//     free_code(code);

// }