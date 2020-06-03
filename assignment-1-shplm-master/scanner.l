%{
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <stdlib.h>
#include <stdio.h>
#include <string>

//store && printout structure
struct _word {
	std::string lexeme;
	std::string category;
};

std::vector<struct _word> _words;
std::set<std::string> _ids;
bool _error = false;

void _save_word(std::string lexeme, std::string category) {
	struct _word word = { .lexeme = lexeme, .category = category};
	_words.push_back(word);
}

//Int_to_Str convert
std::string convert_int_to_string(std::string lexeme){
	int num = atoi(yytext);
	std::string sentence = "INTEGER\t\t\t" + std::to_string(num);
	return sentence;
}

//Float_to_Str convert
std::string convert_float_to_string(std::string lexeme){
	float num = atof(yytext);
	std::string sentence = "FLOAT\t\t\t" + std::to_string(num);
	sentence.erase ( sentence.find_last_not_of('0') + 1, std::string::npos );
	sentence.erase ( sentence.find_last_not_of('.') + 1, std::string::npos );
	return sentence;
}

//Format stack
int Dent_level = 0;

void Dent_print(int space){
	if(space > Dent_level){
		_save_word("", "INDENT");
		Dent_level++;
		Dent_level = space;
	}
	/*
	printf("Dent_space: %d\n", space);
	printf("Dent_level: %d\n", Dent_level);
	*/	
	while(space < Dent_level){
		_save_word("", "DEDENT");
		Dent_level = Dent_level - 4;	
	}
}

%}

%option noyywrap
%option yylineno

%%

^[ \t]+   {}

[ ]\n {}

^#.*\n  {}

^[ ]*\n {}


^[ ]*[^ \n]+ {
	//get the num of dent space for current fetching line
	int Dent_space = 0;
	for(int i = 0; i < yyleng; i++){
		if(yytext[i] == ' ' || yytext[i] == '	'){
			Dent_space++;
		}
	}
	//call dent function for printing out
	Dent_print(Dent_space);

	//get the length from current yytext sentence
	int flex_size = yyleng - 1;
	while ((flex_size >= 0) && (yytext[flex_size] != ' ')){
		//unput(): 
		//Destory the present contents of yytext for future section usage
		unput(yytext[flex_size]);
		flex_size--;
	}
	}


[0-9]*      {
	 _save_word("", convert_int_to_string(yytext)); 
	 }

[0-9]*[.][0-9]*   { 
	_save_word("", convert_float_to_string(yytext));
	}

[\n]	{ _save_word("", "NEWLINE"); }
"="         { _save_word(yytext, "ASSIGN\t"); }
"+"         { _save_word(yytext, "PLUS\t"); }
"-"         { _save_word(yytext, "MINUS\t"); }
"*"         { _save_word(yytext, "TIMES\t"); }
"/"         { _save_word(yytext, "DIVIDEDBY"); }
";"         { _save_word(yytext, "SEMICOLON"); }
"("         { _save_word(yytext, "LPAREN\t"); }
")"         { _save_word(yytext, "RPAREN\t"); }
","         { _save_word(yytext, "COMMA\t"); }
":"         { _save_word(yytext, "COLON\t"); }
"=="         { _save_word(yytext, "EQ\t"); }
"!="         { _save_word(yytext, "NEQ\t"); }
">"         { _save_word(yytext, "GT\t"); }
">="         { _save_word(yytext, "GTE\t"); }
"<"         { _save_word(yytext, "LT\t"); }
"<="         { _save_word(yytext, "LTE\t"); }

"True" { _save_word("", "BOOLEAN\t\t\t1"); }
"TRUE" { _save_word("", "BOOLEAN\t\t\t1"); }

"False" { _save_word("", "BOOLEAN\t\t\t0"); }
"FALSE" { _save_word("", "BOOLEAN\t\t\t0"); }

"and"         { _save_word(yytext, "AND\t"); }
"break"         { _save_word(yytext, "BREAK\t"); }
"def"         { _save_word("", "DEF\t\t\tdef"); }
"if"         { _save_word("", "IF\t\t\tif"); }
"elif"         { _save_word(yytext, "ELIF\t"); }
"else"         { _save_word("", "ELSE\t\t\telse"); }
"for"         { _save_word(yytext, "FOR\t"); }
"not"         { _save_word(yytext, "NOT\t"); }
"or"         { _save_word(yytext, "OR\t"); }
"return"         { _save_word("", "RETURN\t\t\treturn"); }
"while"         { _save_word("", "WHILE\t\t\twhile"); }


([a-zA-Z0-9_]*)* {
		_save_word(yytext, "IDENTIFIER");
		_ids.insert(yytext);
	}

[ \t]* {}

.           {
		std::cerr << "Invalid symbol on line " << yylineno
			<< ":" << yytext << std::endl;
		_error = true;
	}

<<EOF>>     {
	//implement for any dedent about at very last line 
	while(Dent_level > 0){
		_save_word("", "DEDENT");
		Dent_level = Dent_level - 4;
	}

	if (_error) {
		return 1;
	} else {
		return 0;
	}
	}

%%

int main(int argc, char **argv) {
	//Here is the basic structure I copy from Dr.Rob lecture notes
	if (!yylex()) {
		if(argc == 2){
			std::ofstream writefile;
			writefile.open(argv[1]);
			for(int i = 0; i < _words.size(); i++){
				writefile << _words[i].category;
				writefile << "\t\t";
				writefile << _words[i].lexeme;
				writefile << "\n";
			}
			std::cout << "File" << argv[1] << "has generated!" << std::endl;
			writefile.close();
		}
		else{
		for (int i = 0; i < _words.size(); i++) {
			std::cout << _words[i].category << "\t\t" << _words[i].lexeme << std::endl;
		}
		}
	}
}
