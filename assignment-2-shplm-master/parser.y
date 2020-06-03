%{
#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
#include "parser.hpp"

using namespace std;
vector<string> symbol;
vector<string> printout;
bool _error = false;

extern int yylex();
extern int yylineno;
void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << yylineno << "): " << err << std::endl;
}
%}

%locations
%define parse.error verbose

%define api.pure full
%define api.push-pull push

%union {
  std::string* str;
  float val;
  int category;
}

%token <str> IDENTIFIER
%token <str> FLOAT NUMBER

%token <category> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE TRUE FALSE
%token <category> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <category> SEMICOLON LPAREN RPAREN
%token <category> EQ NEQ GT GTE LT LTE COMMA COLON
%token <category> INDENT DEDENT NEWLINE

%type  <str> expression variable statement master
%type  <str> assign_clause while_clause break_clause
%type  <str> if_clause elseif_clause else_clause

// %left PLUS MINUS
// %left TIMES DIVIDEDBY
/* %right
%nonassoc
%precedence  */

%start program

%%

program
  : master       { printout.push_back(*$1); delete $1; }

master
  : statement          { $$ = $1; }
  | master statement   { string* tmp = new string(*$$ + "\n" + *$2); 
                          delete $$, $2;
                          $$ = tmp;
                        }
;

statement
  : assign_clause
  | if_clause
  | while_clause
  | break_clause
;

assign_clause
  : IDENTIFIER EQUALS expression NEWLINE                       { 
                                                                 if (find(symbol.begin(), symbol.end(), *$1) == symbol.end()){
                                                                  symbol.push_back(*$1);
                                                                }
                                                                $$ = new string(*$1 + " = " + *$3 + ";"); delete $1, $3;}
;

if_clause
  : IF expression COLON NEWLINE INDENT master DEDENT                 { $$ = new string("if (" + *$2 + ") {\n" + *$6 + "\n"); delete $2, $6;}
  | IF expression COLON NEWLINE INDENT master elseif_clause                 { $$ = new string("if (" + *$2 + ") {\n" + *$6 + *$7); delete $2, $6, $7;} 
  | IF expression COLON NEWLINE INDENT master else_clause                 { $$ = new string("if (" + *$2 + ") {\n" + *$6 + *$7); delete $2, $6, $7;}
;

while_clause
  : WHILE expression COLON NEWLINE INDENT master DEDENT                   { $$ = new string("while (" + *$2 + ") {\n" + *$6 + "\n}"); delete $2, $6;}
;

break_clause
  : BREAK NEWLINE                                         { $$ = new string("break;"); }
;

elseif_clause
  : ELIF expression COLON NEWLINE INDENT master DEDENT                 { $$ = new string("else if (" + *$2 + ") {" + *$6 + "} "); delete $2, $6; }
;

else_clause
  : DEDENT ELSE COLON NEWLINE INDENT master DEDENT              { $$ = new string("\n} else {\n" + *$6 + "\n}"); delete $6; }
;

expression
  : LPAREN expression RPAREN   { $$ = new string("(" + *$2 + ")"); delete $2;}
  | expression PLUS expression       { $$ = new string(*$1 + " + " + *$3); delete $1, $3;}
  | expression MINUS expression      { $$ = new string(*$1 + " - " + *$3); delete $1, $3;}
  | expression TIMES expression      { $$ = new string(*$1 + " * " + *$3); delete $1, $3;}
  | expression DIVIDEDBY expression  { $$ = new string(*$1 + " / " + *$3); delete $1, $3;}
  | NOT expression          { $$ = new string("!" + *$2); delete $2;}
  | expression AND expression  { $$ = new string(*$1 + " && " + *$3); delete $1, $3;}
  | expression OR expression   { $$ = new string(*$1 + " || " + *$3); delete $1, $3;}
  | expression EQ expression   { $$ = new string(*$1 + " == " + *$3); delete $1, $3;}
  | expression NEQ expression  { $$ = new string(*$1 + " != " + *$3); delete $1, $3;}
  | expression GT expression   { $$ = new string(*$1 + " > " + *$3); delete $1, $3;}
  | expression GTE expression  { $$ = new string(*$1 + " >= " + *$3); delete $1, $3;}
  | expression LT expression   { $$ = new string(*$1 + " < " + *$3); delete $1, $3;}
  | expression LTE expression  { $$ = new string(*$1 + " <= " + *$3); delete $1, $3;}
  | variable
  ;


variable
  : NUMBER                 { $$ = $1; }
  | IDENTIFIER           { $$ = $1; }
  | FLOAT                { $$ = $1; }
  | TRUE                 { $$ = new string("true"); }
  | FALSE                { $$ = new string("false"); }
  ;
%%