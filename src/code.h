#ifndef CODE_H
#define CODE_H

#include "symbol_table.h"

/**
 * @brief Liste chainée conteant le code
 * 
 */
typedef struct _code_t {
    char* string;
    struct _code_t* next;
} code_t;

/**
 * @brief Initialise un code avec les string puis l'ajout a la liste chainé code
 * donnée en paramètre
 * 
 * @param code 
 * @param string 
 * @param ... 
 * @return code_t* 
 */
code_t* insert_code(code_t* code, int nargs, char* string, ...);

/**
 * @brief Initialisation d'une liste chainée appelée "code" contenant 
 * les paramètres.
 * 
 * @param str
 * @param ...
 * @return code_t* 
 */
code_t* init_code(int nargs, char* string, ...);

/**
 * @brief Permet de n'avoir qu'une seule chaine de caractère contenant tout le code
 * 
 * @param code 
 * @return code_t* 
 */
code_t* union_code(code_t* code);

/**
 * @brief Crée une nouvelle variable temporaire
 * 
 * @return char* 
 */
char* new_tmp();
/**
 * @brief Crée une nouvelle étiquette
 * 
 * @return char* 
 */
char* new_et();

/**
 * @brief Affiche le code dans le terminal et dans un fichier
 * 
 * @param ll 
 */
void print_code(code_t* ll);

/**
 * @brief Libère la mémoire alloué au code
 * 
 * @param ll 
 */
void free_code(code_t* ll);

/**
 * @brief Concatène 2 listes chainées
 * 
 * @param c1 
 * @param c2 
 * @return code_t* 
 */
code_t* concat_code(code_t* c1, code_t* c2);

/**
 * @brief Crée un code contenant les déclarations des variables temporaires
 * 
 * @param table 
 * @return code_t* 
 */
code_t* declare_var(symbol_t** table);

#endif