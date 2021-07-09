%{
    #include <stdio.h>
    #include <math.h>
    
    int yylex(void);
    void yyerror(char const*);
%}
 
%define api.value.type {double}
%token NUM
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'
 
%%
 
input:
    %empty
    | input line
    ;
 
line:
    '\n'
    | exp '\n'      { printf ("\t%.10g\n", $1); }
    | error '\n'    { yyerrok; }
    ;
 
exp:
    NUM
    | exp '+' exp           { $$ = $1 + $3;      }
    | exp '-' exp           { $$ = $1 - $3;      }
    | exp '*' exp           { $$ = $1 * $3;      }
    | exp '/' exp           { $$ = $1 / $3;      }
    | '-' exp %prec NEG     { $$ = -$2;          }
    | exp '^' exp           { $$ = pow($1, $3);  }  
    | '(' exp ')'           { $$ = $2;           } 
    ;

%%
 
#include <ctype.h>
#include <stdlib.h>

int yylex(void) {
    int c = getchar();
    while (c == ' ' || c == '\t')
        c = getchar ();

    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        if (scanf("%lf", &yylval) != 1)
            abort();
        return NUM;
    } else if (c == EOF)
        return YYEOF;
    else
        return c;
}

int main(void) {
    return yyparse();
}

void yyerror(char const* s) {
    fprintf(stderr, "%s\n", s);
}
   