#ifndef SYMTBL_H
#define SYMTBL_H

struct sym {
    char * name;
    double value;
    struct sym * next;
} * sym_tbl;

struct sym * print();
struct sym * sym_init();
struct sym * sym_new_loop (struct sym *, char *, double);
struct sym * sym_new (char *, double);
struct sym * sym_lookup(char *);

#endif /* SYMTBL_H */
