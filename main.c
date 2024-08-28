#include <stdio.h>
#include <string.h>
#include "src/symbol_table.h"
#include "src/attribut.h"
#include "y.tab.h"

#define SIZE 127
#define DEBUG 1

symbol_t* table[SIZE];
symbol_t* table_f[SIZE];
FILE *dst_file;
int index_variable = 0;

int main(int argc, char* argv[]) {
    FILE *src_file;
    
    // #ifdef YYDEBUG
    // yydebug = 1;
    // #endif

    src_file = fopen(argv[1], "r");
    dst_file = fopen(argv[2], "w");
    reset_table(table);
    reset_table(table_f);
    init_table(table);

    if (src_file == NULL || dst_file == NULL) {
        fprintf(stderr, "Error: impossible to open the file.\n");
        #if DEBUG
            yyparse();
        #endif

    } else {
        stdin = src_file;

        yyparse();

        fclose(src_file);
        fclose(dst_file);
    }

    return 1;
}

