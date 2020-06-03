#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
using namespace std;

extern int yylex();
extern vector<string> symbol;
extern vector<string> printout;
extern bool _error;

void print_vars(){
//I realized that's the only method to print that correspond as same as the example code it is :<
sort( symbol.begin(), symbol.end() );
    std::vector<string>::iterator it;
    for (it = symbol.begin(); it != symbol.end(); it++){
          std::cout << "float " << *it << ";" << endl;
        }
}

void print_prog(){
     std::vector<string>::iterator it; 
     for (it = printout.begin(); it != printout.end(); ++it){
        std::cout << *it << ' ';
     } 
}

void print_output(){
    std::vector<string>::iterator it;
    for (it = symbol.begin(); it != symbol.end(); it++){
      cout <<"std::cout << ";
      cout << "\""<< *it << ": \" << "; 
      cout << *it << " << std::endl;";
      cout << endl;
    }
}

int main() {
  if (!yylex()) {
    if (!_error) {
    cout << "#include <iostream>" << endl;
    cout << "int main() {" << endl;
    
      print_vars();

      cout << "\n\n/* Begin Program */\n" << endl;

      print_prog();

      cout << "\n\n/* End Program */\n" << endl;

      print_output();
          cout << "}" << endl;
    }

    return 0;
  } else {
    return 1;
  }
}
