%{
#include <iostream>
#include <vector>
#include <set>
#include <cstdlib>

#include "parser-push.hpp"

YYSTYPE yylval;
YYLTYPE yylloc;
yypstate* pstate = yypstate_new();

#define PUSH_TOKEN(category) do {                      \
    int s = yypush_parse(pstate, category, &yylval, &yylloc);   \
    if (s != YYPUSH_MORE) {                         \
      yypstate_delete(pstate);                      \
      return s;                                     \
    }                                               \
  } while(0)

#define YY_USER_ACTION \
  yylloc.first_line = yylloc.last_line = yylineno;

%}

%option noyywrap
%option yylineno

%%

%{
  /* No code to put at the top of yylex(). */
%}

[ \t\n]*      /* Ignore whitespace. */

[a-z][0-9]?   {
                /* _save_word(yytext, "IDENTIFIER");
                _ids.insert(yytext); */

                yylval.str = new std::string(yytext, yyleng);
                PUSH_TOKEN(IDENTIFIER);
              }

[0-9]+("."[0-9]+)? {
                      yylval.val = atof(yytext);
                      PUSH_TOKEN(NUMBER);
                   }

"="           { yylval.category = EQUALS; PUSH_TOKEN(yylval.category); }
"+"           { yylval.category = PLUS; PUSH_TOKEN(yylval.category); }
"-"           { yylval.category = MINUS; PUSH_TOKEN(yylval.category); }
"*"           { yylval.category = TIMES; PUSH_TOKEN(yylval.category); }
"/"           { yylval.category = DIVIDEDBY; PUSH_TOKEN(yylval.category); }

";"           { yylval.category = SEMICOLON; PUSH_TOKEN(yylval.category); }
"("           { yylval.category = LPAREN; PUSH_TOKEN(yylval.category); }
")"           { yylval.category = RPAREN; PUSH_TOKEN(yylval.category); }

.             {
                std::cerr << "Invalid symbol on line " << yylineno
                  << ": " << yytext << std::endl;
                yylval.category = yytext[0]; PUSH_TOKEN(yylval.category);
              }

<<EOF>>       {
                int s = yypush_parse(pstate, 0, NULL, NULL);
                yypstate_delete(pstate);
                return s;
              }


%%
