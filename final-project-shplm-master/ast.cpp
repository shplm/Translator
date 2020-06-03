#include <sstream>

#include "ast.hpp"
#include "parser.hpp"


llvm::Value* numericConstant(float val) {
  return llvm::ConstantFP::get(TheContext, llvm::APFloat(val));
}
llvm::Value* variableValue(const std::string& name) {
  llvm::Value* val = TheSymbolTable[name];
  if (!val) {
    std::cerr << "Invalid variable name: " << name << std::endl;
    return NULL;
  }
  return TheBuilder.CreateLoad(val,name.c_str());

}
llvm::Value* binaryOperation(llvm::Value* lhs, llvm::Value* rhs, char op) {
  if (!lhs || !rhs) {
    return NULL;
  }

  switch (op) {
  case '+':
    return TheBuilder.CreateFAdd(lhs, rhs, "addtmp");
  case '-':
    return TheBuilder.CreateFSub(lhs, rhs, "subtmp");
  case '*':
    return TheBuilder.CreateFMul(lhs, rhs, "multmp");
  case '/':
    return TheBuilder.CreateFDiv(lhs, rhs, "divtmp");
  case '<':
    lhs = TheBuilder.CreateFCmpULT(lhs, rhs, "lttmp");
    return TheBuilder.CreateUIToFP(lhs, llvm::Type::getFloatTy(TheContext), "booltmp");
  case '>':
    lhs = TheBuilder.CreateFCmpUGT(lhs, rhs, "gtmp");
    return TheBuilder.CreateUIToFP(lhs, llvm::Type::getFloatTy(TheContext), "booltmp");
  default:
    std::cerr << "Invalid operator:" << op << std::endl;
    return NULL;
  }
}

llvm::AllocaInst* generateEntryBlockAlloca(std::string& name) {
  llvm::Function* currFn =
    TheBuilder.GetInsertBlock()->getParent();
  llvm::IRBuilder<> tmpBuilder(&currFn->getEntryBlock(),
    currFn->getEntryBlock().begin());

  return tmpBuilder.CreateAlloca(llvm::Type::getFloatTy(TheContext), 0, name.c_str());
}

llvm::Value* assignmentStatement(std::string& lhs, llvm::Value* rhs) {
  if (!rhs) {
    return NULL;
  }
  if (!TheSymbolTable.count(lhs)) {
    // Allocate lhs
    TheSymbolTable[lhs] = generateEntryBlockAlloca(lhs);
  }
  return TheBuilder.CreateStore(rhs, TheSymbolTable[lhs]);
}

void generateObjCode(const std::string& filename) {
  std::string targetTriple = llvm::sys::getDefaultTargetTriple();

  llvm::InitializeAllTargetInfos();
  llvm::InitializeAllTargets();
  llvm::InitializeAllTargetMCs();
  llvm::InitializeAllAsmParsers();
  llvm::InitializeAllAsmPrinters();

  std::string error;
  const llvm::Target* target =
    llvm::TargetRegistry::lookupTarget(targetTriple, error);
  if (!target) {
    std::cerr << error << std::endl;
  } else {
    std::string cpu = "generic";
    std::string features = "";
    llvm::TargetOptions options;
    llvm::TargetMachine* targetMachine =
      target->createTargetMachine(targetTriple, cpu, features,
        options, llvm::Optional<llvm::Reloc::Model>());

    TheModule->setDataLayout(targetMachine->createDataLayout());
    TheModule->setTargetTriple(targetTriple);

    std::error_code ec;
    llvm::raw_fd_ostream file(filename, ec, llvm::sys::fs::F_None);
    if (ec) {
      std::cerr << "Could not open output file: " << ec.message() << std::endl;
    } else {
      llvm::TargetMachine::CodeGenFileType type = llvm::TargetMachine::CGFT_ObjectFile;
      llvm::legacy::PassManager pm;
      if (targetMachine->addPassesToEmitFile(pm, file, NULL, type)) {
        std::cerr << "Unable to emit target code" << std::endl;
      } else {
        pm.run(*TheModule);
        file.close();
      }
    }
  }
}

void doOptimizations(llvm::Function* fn) {
  llvm::legacy::FunctionPassManager* fpm =
    new llvm::legacy::FunctionPassManager(TheModule);

  fpm->add(llvm::createPromoteMemoryToRegisterPass());
  // fpm->add(llvm::createInstructionCombiningPass());
  fpm->add(llvm::createReassociatePass());
  fpm->add(llvm::createGVNPass());
  fpm->add(llvm::createCFGSimplificationPass());

  fpm->run(*fn);
}

llvm::Value* LHS_assign(struct node* nodes){
    if(nodes->shape == "box"){
      if(nodes->label.substr(0,10) == "Identifier"){
        return variableValue(nodes->str);
      }
      else{
        float temp = atof(nodes->str.c_str());
        return numericConstant(temp);
      }
    }
    if(nodes->next_node[0]->label !="box"){
       if(nodes->next_node[1]->label.substr(0,10) == "Identifier"){
          if(nodes->label == "PLUS"){
            return binaryOperation(LHS_assign(nodes->next_node[0])
                    ,variableValue(nodes->next_node[1]->str), '+');
          }
          else if(nodes->label == "MINUS"){
            return binaryOperation(LHS_assign(nodes->next_node[0])
                    ,variableValue(nodes->next_node[1]->str), '-');
          }
          else if(nodes->label == "TIMES"){
            return binaryOperation(LHS_assign(nodes->next_node[0])
                    ,variableValue(nodes->next_node[1]->str), '*');
          }
          else if(nodes->label == "DIVIDEDBY"){
            return binaryOperation(LHS_assign(nodes->next_node[0])
                    ,variableValue(nodes->next_node[1]->str), '/');
          }
          else{
            return NULL;
          }
        }
        else{
          float temp = atof(nodes->next_node[1]->str.c_str());
          if(nodes->label == "PLUS"){
            return binaryOperation(numericConstant(temp)
                    ,LHS_assign(nodes->next_node[0]), '+');
          }
          else if(nodes->label == "MINUS"){
            return binaryOperation(numericConstant(temp)
                    ,LHS_assign(nodes->next_node[0]), '-');
          }
          else if(nodes->label == "TIMES"){
            return binaryOperation(numericConstant(temp)
                    ,LHS_assign(nodes->next_node[0]), '*');
          }
          else if(nodes->label == "DIVIDEDBY"){
            return binaryOperation(numericConstant(temp)
                    ,LHS_assign(nodes->next_node[0]), '/');
          }
          else{
            return NULL;
          }
        }
    }
    else{
      if(nodes->next_node[0]->label.substr(0,10) == "Identifier"
      && nodes->next_node[1]->label.substr(0,10) == "Identifier"){
        llvm::Value* temp = NULL;
        if(nodes->label == "PLUS"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,variableValue(nodes->next_node[0]->str), '+');
        }
        else if(nodes->label == "MINUS"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,variableValue(nodes->next_node[0]->str), '-');
        }
        else if(nodes->label == "TIMES"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,variableValue(nodes->next_node[0]->str), '*');
        }
        else if(nodes->label == "DIVIDEDBY"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,variableValue(nodes->next_node[0]->str), '/');
        }
        else{
          return NULL;
        }
        return temp;
      }
      else if(nodes->next_node[0]->label.substr(0,10) != "Identifier"
            && nodes->next_node[1]->label.substr(0,10) != "Identifier"){
        float temp2 = atof(nodes->next_node[0]->str.c_str());
        llvm::Value* temp = NULL;
        if(nodes->label == "PLUS"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,numericConstant(temp2), '+');
        }
        else if(nodes->label == "MINUS"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,numericConstant(temp2), '-');
        }
        else if(nodes->label == "TIMES"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,numericConstant(temp2), '*');
        }
        else if(nodes->label == "DIVIDEDBY"){
          temp = binaryOperation(variableValue(nodes->next_node[1]->str)
                    ,numericConstant(temp2), '/');
        }
        else{
          return NULL;
        }
        return temp;
      }
      else if(nodes->next_node[0]->label.substr(0,10) == "Identifier"
            && nodes->next_node[1]->label.substr(0,10) == "Identifier"){
        float temp2 = atof(nodes->next_node[1]->str.c_str());
        llvm::Value* temp = NULL;
        if(nodes->label == "PLUS"){
          temp = binaryOperation(variableValue(nodes->next_node[0]->str)
                    ,numericConstant(temp2), '+');
        }
        else if(nodes->label == "MINUS"){
          temp = binaryOperation(variableValue(nodes->next_node[0]->str)
                    ,numericConstant(temp2), '-');
        }
        else if(nodes->label == "TIMES"){
          temp = binaryOperation(variableValue(nodes->next_node[0]->str)
                    ,numericConstant(temp2), '*');
        }
        else if(nodes->label == "DIVIDEDBY"){
          temp = binaryOperation(variableValue(nodes->next_node[0]->str)
                    ,numericConstant(temp2), '/');
        }
        else if(nodes->label == "boolean true" || nodes->label == "boolean false"){}
        else{
          return NULL;
        }
        return temp;
       }
       else if(nodes->next_node[0]->label.substr(0,10) != "Identifier"
             && nodes->next_node[1]->label.substr(0,10) != "Identifier"){
        float temp1 = atof(nodes->next_node[0]->str.c_str());
        float temp2 = atof(nodes->next_node[1]->str.c_str());
         llvm::Value* temp = NULL;
        if(nodes->label == "TIMES"){
           temp = binaryOperation(numericConstant(temp1),numericConstant(temp2), '*');
        }
        else if(nodes->label == "PLUS"){
          temp = binaryOperation(numericConstant(temp1),numericConstant(temp2), '+');
        }
        else if(nodes->label == "MINUS"){
         temp = binaryOperation(numericConstant(temp1),numericConstant(temp2), '-');
        }
        else if(nodes->label == "DIVIDEDBY"){
         temp = binaryOperation(numericConstant(temp1),numericConstant(temp2), '/');
        }
        else{
          return NULL;
        }
        return temp;
      }
      else{
        return NULL;
      }

    }
}

llvm::Value* generateGVSpec(struct node* nodes, llvm::Module* TheModule){
  if(nodes->label== "Block"){
      for(struct node* i: nodes->next_node){
        generateGVSpec(i,TheModule);
      }
      return NULL;
  }
  else if(nodes->label== "Assignment"){
      if(nodes->next_node[1]->shape == "box"
      && nodes->next_node[1]->label.substr(0,10) != "Identifier" ){
        float num_temp = atof(nodes->next_node[1]->str.c_str());
        if(nodes->next_node[1]->label == "boolean true"){
          llvm::Value* temp = assignmentStatement(nodes->next_node[0]->str, numericConstant(1));
        }
        else if(nodes->next_node[1]->label == "boolean false"){
          llvm::Value* temp = assignmentStatement(nodes->next_node[0]->str, numericConstant(0));
        }
        else{
          llvm::Value* value_temp = numericConstant(num_temp);
          llvm::Value* temp = assignmentStatement(nodes->next_node[0]->str, value_temp);
        }
        return NULL;
      }
      else{
        llvm::Value* temp = assignmentStatement(nodes->next_node[0]->str, LHS_assign(nodes->next_node[1]));
        return temp;
      }
    }
  else{
      return NULL;
  }
}

void start(int argc, char const *argv[]){

    TheModule = new llvm::Module("Python compiler", TheContext);

    llvm::FunctionType* mainFnType = llvm::FunctionType::get(
      llvm::Type::getVoidTy(TheContext), false
    );
    llvm::Function* mainFn = llvm::Function::Create(
      mainFnType,
      llvm::GlobalValue::ExternalLinkage,
      "foo",
      TheModule
    );
    llvm::BasicBlock* entryBlock =
        llvm::BasicBlock::Create(TheContext, "entry", mainFn);
    TheBuilder.SetInsertPoint(entryBlock);


    //recursive generateGVSpec()
    generateGVSpec(nodes,TheModule);

    TheBuilder.CreateRetVoid();
    if(argc > 1){
        if(argv[1][0] == '-' && argv[1][1] == 'O'){
              doOptimizations(mainFn);
            }
    }

    llvm::verifyFunction(*mainFn);
    TheModule->print(llvm::outs(),NULL);
    string filename = "output.o";
    generateObjCode(filename);
    delete TheModule;

}
