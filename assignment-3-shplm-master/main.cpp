#include <iostream>
#include <set>
#include <deque>
#include <string>
#include "parser.hpp"

using std::deque;
using std::cin;
using std::cout;
using std::endl;
using std::set;
using std::string;

extern int yylex();

extern Astree* root;

extern string* target_program;
extern set<string> symbols;

deque<Astree*> node_queue;
deque<string> curr_node;
deque<string> prev_node;
Astree* curr;
string curr_symbol;

void label_printout(string symbol, Astree* node);

int main() {
    int count = 0;
    if (!yylex()) {
        cout << "digraph G {" << endl;

        node_queue.push_back(root);
        curr_node.push_back("n0");

        while(!node_queue.empty()){
            curr = node_queue.back();
            curr_symbol = curr_node.back();

            if (!prev_node.empty()) {
                cout << "  " << prev_node.back() << " -> " << curr_node.back() << ";" << endl;
                prev_node.pop_back();
            }

            label_printout(curr_node.back(), node_queue.back());
            curr_node.pop_back();
            node_queue.pop_back();

            if (curr->get_right() != NULL) {
                    node_queue.push_back(curr->get_right());
                    prev_node.push_back(curr_symbol);
                    curr_node.push_back(curr_symbol + "_rhs");
            }
            if (curr->get_left() != NULL) {
                    node_queue.push_back(curr->get_left());
                    prev_node.push_back(curr_symbol);
                    curr_node.push_back(curr_symbol + "_lhs");
            }
            else if(curr->get_name() == "OR"  || 
                    curr->get_name() == "AND" ||
                    curr->get_name() == "EQ"  ||
                    curr->get_name() == "NEQ" ||
                    curr->get_name() == "GT"  ||
                    curr->get_name() == "GTE" ||
                    curr->get_name() == "LE"  ||
                    curr->get_name() == "LET" ||
                    curr->get_name() == "NOT"){
                    }
            else if (!curr->get_child().empty()){
                if(curr->get_name() == "If"){
                        for (int i = curr->get_child_size() - 1; i >=0; i--) {
                                node_queue.push_back(curr->get_child()[i]);
                                string temp = node_queue.back()->get_name(); 
                                if (temp == "OR"  || 
                                                    temp == "AND" ||
                                                    temp == "EQ"  ||
                                                    temp == "NEQ" ||
                                                    temp == "GT"  ||
                                                    temp == "GTE" ||
                                                    temp == "LE"  ||
                                                    temp == "LET" ||
                                                    temp == "NOT" ||
                                                    temp == "IF" ||
                                                    temp == "Identifier"){
                                                        prev_node.push_back(curr_symbol);
                                                        curr_node.push_back(curr_symbol + "_cond");
                                }
                                else if(temp == "Block"){
                                    prev_node.push_back(curr_symbol);
                                    curr_node.push_back(curr_symbol + "_if");
                                }
                                else{
                                prev_node.push_back(curr_symbol);
                                curr_node.push_back(curr_symbol + std::to_string(i));
                                }
                            }
                }
                else if(curr->get_name() == "Elif"){
                                        for (int i = curr->get_child_size() - 1; i >=0; i--) {
                                
                                node_queue.push_back(curr->get_child()[i]);
                                string temp = node_queue.back()->get_name(); 

                                if (temp == "OR"  || 
                                                    temp == "AND" ||
                                                    temp == "EQ"  ||
                                                    temp == "NEQ" ||
                                                    temp == "GT"  ||
                                                    temp == "GTE" ||
                                                    temp == "LE"  ||
                                                    temp == "LET" ||
                                                    temp == "NOT" ||
                                                    temp == "IF" ||
                                                    temp == "Identifier"){
                                                        prev_node.push_back(curr_symbol);
                                                        curr_node.push_back(curr_symbol + "_cond");
                                                    }
                                
                                else if(temp == "Block"){
                                    curr_symbol.pop_back();
                                    curr_symbol.pop_back();
                                    curr_symbol.pop_back();
                                    prev_node.push_back(curr_symbol);
                                    curr_node.push_back(curr_symbol + "_elif");
                                }
                                
                                else{
                                prev_node.push_back(curr_symbol);
                                curr_node.push_back(curr_symbol + std::to_string(i));
                                }
                            }
                }
                else if(curr->get_value() == "Else"){
                    for (int i = curr->get_child_size() - 1; i >=0; i--) {
                                
                                node_queue.push_back(curr->get_child()[i]);
                                string temp = node_queue.back()->get_name(); 

                                if (temp == "OR"  || 
                                                    temp == "AND" ||
                                                    temp == "EQ"  ||
                                                    temp == "NEQ" ||
                                                    temp == "GT"  ||
                                                    temp == "GTE" ||
                                                    temp == "LE"  ||
                                                    temp == "LET" ||
                                                    temp == "NOT" ||
                                                    temp == "IF" ||
                                                    temp == "Identifier"){
                                                        prev_node.push_back(curr_symbol);
                                                        curr_node.push_back(curr_symbol + "_cond");
                                                    }
                                
                                else if(temp == "Block"){
                                    curr_symbol.pop_back();
                                    curr_symbol.pop_back();
                                    curr_symbol.pop_back();
                                    prev_node.push_back(curr_symbol);
                                    curr_node.push_back(curr_symbol + "_else");
                                }
                                
                                else{
                                prev_node.push_back(curr_symbol);
                                curr_node.push_back(curr_symbol + std::to_string(i));
                                }
                            }
                }
                else if(curr->get_name() == "While"){
                    for (int i = curr->get_child_size() - 1; i >=0; i--) {
                                node_queue.push_back(curr->get_child()[i]);
                                string temp = node_queue.back()->get_name(); 
                                if (temp == "OR"  || 
                                                    temp == "AND" ||
                                                    temp == "EQ"  ||
                                                    temp == "NEQ" ||
                                                    temp == "GT"  ||
                                                    temp == "GTE" ||
                                                    temp == "LE"  ||
                                                    temp == "LET" ||
                                                    temp == "NOT" ||
                                                    temp == "IF" ||
                                                    temp == "Identifier" ||
                                                    temp == "Boolean"){
                                                        prev_node.push_back(curr_symbol);
                                                        curr_node.push_back(curr_symbol + "_cond");
                                                    }
                                
                                else if(temp == "Block"){
                                    prev_node.push_back(curr_symbol);
                                    curr_node.push_back(curr_symbol + "_while");
                                }
                                
                                else{
                                prev_node.push_back(curr_symbol);
                                curr_node.push_back(curr_symbol + std::to_string(i));
                                }
                            }
                }
                else{
                    for (int i = curr->get_child_size() - 1; i >=0; i--) {
                        node_queue.push_back(curr->get_child()[i]);
                        prev_node.push_back(curr_symbol);
                        curr_node.push_back(curr_symbol + "_" + std::to_string(i));
                    }
                }
            }
        }
        cout << "}" << endl;
    }
    delete root;

    return 0;
}

void label_printout(string symbol, Astree* node) {
    string value = node->get_name();
    if (value == "Identifier" || value == "Float" || value == "Integer" || value == "Boolean") {
        value = value + ": " + node->get_value();
        cout << "  " << symbol << " [shape=box,label=\"" << value << "\"];" << endl;
    } 
    else if (value == "If" || value == "Elif"){
        value = value + node->get_value();
        cout << "  " << symbol << " [label=\"" << value << "\"];" << endl;
    }
    else {
        cout << "  " << symbol << " [label=\"" << value << "\"];" << endl;
    }
}
