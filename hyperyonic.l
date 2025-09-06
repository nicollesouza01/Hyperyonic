/* Definições de cabeçalhos C */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int linha = 1;

char* remover_aspas(char* s){
        
    int tam=strlen(s);

    if(tam<2){
        char *scopy =  malloc(1);
        if (scopy) scopy[0]='\0';
        return scopy;
    }

    char *scopy = malloc(tam-1);

    strncpy(scopy, s+1, tam-2);
    scopy[tam-2] = '\0';

    return scopy;
}

%}

/* Estados */
%x COMMENT 

/* Definições Regulares */
LETRA       [a-zA-Z_]
DIGITO      [0-9]
ESPECIAL    [^a-zA-Z]

%%

@:.* { /*Comentario de uma linha ignorado */ }

<INITIAL>"@/"   { BEGIN(COMMENT); }
<COMMENT>"/@"   { BEGIN(INITIAL); }
<COMMENT>"\n"   { linha++; } 
<COMMENT>.      { /*Comentario em bloco ignorado*/}

"Iniciando"        { printf("BEGIN_PROGRAM:\t\t%s\n", yytext); }
"Finalizando"      { printf("END_PROGRAM:\t\t%s\n", yytext); }
"leia"             { printf("READ_INPUT:\t\t%s\n", yytext); }
"escreva"          { printf("PRINT_OUTPUT:\t\t%s\n", yytext); }      

"++"        { printf("OP_INCREMENTAR:\t\t%s\n", yytext); }
"+="        { printf("OP_ATRIBUICAO_COMPOSTA:\t%s\n", yytext); }
"--"        { printf("OP_DECREMENTAR:\t\t%s\n", yytext); }
"-="        { printf("OP_ATRIBUICAO_COMPOSTA:\t%s\n", yytext); }
">="        { printf("OP_LOGICO:\t\t%s\n", yytext); }
"<="        { printf("OP_LOGICO:\t\t%s\n", yytext); }
"=="        { printf("OP_LOGICO:\t\t%s\n", yytext); }
"!="        { printf("OP_LOGICO:\t\t%s\n", yytext); }
"||"        { printf("OP_LOGICO:\t\t%s\n", yytext); }
"&&"        { printf("OP_LOGICO:\t\t%s\n", yytext); }

"&"         { printf("OP_MEMORIA: \t\t%s\n", yytext); }

"e"         { printf("OP_LOGICO:\t\t%s\n", yytext); }
"ou"        { printf("OP_LOGICO:\t\t%s\n", yytext); }
"para"      { printf("REPETICAO:\t\t%s\n", yytext); }
"enquanto"  { printf("REPETICAO:\t\t%s\n", yytext); }
"faz"       { printf("REPETICAO:\t\t%s\n", yytext); }
"retorne"   { printf("RETURN:\t\t\t%s\n", yytext); }
"int"       { printf("TIPO:\t\t\t%s\n", yytext); }
"float"     { printf("TIPO:\t\t\t%s\n", yytext); }
"char"      { printf("TIPO:\t\t\t%s\n", yytext); }
"string"    { printf("TIPO:\t\t\t%s\n", yytext); }
"bool"      { printf("TIPO:\t\t\t%s\n", yytext); }
"verdade"   { printf("BOOLEANO:\t\t%s\n", yytext); }
"falso"     { printf("BOOLEANO:\t\t%s\n", yytext); }
"se"        { printf("CONDICIONAL:\t\t%s\n", yytext); }
"senao"     { printf("CONDICIONAL:\t\t%s\n", yytext); }


{LETRA}({LETRA}|{DIGITO})* { printf("ID:\t\t\t%s\n", yytext); }


{DIGITO}+\.{DIGITO}+        { printf("FLOAT:\t\t\t%s\n", yytext); }
{DIGITO}+                   { printf("INTEIRO:\t\t%s\n", yytext); }


\"([^"\n])*\"   {
    yytext=remover_aspas(yytext);
    
    printf("STRING:\t\t\t%s\n", yytext); }
'([^'\n])'      { 
    yytext=remover_aspas(yytext);
    
    printf("CHAR:\t\t\t%s\n", yytext); }


"="         { printf("OP_ATRIBUICAO:\t\t%s\n", yytext); }
"+"         { printf("OP_ARITMETICO:\t\t%s\n", yytext); }
"*"         { printf("OP_ARITMETICO:\t\t%s\n", yytext); }
"-"         { printf("OP_ARITMETICO:\t\t%s\n", yytext); }
"/"         { printf("OP_ARITMETICO:\t\t%s\n", yytext); }
">"         { printf("OP_LOGICO:\t\t%s\n", yytext); }
"<"         { printf("OP_LOGICO:\t\t%s\n", yytext); }
"!"         { printf("OP_LOGICO:\t\t%s\n", yytext); }
"("         { printf("DELIMITADOR:\t\t%s\n", yytext); }
")"         { printf("DELIMITADOR:\t\t%s\n", yytext); }
"{"         { printf("DELIMITADOR:\t\t%s\n", yytext); }
"}"         { printf("DELIMITADOR:\t\t%s\n", yytext); }
","         { printf("DELIMITADOR:\t\t%s\n", yytext); }
";"         { printf("DELIMITADOR:\t\t%s\n", yytext); }
"\""        { printf("DELIMITADOR:\t\t%s\n", yytext); }
"'"         { printf("DELIMITADOR:\t\t%s\n", yytext); }


[ \t\r]+    { }
\n          { linha++; }


.           { printf("ERRO! Verifique o caractere '%s' que está na linha %d\n", yytext, linha); }

%%


int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    FILE *arquivo;

    if (argc > 1) {
        arquivo = fopen(argv[1], "r");
        if (!arquivo) {
            printf("ERRO! Seu arquivo %s não está abrindo.\n", argv[1]);
            return 1;
        }
        yyin = arquivo;
        printf(" <:><:><:> Analise Lexica do Arquivo: %s <:><:><:>\n\n", argv[1]);
    } else {
        printf("-> Analise Lexica (entrada padrao)...\n");
        printf("Digite o codigo pra gente iniciar (digite Ctrl+D quando finalizar):\n\n");
    }

    yylex();

    if (argc > 1) {
        fclose(arquivo);
    }

    printf("\n <3 Vc terminou sua Analise Lexica e ja pode criar seu projeto de Compiladores!\n");
    return 0;
}
