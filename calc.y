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
%token <list> LIST
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
    : LIST {print();}
    | NAME '=' expression { $1->value = $3; }
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

int init=1;

void print (){
    if(init==1){
	sym_tbl = sym_init();
	init = 0;
    }	
	struct sym * temp = sym_tbl;
	int count=0;
	while(temp->next != NULL){
		count++;
		temp = temp->next;
	}
	count++;
	printf("num-syms: %d \n", count);
	temp = sym_tbl;
	while(temp->next != NULL){
		printf("\t%s => %f \n", temp->name, temp->value);
		temp = temp->next;
	}
	printf("\t%s => %f \n", temp->name, temp->value);
}

struct sym * sym_init (){
	struct sym * pi = malloc(sizeof(*pi));
	struct sym * phi = malloc(sizeof(*phi));
	phi = sym_new (NULL, "PHI", 1.61803);
	pi = sym_new_loop (phi, "PI", 3.14159);
	struct sym * head = phi;
	return head;
}

struct sym * sym_new_loop (struct sym * sp, char * n, double val){
	struct sym * newsp = malloc(sizeof(*newsp));
	if (sp->next == NULL){
		sp->next = sym_new(sp->next, n, val);
		return sp->next;
	}else{
	    if(n > sp->name){
		newsp = sym_new_loop (sp->next, n, val);
		return newsp;
	    }else{
		sp->next = sym_new(sp->next, n, val);
	    } 
	}
}

struct sym * sym_new (struct sym * nxtsp, char * n, double val){
	struct sym * sp = malloc(sizeof(*sp));
	sp->name = n;
	sp->value = val;
	sp->next = nxtsp;
	return sp;
}

struct sym * sym_lookup(char * s){
    if(init==1){
//	struct sym * head;
	sym_tbl = sym_init();
	init = 0;
    }
    struct sym * sp;
    sp=sym_tbl;
    int a=1;
    while (a == 1)
//    for (sp=sym_tbl; sp < &sym_tbl[NSYMS]; sp++)
    {
        if (strcmp(sp->name, s) == 0){
            if ((strcmp(s, "PHI")==0)||(strcmp(s, "PI")==0)){
		printf("assign to const\n");
	    }
	    a=0;
	    return sp;
	}
        if (sp->next != NULL){
        	sp = sp->next;
		return sp;
	}else{
        	sp = sym_new_loop (sp, s, 0);
		a=0;
		return sp;
	} 
    }
   
    yyerror("Too many symbols");
    exit(-1);
    return NULL; /* unreachable */
}

