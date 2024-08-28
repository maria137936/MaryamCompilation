#include "code.h"

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

/**
 * @brief Stocke la famille d'un symbole
 * 
 */
typedef enum _type_t {
    VARIABLE, FUNCTION, POINTER
} type_t;

/**
 * @brief Stocke le type d'un symbole
 * 
 */
typedef enum _datatype_t {
    INTEGER, CONST, V, STRUCTURE
} datatype_t;

/**
 * @brief Permet de stocker les Identifiers rencontrés
 * 
 */
typedef struct _symbol_t {
    type_t type;
    datatype_t datatype;
    char* name;

    int nb_args;
    int is_extern;
    int is_constant; 

    // code_t* code;

    struct _symbol_t* next;
} symbol_t; 

/**
 * @brief Table de symboles globales
 * 
 */
extern symbol_t* table[];

/**
 * @brief Table de symbole pour les fonctions
 * 
 */
extern symbol_t* table_f[];

/**
 * @brief Fichier destinations
 * 
 */
extern FILE *dst_file;

/**
 * @brief 
 * 
 * @param name 
 * @return int 
 */
int hash(char* name);

/**
 * @brief To set all entry of the symbol_t table to NULL
 * 
 * @param table 
 */
void reset_table(symbol_t** table);

/**
 * @brief To search for a name and return pointer to its entry
 * 
 * @param name
 * @return symbol_t* 
 */
symbol_t* lookup(char* name, symbol_t** table);

void print_table(symbol_t** table);

/**
 * @brief To insert a name in a symbol_t table and return a pointer to its entry
 * 
 * @param name 
 * @param table 
 * @return symbol_t*
 */
symbol_t* insert(char* name, symbol_t** table);

/**
 * @brief datatype to string
 * 
 * @param datatype 
 * @return char* 
 */
char* dttostr(datatype_t datatype);

/**
 * @brief Initialise tout les éléments d'une table sur NULL
 * 
 * @param table 
 */
void init_table(symbol_t** table);

#endif