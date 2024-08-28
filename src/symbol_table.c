#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"

#define SIZE 103
#define MAX_STACKS 8

int hash(char* name) {
    int r = 0;
    int size = strlen(name);

    for (int i = 0; i< size ; i++) {
        r = ((r << 8) + name[i]) % SIZE;
    }

    return r;
}

void reset_table(symbol_t** table) {
    for ( int i = 0; i < SIZE; i++) {
        table[i] = NULL;
    }
}

symbol_t* lookup(char* name, symbol_t** table) {
    symbol_t * res = table[hash(name)];

    // while (res != NULL) {
    //     if (!strcmp(res->name, name)) {
    //         res = res->next;
    //     }
    // }

    if (res == NULL) {
        res = malloc(sizeof(symbol_t));
    }

    return res;
}

void print_table(symbol_t** table){
    // symbol_t* s;

    // s = malloc(sizeof(symbol_t));

    printf("\n%15s | %15s | %15s |\n", "TABLE", "NOM", "TYPE");

    for(int i = 0; i < SIZE; i++){
        if(table[i] != NULL){
            // s = table[i];
            
            printf("table[%d]\t| %15s | %15s |", i, table[i]->name, dttostr(table[i]->datatype));

            // while(table[i]->next != NULL){
            //     printf("[%table[i]]->", table[i]->name);
            //     table[i] = table[i]->next;
            // }

            // printf("NULL\n");
            printf("\n");
        }
    }

    // free(s);
}

symbol_t* insert(char* name, symbol_t** table) {
    int h;
    symbol_t* s;
    symbol_t* precedent;

    h = hash(name);
    s = table[h];
    precedent = NULL; 

    // En cas de collision on mets le symbole à la suite d'une liste chainé appelés "bucket"
    while (s != NULL) {
        if ( !strcmp( s->name, name ) ) return s;

        precedent = s;
        s = s->next;
    }

    if ( precedent == NULL ) {
        table[h] = (symbol_t*) malloc(sizeof(symbol_t));
        s = table[h];
    } else {
        precedent->next = (symbol_t*) malloc(sizeof(symbol_t));
        s = precedent->next;
    }

    s->name = strdup(name);
    s->next = NULL;

    return s;
}

void free_table(symbol_t** table) {

    for(int i = 0; i < SIZE; i++){
        if(table[i] != NULL){
            free(table[i]);
        }
    }
}

char* dttostr(datatype_t datatype) {
    switch (datatype)
    {
    case INTEGER:
        return "int";
    case V:
        return "void";
    case STRUCTURE:
        return "struct";
    default:
        return "unkwom_datatype";
    }
}

void init_table(symbol_t** table) {
    insert("malloc", table);
    insert("free", table);
}

// int main(void) {
//     symbol_t* table1[SIZE];
//     symbol_t* gp;
//     symbol_t* pp;

//     reset_table(table1);

//     pp = insert("petit poucet", table1);
//     gp = insert("grand poucet", table1);
//     // insert("grand pouceu", table1);

//     gp->value = 10;
//     // table1[101]->value = 20;

//     print_table(table1);

//     // pp = lookup("petit poucet", table1);
//     // // pp->value = 10;
//     // printf("Value qui tue:\t %d\n", pp->value);

//     free(gp);
//     free(pp);
//     // free_table(table1);

//     return 0;
// }
