all: compilefe compilebe clean

compilebe:
	flex src/ANSI-BE.l
	bison -dv src/structbe.y -o y.tab.c
	gcc lex.yy.c y.tab.c -o backend -lfl

compilefe:
	flex src/ANSI-FE.l
	bison -dv src/structfe.y -o y.tab.c --report=all -Wconflicts-sr
	gcc -DYYDEBUG=1 -g3 src/attribut.c src/code.c src/symbol_table.c lex.yy.c y.tab.c main.c -lfl -o frontend

clean:
	rm -rf y.tab.* lex.yy.c

lexer:
	flex src/ANSI-BE.l
	gcc -lfl lex.yy.c

zip:
	tar -zcvf Projet-mirzazad.tar.gz main.c readme.txt testing.sh src/*.h src/*.c src/*.l src/*.y makefile RAPPORT* tests/*
