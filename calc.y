%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sym.h"
%}

%union {
    double dval;
    struct sym * symptr;
}

%token <symptr> NAME
%token <dval> NUMBER
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%type <dval> expression
%%
statement_list
    : statement '\n'
    | statement_list statement '\n'
    ;

statement
    : NAME '=' expression { $1->value = $3; }
    | expression { printf("= %g\n", $1); }
    ;

expression
    : expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression { 
	if($3 == 0){printf("divide by zero\n");}
	else{$$ = $1 / $3;}}
    | '-' expression %prec UMINUS { $$ = -$2; }
    | '(' expression ')' { $$ = $2; }
    | NUMBER
    | NAME { $$ = $1->value; }
    ;

%%

struct sym * sym_init (){
	sym * pi;
	sym * phi;
	pi = sym_new ("PI", 3.14159);
	phi = sym_new_loop (pi, "PHI", 1.61803);
	return pi;
}

struct sym * sym_new_loop (sym * sp, char * n, double val){
	sym * sp2;
	if (sp->next == NULL){
		sp->next = sym_new(n, val);
		return sp->next;
	}else{
		sp2 = sym_new_loop (sp->next, n, val);
		return sp2; 
	}
}

struct sym * sym_new (char * n, double val){
	struct sym * sp;
	sp->name = n;
	sp->value = val;
	sp->next = NULL;
	return sp;
}

struct sym * sym_lookup(char * s)
{
    char * p;
    struct sym * sp;
    int a=1;

    while (a == 1)
//    for (sp=sym_tbl; sp < &sym_tbl[NSYMS]; sp++)
    {
        if (sp->name && strcmp(sp->name, s) == 0){
            a=0;
	    return sp;
	}
        if (sp->name)
            continue;

        sp->name = strdup(s);
        return sp; 
    }
   
    yyerror("Too many symbols");
    exit(-1);
    return NULL; /* unreachable */
}

