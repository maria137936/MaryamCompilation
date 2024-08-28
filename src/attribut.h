#ifndef ATTRIBUT_H
#define ATTRIBUT_H

#include <stdio.h>
#include <stdlib.h>
#include "code.h"
#include "symbol_table.h"

/**
 * @brief Permet de stocker les attributs des non terminaux
 * 
 */
typedef struct _attribut_t {
    symbol_t* symbole; // On stocke le nom de la variable et d'autre information, évite de faire des lookup a chaque fois
    int taille;
    code_t* code;
} attribut_t;

/**
 * @brief Génère le code 3 adresses et vérifier les types
 * 
 * @param a1 
 * @param a2 
 * @param op 
 * @return attribut_t* 
 */
attribut_t* tac_binary_op(attribut_t* a1, attribut_t* a2, char* op);

#endif