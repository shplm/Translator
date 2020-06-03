%{

#include <iostream>

int num_chars = 0;
int num_words = 0;
int num_lines = 0;
int num_ints = 0;
%}

%option noyywrap

%%

\n    {
        num_lines++;
        num_chars++;
      }

"int" {
        num_ints++;
        REJECT;
      }

[^ \t\n]+ {
            num_words++;
            num_chars += yyleng;
          }

.         {
            num_chars++;
          }

%%

int main() {
  yylex();
  std::cout << num_lines << " lines" << std::endl;
  std::cout << num_words << " words" << std::endl;
  std::cout << num_chars << " chars" << std::endl;
  std::cout << num_ints << " ints" << std::endl;
  return 0;
}
