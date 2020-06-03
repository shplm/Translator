#include "Astree.h"


Astree::Astree(string name){
    this->name = name;
    this->value = "";
    this->right = NULL;
    this->left = NULL;
}

Astree::Astree(string name, string value){
    this->name = name;
    this->value = value;
    this->right = NULL;
    this->left = NULL;
}

Astree::Astree(string name, string value, Astree* child_node){
    this->name = name;
    this->value = value;
    this->child = child_node->child;
    this->right = NULL;
    this->left = NULL;
    delete child_node;
}

void Astree::set_name(string name){
    this->name = name;
}

void Astree::set_value(string value){
    this->value = value;
}

void Astree::set_lhs(Astree* lhs){
    this->left = lhs;
}

void Astree::set_rhs(Astree* rhs){
    this->right = rhs;
}

void Astree::set_child(Astree* child){
    this->child.push_back(child);
}

vector<Astree*> Astree::get_child(){
    return child;
}

int Astree::get_child_size(){
    return child.size();
}

string Astree::get_name(){
    return name;
}

string Astree::get_value(){
    return value;
}

Astree* Astree::get_left(){
    return left;
}

Astree* Astree::get_right(){
    return right;
}
