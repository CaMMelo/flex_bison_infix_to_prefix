%{
#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

extern int yylex();

void
yyerror(char *s)
{
    fprintf(stderr, "|~> ERROR: %s.\n", s);
}

char *buffer = NULL;
char **stack = NULL;
char **result = NULL;
long long calc[1024];
size_t sp = 0;
size_t cp = 0;
size_t rp = 0;

void
push(long long n)
{
    asprintf(&buffer, "%lld", n);
    stack[sp++] = buffer;
    calc[cp++] = n;
    buffer = malloc(1024*sizeof(char));
}

void
finish()
{
    result[rp++] = stack[--sp];
}

void pop();

%}

%union {
    long long number;
}

%token SUM
%token SUB
%token MUL
%token DIV
%token MOD
%token POW
%token <number> NUM

// %type <number> term pot factor expr

%%

start:
    %empty
    | expr ';' start { finish(); }
    ;

expr:
    expr SUM term   { pop(SUM); }
    | expr SUB term { pop(SUB); }
    | term
    ;

term:
    term MUL pot   { pop(MUL); }
    | term DIV pot { pop(DIV); }
    | term MOD pot { pop(MOD); }
    | pot
    ;

pot:
    pot POW factor { pop(POW); }
    | factor
    ;

factor:
    NUM  { push($1); }
    | '(' expr ')'
    ;

%%


void
pop(enum yytokentype op)
{
    long long b = calc[--cp];
    long long a = calc[--cp];
    char* bb = stack[--sp];
    char* aa = stack[--sp];
    switch(op) {
        case SUM:
            calc[cp++] = a + b;
            asprintf(&buffer, "+ %s %s", aa, bb);
            break;
        case SUB:
            calc[cp++] = a - b;
            asprintf(&buffer, "- %s %s", aa, bb);
            break;
        case MUL:
            calc[cp++] = a * b;
            asprintf(&buffer, "* %s %s", aa, bb);
            break;
        case DIV:
            calc[cp++] = a / b;
            asprintf(&buffer, "/ %s %s", aa, bb);
            break;
        case MOD:
            calc[cp++] = a % b;
            asprintf(&buffer, "%% %s %s", aa, bb);
            break;
        case POW:
            calc[cp++] = powl(a, b);
            asprintf(&buffer, "^ %s %s", aa, bb);
            break;
        default:
            break;
    }
    free(aa);
    free(bb);
    stack[sp++] = buffer;
    buffer = malloc(1024*sizeof(char));
}

int
main(int argc, char** argv)
{
    stack = malloc(1024 * sizeof(char*));
    result = malloc(1024 * sizeof(char*));
    buffer = malloc(1024 * sizeof(char));
    yyparse();
    
    for(int i=0; i<rp; i++)
        printf("|~> %s = %lld\n", result[rp-i-1], calc[i]);
}
