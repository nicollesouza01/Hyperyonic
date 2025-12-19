%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>

    extern int yylex();
    extern int linha;
    extern FILE *yyin;
    void yyerror(const char *s);

    /* ASTs */
    
    // Tipos de nós
    typedef enum { typeCon, typeId, typeOpr, typeStr, typeIf, typeWhile, typeRead, typeWrite } nodeEnum;

    // Tabela de Símbolos
    struct Symbol {
        char *name;
        int type; // 1=int, 2=float, 3=string
        double value;
        char *strValue;
    };
    
    struct Symbol symTable[100];
    int symCount = 0;

    struct Symbol* findSymbol(char* name) {
        for(int i=0; i<symCount; i++) {
            if(strcmp(symTable[i].name, name) == 0) return &symTable[i];
        }
        return NULL;
    }

    void addSymbol(char* name, int type) {
        if(findSymbol(name)) return; 
        symTable[symCount].name = strdup(name);
        symTable[symCount].type = type;
        symTable[symCount].value = 0;
        symTable[symCount].strValue = NULL;
        symCount++;
    }

    // Estruturas dos nós
    typedef struct {
        double value;
    } conNodeType;

    typedef struct {
        char *value;
    } strNodeType;

    typedef struct {
        struct Symbol *s;
    } idNodeType;

    typedef struct {
        int oper;
        int nops;
        struct nodeTypeTag *op[3];
    } oprNodeType;

    typedef struct {
        struct nodeTypeTag *cond;
        struct nodeTypeTag *ifTrue;
        struct nodeTypeTag *ifFalse;
    } ifNodeType;

    typedef struct {
        struct nodeTypeTag *cond;
        struct nodeTypeTag *body;
    } whileNodeType;

    typedef struct nodeTypeTag {
        nodeEnum type;
        union {
            conNodeType con;
            strNodeType str;
            idNodeType id;
            oprNodeType opr;
            ifNodeType ifNode;
            whileNodeType whileNode;
        };
    } nodeType;

    //Criação de Nós
    nodeType *con(double value);
    nodeType *strNode(char *value);
    nodeType *id(char *name);
    nodeType *opr(int oper, int nops, nodeType *op1, nodeType *op2, nodeType *op3);
    nodeType *ifNode(nodeType *cond, nodeType *ifTrue, nodeType *ifFalse);
    nodeType *whileNode(nodeType *cond, nodeType *body);
    void freeNode(nodeType *p);
    
    
    void execute(nodeType *p);
%}

%union {
    double dval;
    int ival;
    char *sval;
    struct nodeTypeTag *nPtr;
}

%token <dval> NUM_REAL
%token <sval> STRING_LITERAL ID
%token <ival> TIPO
%token INICIANDO FINALIZANDO LEIA ESCREVA SE SENAO ENQUANTO
%token GE LE EQ NE AND OR

%type <nPtr> stmt stmt_list expr variable

%left OR
%left AND
%left EQ NE
%left '<' '>' GE LE
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%

program:
    INICIANDO declarations stmt_list FINALIZANDO {
        printf("\n--- EXECUÇÃO HYPERYONIC ---\n");
        execute($3);
        freeNode($3);
        printf("\n--- FIM DO PROGRAMA ---\n");
    }
    ;

declarations:
    /* vazio */
    | declarations declaration
    ;

declaration:
    TIPO ID ';' { addSymbol($2, $1); free($2); }
    ;

stmt_list:
    stmt            { $$ = $1; }
    | stmt_list stmt { $$ = opr(';', 2, $1, $2, NULL); }
    ;

stmt:
    ';'                     { $$ = opr(';', 2, NULL, NULL, NULL); }
    | variable '=' expr ';' { $$ = opr('=', 2, $1, $3, NULL); }
    | ESCREVA '(' expr ')' ';' { $$ = opr(ESCREVA, 1, $3, NULL, NULL); }
    | LEIA '(' variable ')' ';' { $$ = opr(LEIA, 1, $3, NULL, NULL); }
    | SE '(' expr ')' '{' stmt_list '}' { $$ = ifNode($3, $6, NULL); }
    | SE '(' expr ')' '{' stmt_list '}' SENAO '{' stmt_list '}' { $$ = ifNode($3, $6, $10); }
    | ENQUANTO '(' expr ')' '{' stmt_list '}' { $$ = whileNode($3, $6); }
    ;

variable:
    ID { $$ = id($1); free($1); }
    ;

expr:
    NUM_REAL            { $$ = con($1); }
    | STRING_LITERAL    { $$ = strNode($1); free($1); }
    | variable          { $$ = $1; }
    | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2, NULL, NULL); }
    | expr '+' expr     { $$ = opr('+', 2, $1, $3, NULL); }
    | expr '-' expr     { $$ = opr('-', 2, $1, $3, NULL); }
    | expr '*' expr     { $$ = opr('*', 2, $1, $3, NULL); }
    | expr '/' expr     { $$ = opr('/', 2, $1, $3, NULL); }
    | expr '<' expr     { $$ = opr('<', 2, $1, $3, NULL); }
    | expr '>' expr     { $$ = opr('>', 2, $1, $3, NULL); }
    | expr GE expr      { $$ = opr(GE, 2, $1, $3, NULL); }
    | expr LE expr      { $$ = opr(LE, 2, $1, $3, NULL); }
    | expr NE expr      { $$ = opr(NE, 2, $1, $3, NULL); }
    | expr EQ expr      { $$ = opr(EQ, 2, $1, $3, NULL); }
    | expr AND expr     { $$ = opr(AND, 2, $1, $3, NULL); }
    | expr OR expr      { $$ = opr(OR, 2, $1, $3, NULL); }
    | '(' expr ')'      { $$ = $2; }
    ;

%%

/* FUNÇÕES C */

// Funções Auxiliares(AST)
nodeType *con(double value) {
    nodeType *p = malloc(sizeof(nodeType));
    p->type = typeCon;
    p->con.value = value;
    return p;
}

nodeType *strNode(char *value) {
    nodeType *p = malloc(sizeof(nodeType));
    p->type = typeStr;
    p->str.value = strdup(value);
    return p;
}

nodeType *id(char *name) {
    nodeType *p = malloc(sizeof(nodeType));
    p->type = typeId;
    p->id.s = findSymbol(name);
    if(p->id.s == NULL) {
        printf("Erro: Variável '%s' não declarada.\n", name);
        exit(1);
    }
    return p;
}

nodeType *opr(int oper, int nops, nodeType *op1, nodeType *op2, nodeType *op3) {
    nodeType *p = malloc(sizeof(nodeType));
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    p->opr.op[0] = op1;
    p->opr.op[1] = op2;
    p->opr.op[2] = op3;
    return p;
}

nodeType *ifNode(nodeType *cond, nodeType *ifTrue, nodeType *ifFalse) {
    nodeType *p = malloc(sizeof(nodeType));
    p->type = typeIf;
    p->ifNode.cond = cond;
    p->ifNode.ifTrue = ifTrue;
    p->ifNode.ifFalse = ifFalse;
    return p;
}

nodeType *whileNode(nodeType *cond, nodeType *body) {
    nodeType *p = malloc(sizeof(nodeType));
    p->type = typeWhile;
    p->whileNode.cond = cond;
    p->whileNode.body = body;
    return p;
}

void freeNode(nodeType *p) {
    if (!p) return;
    if (p->type == typeOpr) {
        for (int i = 0; i < p->opr.nops; i++) freeNode(p->opr.op[i]);
    } else if (p->type == typeIf) {
        freeNode(p->ifNode.cond);
        freeNode(p->ifNode.ifTrue);
        freeNode(p->ifNode.ifFalse);
    } else if (p->type == typeWhile) {
        freeNode(p->whileNode.cond);
        freeNode(p->whileNode.body);
    } else if (p->type == typeStr) {
        free(p->str.value);
    }
    free(p);
}

// EXECUÇÃO DA AST (INTERPRETADOR)

double eval(nodeType *p) {
    if (!p) return 0;

    switch(p->type) {
        case typeCon: return p->con.value;
        case typeId:  return p->id.s->value;
        case typeStr: return 0;
        case typeOpr:
            switch(p->opr.oper) {
                case ENQUANTO: 
                    while(eval(p->opr.op[0])) eval(p->opr.op[1]); 
                    return 0;
                case SE: 
                    if(eval(p->opr.op[0])) eval(p->opr.op[1]);
                    else if(p->opr.nops > 2) eval(p->opr.op[2]);
                    return 0;
                case ESCREVA:
                    if (p->opr.op[0]->type == typeStr) {
                        printf("%s", p->opr.op[0]->str.value);
                    } else if (p->opr.op[0]->type == typeId && p->opr.op[0]->id.s->type == 3) {
                         printf("%s", p->opr.op[0]->id.s->strValue ? p->opr.op[0]->id.s->strValue : "null");
                    } else {
                        printf("%.2f", eval(p->opr.op[0]));
                    }
                    printf("\n");
                    return 0;
                case LEIA: {
                    struct Symbol *s = p->opr.op[0]->id.s;
                    if(s->type == 3) { // String
                         char buffer[255];
                         scanf("%s", buffer);
                         if(s->strValue) free(s->strValue);
                         s->strValue = strdup(buffer);
                    } else { // Numérico
                        scanf("%lf", &s->value);
                    }
                    return 0;
                }
                case ';': eval(p->opr.op[0]); eval(p->opr.op[1]); return 0;
                case '=': {
                    double val = eval(p->opr.op[1]);
                    p->opr.op[0]->id.s->value = val;
                    // Se o lado direito for string literal e o esquerdo variavel string
                    if(p->opr.op[1]->type == typeStr && p->opr.op[0]->id.s->type == 3) {
                        if(p->opr.op[0]->id.s->strValue) free(p->opr.op[0]->id.s->strValue);
                        p->opr.op[0]->id.s->strValue = strdup(p->opr.op[1]->str.value);
                    }
                    return val;
                }
                case UMINUS: return -eval(p->opr.op[0]);
                case '+': return eval(p->opr.op[0]) + eval(p->opr.op[1]);
                case '-': return eval(p->opr.op[0]) - eval(p->opr.op[1]);
                case '*': return eval(p->opr.op[0]) * eval(p->opr.op[1]);
                case '/': return eval(p->opr.op[0]) / eval(p->opr.op[1]);
                case '<': return eval(p->opr.op[0]) < eval(p->opr.op[1]);
                case '>': return eval(p->opr.op[0]) > eval(p->opr.op[1]);
                case GE:  return eval(p->opr.op[0]) >= eval(p->opr.op[1]);
                case LE:  return eval(p->opr.op[0]) <= eval(p->opr.op[1]);
                case NE:  return eval(p->opr.op[0]) != eval(p->opr.op[1]);
                case EQ:  return eval(p->opr.op[0]) == eval(p->opr.op[1]);
                case AND: return eval(p->opr.op[0]) && eval(p->opr.op[1]);
                case OR:  return eval(p->opr.op[0]) || eval(p->opr.op[1]);
            }
        case typeIf:
            if(eval(p->ifNode.cond)) execute(p->ifNode.ifTrue);
            else if(p->ifNode.ifFalse) execute(p->ifNode.ifFalse);
            return 0;
        case typeWhile:
            while(eval(p->whileNode.cond)) execute(p->whileNode.body);
            return 0;
    }
    return 0;
}

void execute(nodeType *p) {
    eval(p);
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro Sintático na linha %d: %s\n", linha, s);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror(argv[1]); return 1; }
        yyin = f;
    }
    yyparse();
    if (argc > 1) fclose(yyin);
    return 0;
}