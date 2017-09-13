%define api.pure full
%name-prefix "symparser_"

%token <l> LONG
%token <d> DOUBLE
%token <r> RAT
%token <p> PITCH
%token <sym> SYMBOL
%token PUSH POP
%token BACHNULL BACHNIL

%debug

%{
	//#define BACH_MAX
	#ifdef BACH_MAX
    #include "symparser.h"
    #else
    #include <stdio.h>
    #define parserpost printf
    #endif

%}

%union {
	long l;
	double d;
	t_rational r;
	t_pitch p;
	t_symbol *sym;
}


%{
    #include "symparser.tab.h"
    #include "symparser.lex.h"

    int yylex(YYSTYPE *yylval_param, yyscan_t myscanner);
    int yyerror(yyscan_t myscanner, t_llll **ll, t_llll_stack *stack, long *depth, char *s);
    YY_BUFFER_STATE symparser_scan_string(yyscan_t myscanner, char *buf);
    void symparser_flush_and_delete_buffer(yyscan_t myscanner, YY_BUFFER_STATE bp);
%}


%lex-param {void *scanner}
%parse-param {void *scanner}

%parse-param {t_llll **ll}
%parse-param {t_llll_stack *stack}
%parse-param {long *depth}

%%

sequence: 
| sequence term
;

term: LONG {
	llll_appendlong(*ll, $1);
	parserpost("parse: LONG %ld", $1);
} | DOUBLE {
	llll_appenddouble(*ll, $1);
	parserpost("parse: DOUBLE %lf", $1);
} | RAT {
	llll_appendrat(*ll, $1);
	parserpost("parse: RAT %ld/%ld", $1.num(), $1.den());
} | PITCH {
	llll_appendpitch(*ll, $1);
	parserpost("parse: degree: %c%d+%d/%d", 
		t_pitch::degree2name[$1.degree()], $1.octave(), $1.alter().num(), $1.alter().den());
} | SYMBOL {
	llll_appendsym(*ll, $1);
	parserpost("parse: symbol %s", $1->s_name);
} | BACHNULL {
    parserpost("parse: NULL");
} | BACHNIL {
	llll_appendllll(*ll, llll_get());
    parserpost("parse: NIL");
} | PUSH {
	(*depth)++;
	t_llll *newll = llll_get();
	llll_appendllll(*ll, newll, 0, WHITENULL_llll);
	llll_stack_push(stack, *ll);
	*ll = newll;
	parserpost("parse: PUSH");
} | POP {
	(*depth)--;
	if (*depth > 0) {
		t_llll *parent = (t_llll *) llll_stack_pop(stack);
		if (parent->l_depth <= (*ll)->l_depth)
			parent->l_depth = 1 + (*ll)->l_depth;
		*ll = parent;
	} else
		YYERROR;
	parserpost("parse: POPPE");
}
 
%%

void symbol_parse(char *buf, t_llll **ll, t_llll_stack *stack, long *depth)
{
    yyscan_t myscanner;
    YY_BUFFER_STATE bp;
    symparser_lex_init(&myscanner);
 	bp = symparser_scan_string(myscanner, buf);
    symparser_parse(myscanner, ll, stack, depth);
    symparser_flush_and_delete_buffer(myscanner, bp);
    symparser_lex_destroy(myscanner);
}

#ifndef BACH_MAX
int main(int argc, char **argv)
{
	int result = scrisp_parse("(1+2*3)*(4+5) ");

	printf("result: %d\n", result);
	return 0;
}
#endif

int yyerror(void *dummy, t_llll **ll, t_llll_stack *stack, long *depth, char *s)
{
	parserpost("error: %s\n", s);
	return 0;
}
