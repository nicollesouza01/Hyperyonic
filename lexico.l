%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sintatico.tab.h"

int linha = 1;

char* remover_aspas(char* s){
    int tam = strlen(s);
    if(tam < 2) return strdup("");
    char *scopy = malloc(tam-1);
    strncpy(scopy, s+1, tam-2);
    scopy[tam-2] = '\0';
    return scopy;
}
%}

%x COMMENT

LETRA       [a-zA-Z_]
DIGITO      [0-9]

%%

"@:".* { /* Comentario de uma linha ignorado */ }

<INITIAL>"@/"   { BEGIN(COMMENT); }
<COMMENT>"/@"   { BEGIN(INITIAL); }
<COMMENT>"\n"   { linha++; }
<COMMENT>.      { /* Conteudo do comentario em bloco ignorado */ }

"Iniciando"     { return INICIANDO; }
"Finalizando"   { return FINALIZANDO; }

"leia"          { return LEIA; }
"escreva"       { return ESCREVA; }

"se"            { return SE; }
"senao"         { return SENAO; }
"enquanto"      { return ENQUANTO; }

"int"           { yylval.ival = 1; return TIPO; }
"float"         { yylval.ival = 2; return TIPO; }
"string"        { yylval.ival = 3; return TIPO; }

">="            { return GE; }
"<="            { return LE; }
"=="            { return EQ; }
"!="            { return NE; }
"&&"            { return AND; }
"||"            { return OR; }

"="             { return '='; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
">"             { return '>'; }
"<"             { return '<'; }
"!"             { return '!'; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }
";"             { return ';'; }
","             { return ','; }

{LETRA}({LETRA}|{DIGITO})* { 
    yylval.sval = strdup(yytext);
    return ID; 
}

{DIGITO}+\.{DIGITO}+ { 
    yylval.dval = atof(yytext);
    return NUM_REAL; 
}

{DIGITO}+ { 
    yylval.dval = (double)atof(yytext); /* Tratando tudo como double pra simplificar operacoes */
    return NUM_REAL; 
}

\"([^"\n])*\" {
    yylval.sval = remover_aspas(yytext);
    return STRING_LITERAL;
}

[ \t\r]+    { /* Ignora espacos */ }
\n          { linha++; }

.           { printf("Erro lexico na linha %d: %s\n", linha, yytext); }

%%

int yywrap() { return 1; }