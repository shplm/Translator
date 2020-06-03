%{
#include <iostream>
#include <vector>
#include <set>

struct _word {
  std::string lexeme;
  std::string category;
};

std::vector<struct _word> _words;
std::set<std::string> _ids;
bool _error = false;

void _save_word(std::string lexeme, std::string category) {
  struct _word word = { .lexeme = lexeme, .category = category};
  _words.push_back(word);
}
%}

%option noyywrap
%option yylineno

%%

[ \t\n]*    {}

[a-z][0-9]? {
              _save_word(yytext, "IDENTIFIER");
              _ids.insert(yytext);
            }

[0-9]+("."[0-9]+)? {
              _save_word(yytext, "NUMBER");
            }

"="         { _save_word(yytext, "EQUALS"); }
"+"         { _save_word(yytext, "PLUS"); }
"-"         { _save_word(yytext, "MINUS"); }
"*"         { _save_word(yytext, "TIMES"); }
"/"         { _save_word(yytext, "DIVIDEDBY"); }

";"         { _save_word(yytext, "SEMICOLON"); }
"("         { _save_word(yytext, "LPAREN"); }
")"         { _save_word(yytext, "RPAREN"); }

.           {
              std::cerr << "Invalid symbol on line " << yylineno
                << ":" << yytext << std::endl;
              _error = true;
            }

<<EOF>>     {
              if (_error) {
                return 1;
              } else {
                return 0;
              }
            }

%%

int main() {
  if (!yylex()) {
    std::cout << "Saw these tokens:" << std::endl;
    for (int i = 0; i < _words.size(); i++) {
      std::cout << _words[i].category << "\t\t" << _words[i].lexeme << std::endl;
    }

    std::cout << std::endl << "Saw these unique identifiers:" << std::endl;
    std::set<std::string>::iterator it;
    for (it = _ids.begin(); it != _ids.end(); it++) {
      std::cout << *it << std::endl;
    }
  }
}
