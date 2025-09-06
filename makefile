CC = gcc
FLEX = flex
CFLAGS = -Wall -g
LDFLAGS = -lfl

# Arquivos
LEXER_SOURCE = hyperyonic.l
LEXER_OUTPUT = lex.yy.c
EXECUTABLE = hyperyonic
TEST_FILE = codigo.yn

# Regra principal
all: $(EXECUTABLE)

# Compilar o analisador léxico
$(EXECUTABLE): $(LEXER_SOURCE)
	@echo "<:> Compilando Analisador Lexico HyperYoNic <:>"
	$(FLEX) $(LEXER_SOURCE)
	$(CC) $(CFLAGS) $(LEXER_OUTPUT) -o $(EXECUTABLE) $(LDFLAGS)
	@echo "<:> Compilação concluída <:>"

# Executar teste com arquivo
test: $(EXECUTABLE)
	@echo "<:> Execução de teste com o arquivo $(TEST_FILE) em linguagem HyperYoNic <:>"
	./$(EXECUTABLE) $(TEST_FILE)

# Executar com entrada interativa
run: $(EXECUTABLE)
	@echo "<:> Execução do analisador -> interagindo com HyperYoNic <:>"
	./$(EXECUTABLE)

# Limpar arquivos gerados
clean:
	@echo "<:> Limpando os arquivos gerados <:>"
	rm -f $(LEXER_OUTPUT) $(EXECUTABLE)
	@echo "<:> Limpeza concluída <:>"

# Mostrar ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make all    - Compila o analisador léxico"
	@echo "  make test   - Executa teste com arquivo codigo.yn"
	@echo "  make run    - Executa com entrada interativa"
	@echo "  make clean  - Remove arquivos gerados"
	@echo "  make help   - Mostra esta ajuda"

.PHONY: all test run clean help