%{
#include <iostream>
#include <set>
#include <stack>

#include "parser.hpp"

#include "Astree.h"

using std::string;
using std::vector;
using std::cout;
using std::endl;

Astree* root;

Astree* node;

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string* translate_boolean_str(std::string* boolean_str);

/*
 * Here, target_program is a string that will hold the target program being
 * generated, and symbols is a simple symbol table.
 */
std::string* target_program;
std::set<std::string> symbols;
%}

/* Enable location tracking. */
%locations

%code requires{
  #include "Astree.h"
}

%union{
  float val;
  Astree* node;
  string* str;
}


/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */
// %define api.value.type { std::string* }

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
%token <str> IDENTIFIER
%token <str> FLOAT INTEGER BOOLEAN
%token <token> INDENT DEDENT NEWLINE
%token <token> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> EQ NEQ GT GTE LT LTE
%token <token> LPAREN RPAREN COMMA COLON

%type <node> primary_expression negated_expression
%type <node> statement expression assign_statement
%type <node> statements
%type <node> if_statement elif_blocks else_block condition
%type <node> block while_statement break_statement


/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */

program
  : statements { 
                  root = new Astree("Block", "", $1);
                }
  ;

statements
  : statement { 
                Astree* node = new Astree("", "");
                node->set_child($1);
                $$ = node;
              }
  | statements statement { 
                            Astree* node = new Astree("", "", $1);
                            node->set_child($2);
                            $$ = node;
                          }
  ;

statement
  : assign_statement { $$ = $1; }
  | if_statement { $$ = $1; }
  | while_statement { $$ = $1; }
  | break_statement { $$ = $1; }
  ;

primary_expression
  : IDENTIFIER { 
                  node = new Astree("Identifier", *$1);
                  $$ = node; 
                  delete $1;
                }
  | FLOAT { 

              node = new Astree("Float", *$1);
              $$ = node;
              delete $1;
           }
  | INTEGER { 
              node = new Astree("Integer", *$1);
              $$ = node;
              delete $1;
           }
  | BOOLEAN { 
              if(*$1 == "True"){
                node = new Astree("Boolean", "1");
                $$ = node;
              }
              if(*$1 == "False"){
                node = new Astree("Boolean", "0");
                $$ = node;
              }
              delete $1;
            }
  | LPAREN expression RPAREN { 
                              $$ = $2;
                              }
  ;

negated_expression
  : NOT primary_expression {  
                              node = new Astree("NOT");
                              node->set_lhs(NULL);
                              node->set_rhs($2);
                              $$ = node;
                            }
  ;

expression
  : primary_expression { $$ = $1; }
  | negated_expression { $$ = $1; }
  | expression PLUS expression { 
                                node = new Astree("PLUS");
                                node->set_lhs($1);
                                node->set_rhs($3);
                                $$ = node;
                                
                                }
  | expression MINUS expression { 
                                  node = new Astree("MINUS");
                                  node->set_lhs($1);
                                  node->set_rhs($3);
                                  $$ = node;
                                }
  | expression TIMES expression { 
                                  Astree* node = new Astree("TIMES");
                                  node->set_lhs($1);
                                  node->set_rhs($3);
                                  $$ = node; 
                                  
                                }
  | expression DIVIDEDBY expression { 
                                      node = new Astree("DIVIDEDBY");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                                      
                                    }
  | expression EQ expression { 

                                      node = new Astree("EQ");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                              }
  | expression NEQ expression { 

                                      node = new Astree("NEQ");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                              }
  | expression GT expression { 

                                      node = new Astree("GT");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                              }
  | expression GTE expression { 
                                      node = new Astree("GTE");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                              }
  | expression LT expression { 
                                      node = new Astree("LT");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                              }
  | expression LTE expression { 
                                      node = new Astree("LTE");
                                      node->set_lhs($1);
                                      node->set_rhs($3);
                                      $$ = node; 
                              }
  ;

assign_statement
  : IDENTIFIER ASSIGN expression NEWLINE { 
                                            Astree* identifier = new Astree("Identifier", *$1);
                                            delete $1;
                                            node = new Astree("Assignment", "");
                                            node->set_lhs(identifier);
                                            node->set_rhs($3);
                                            $$ = node;
                                          }
  ;

block
  : INDENT statements DEDENT {
                               $$ = new Astree("Block", "", $2);
                              }
  ;

condition
  : expression { $$ = $1; }
  | condition AND condition {
                              node = new Astree("AND");
                              node->set_lhs($1);
                              node->set_rhs($3);
                              $$ = node;
                            }
  | condition OR condition {
                              node = new Astree("OR");
                              node->set_lhs($1);
                              node->set_rhs($3);
                              $$ = node;
                            }
  ;

if_statement
  : IF condition COLON NEWLINE block elif_blocks else_block {
                                                              Astree* if_node = new Astree("If", "");
                                                              if_node->set_child($2);
                                                              if_node->set_child($5);
                                                              if($6 != NULL){
                                                                if_node->set_child($6);
                                                              }
                                                              if($7 != NULL){
                                                                if_node->set_child($7);
                                                              }
                                                              $$ = if_node;
}
  ;

elif_blocks
  : %empty { 
            $$ = NULL;
            }
  | elif_blocks ELIF condition COLON NEWLINE block { 
                                                      if ($1 == NULL){
                                                        Astree* elif_node = new Astree("Elif", "");
                                                        elif_node->set_child($3);
                                                        elif_node->set_child($6);
                                                        $$ = elif_node;
                                                      }
                                                      else{
                                                        Astree* elif_node = new Astree("Elif", "", $1);
                                                        elif_node->set_child($3);
                                                        elif_node->set_child($6);
                                                        $$ = elif_node;
                                                      }
  }
  ;

else_block
  : %empty { 
            $$ = NULL;
            }
  | ELSE COLON NEWLINE block { 
                              Astree* else_node = new Astree("Block", "Else");
                              else_node->set_child($4);
                              $$ = else_node;
                              }


while_statement
  : WHILE condition COLON NEWLINE block { 
                                          node = new Astree("While");
                                          node->set_child($2);
                                          node->set_child($5);
                                          $$ = node;
                                          }
  ;

break_statement
  : BREAK NEWLINE { 
                  node = new Astree("Break");
                  $$ = node;
                  }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
std::string* translate_boolean_str(std::string* boolean_str) {
  if (*boolean_str == "True") {
    return new std::string("true");
  } else {
    return new std::string("false");
  }
}
