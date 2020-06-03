/*
 * This file contains definitions for nodes in an AST representation.  Each
 * of the non-abstract classes defined below has at least one constructor,
 * whose usage is documented with the specific class below.
 *
 * Each non-abstract class below also has a method called generateGVSpec().
 * This function generates GraphView specification code for a single AST node
 * of from the corresponding class.  For all classes, this method takes the
 * following two arguments:
 *
 * @param nodeName A string identifier for this node to be used in the
 *   GraphView specification.  Should be unique with respect to the identifiers
 *   for all other nodes in the specification.
 * @param gvSpec A reference to a running string in which the GraphView
 *   specification for the entire AST is being stored.  The specification for
 *   this node will be appended to the end of this string along with the
 *   specification for any descendants of this node.
 */

#ifndef _AST_HPP
#define _AST_HPP

#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <algorithm>
#include "parser.hpp"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/Value.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Target/TargetMachine.h"

#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Scalar/GVN.h"
#include "llvm/Transforms/Utils.h"


using namespace std;

static llvm::LLVMContext TheContext;
static llvm::IRBuilder<> TheBuilder(TheContext);
static llvm::Module* TheModule;

static std::map<std::string, llvm::Value*> TheSymbolTable;



extern int yylex();
extern int yyparse();
extern vector<string> symb;
extern struct node *nodes;
extern string* lines;
extern bool _error;
void print_graph(struct node* nodes,string i,llvm::Module TheModule);
struct node{
  string str;
  string shape;
  string label;
  string id;
  llvm::Value *value;
  vector<struct node*> next_node;
};


llvm::Value* numericConstant(float val);
llvm::Value* variableValue(const std::string& name);
llvm::Value* binaryOperation(llvm::Value* lhs, llvm::Value* rhs, char op);

llvm::AllocaInst* generateEntryBlockAlloca(std::string& name);
llvm::Value* assignmentStatement(std::string& lhs, llvm::Value* rhs);
void generateObjCode(const std::string& filename);
void doOptimizations(llvm::Function* fn);

llvm::Value* LHS_assign(struct node* nodes);

llvm::Value* generateGVSpec(struct node* nodes, llvm::Module* TheModule);

void start(int argc, char const *argv[]);









#endif
