%{
#include <string.h>
#include <stdio.h>
#include "grammar.tab.h"

extern YYSTYPE yylval;
%}

H [0-9a-fA-F]
D [0-9]
O [0-7]
B [0-1]

%%

"+" { return SUM; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"%" { return MOD; }
"^" { return POW; }

"(" { return '('; }
")" { return ')'; }
";" { return ';'; }

{D}+      { yylval.number = strtol(yytext,   NULL, 10); return NUM; }
0[xX]{H}+ { yylval.number = strtol(yytext+2, NULL, 16); return NUM; }
0[dD]{D}+ { yylval.number = strtol(yytext+2, NULL, 10); return NUM; }
0[oO]{O}+ { yylval.number = strtol(yytext+2, NULL, 8);  return NUM; }
0[bB]{B}+ { yylval.number = strtol(yytext+2, NULL, 2);  return NUM; }

#.* ;
[ \t\n\v] ;
. ;

%%
