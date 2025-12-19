all: lexico.l sintatico.y
	clear
	flex -o lex.yy.c lexico.l
	bison -d sintatico.y
	gcc sintatico.tab.c lex.yy.c -o Hyperyonic -lm
	@echo "Compilação concluída! Execute: ./Hyperyonic exemplo.nic"

clean:
	rm -f lex.yy.c sintatico.tab.c sintatico.tab.h Hyperyonic