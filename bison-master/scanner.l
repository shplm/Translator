%{
#include <iostream>
#include <vector>
#include <set>
#include <cstdlib>

#include "parser.hpp"

struct _word {
  std::string lexeme;
  std::string category;
};

std::vector<struct _word> _words;
std::set<std::string> _ids;
bool _error = false;

void _save_word(const std::string& lexeme, const std::string& category) {
  struct _word _word = {
    .lexeme = lexeme,
    .category = category
  };
  _words.push_back(_word);
}

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
                return IDENTIFIER;
              }

[0-9]+("."[0-9]+)? {
                      yylval.val = atof(yytext);
                      return NUMBER;
                   }

"="           { yylval.category = EQUALS; return yylval.category; }
"+"           { yylval.category = PLUS; return yylval.category; }
"-"           { yylval.category = MINUS; return yylval.category; }
"*"           { yylval.category = TIMES; return yylval.category; }
"/"           { yylval.category = DIVIDEDBY; return yylval.category; }

";"           { yylval.category = SEMICOLON; return yylval.category; }
"("           { yylval.category = LPAREN; return yylval.category; }
")"           { yylval.category = RPAREN; return yylval.category; }

.             {
                std::cerr << "Invalid symbol on line " << yylineno
                  << ": " << yytext << std::endl;
                yylval.category = yytext[0]; return yylval.category;
              }

<<EOF>>       {
                if (_error) {
                  return 1;
                }
                return 0;
              }


%%

/* int main() {
  if (!yylex()) {
    std::vector<struct _word>::iterator wit;
    for (wit = _words.begin(); wit != _words.end(); ++wit) {
      std::cout << wit->lexeme << "\t" << wit->category << std::endl;
    }

    std::cout << std::endl << "Identifiers:" << std::endl;
    std::set<std::string>::iterator iit;
    for (iit = _ids.begin(); iit != _ids.end(); ++iit) {
      std::cout << *iit << std::endl;
    }
  }
} */
