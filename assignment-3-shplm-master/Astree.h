#ifndef AST_NODE_HPP
#define AST_NODE_HPP

#include <vector>
#include <string>
#include <iostream>
using std::string;
using std::vector;

class Astree{
    private:
        string name;
        string value;
        vector<Astree *> child;
        Astree* left;
        Astree* right;

    public:
        Astree(string);
        Astree(string, string);
        Astree(string, string, Astree*);
        void set_name(string);
        void set_value(string);
        void set_lhs(Astree*);
        void set_rhs(Astree*);
        void set_child(Astree*);
        vector<Astree*> get_child();
        int get_child_size();
        string get_name();
        string get_value();
        Astree* get_left();
        Astree* get_right();
};

#endif