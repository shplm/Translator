#include "ast.hpp"

extern int yylex();

int main(int argc, char const *argv[]) {
  if (!yylex()) {
    start(argc, argv);
  }
  return 0;
}
