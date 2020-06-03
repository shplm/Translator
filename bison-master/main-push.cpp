#include <iostream>
#include <map>

extern int yylex();
extern bool _error;
extern std::map<std::string, float> symbols;

int main() {
  if (!yylex()) {
    if (!_error) {
      std::cout << std::endl << "Symbol values:" << std::endl;
      std::map<std::string, float>::iterator it;
      for (it = symbols.begin(); it != symbols.end(); it++) {
        std::cout << it->first << " : " << it->second << std::endl;
      }
    }
    return 0;
  } else {
    return 1;
  }
}
