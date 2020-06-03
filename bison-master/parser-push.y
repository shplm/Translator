%{
#include <iostream>
#include <map>

#include "parser-push.hpp"

bool _error = false;
std::map<std::string, float> symbols;
extern int yylex();
void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}
%}

%locations
%define parse.error verbose

%define api.pure full
%define api.push-pull push

/* %define api.value.type { std::string* } */
%union {
  std::string* str;
  float val;
  int category;
}

%token <str> IDENTIFIER
%token <val> NUMBER
%token <category> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <category> LPAREN RPAREN SEMICOLON

%type <val> expression

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right
%nonassoc
%precedence  */

%start program

%%

program
  : program statement
  | statement
  ;

statement
  : IDENTIFIER EQUALS expression SEMICOLON { symbols[*$1] = $3; delete $1; }
  | error SEMICOLON  { std::cerr << "Error: bad statement on line " << @1.first_line << std::endl; _error = true; }
  ;

expression
  : LPAREN expression RPAREN { $$ = $2; }
  | expression PLUS expression { $$ = $1 + $3; }
  | expression MINUS expression { $$ = $1 - $3; }
  | expression TIMES expression { $$ = $1 * $3; }
  | expression DIVIDEDBY expression { $$ = $1 / $3; }
  | NUMBER { $$ = $1; /* std::cout << "Number recognized on line: " << @1.first_line << std::endl; */ }
  | IDENTIFIER { $$ = symbols[*$1]; delete $1; }
  ;

%%
