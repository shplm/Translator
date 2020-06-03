%{
/*
 * This is the initial declarations block within the definitions section of
 * the Flex specification file.  Any code can be written here, and it will
 * be copied verbatim to the top of the generated scanner code file.
 *
 * Below, we define a single name, DIGIT, and we specify two Flex options
 * directives.
 */
#include <iostream>
%}

DIGIT [0-9]

%option noyywrap
%option yylineno

%%

a       {
          /*
           * This rule recognizes the single character 'a'.  The code within
           * this set of brackets is the action for this rule.  It will be run
           * whenever the token 'a' is recognized in the input source code.
           */

          std::cout << "The text of the matched string is available in yytext: " << yytext << std::endl;
          std::cout << "The length of the matched string is available in yyleng: " << yyleng << std::endl;
          std::cout << "The matched string appeared on this source code line (yylineno): " << yylineno << std::endl;

        }

cat     {
          /*
           * This rule recognizes the concatenation of 'c', 'a', and 't',
           * i.e. the string "cat".
           */

           REJECT;
        }

cat|dog {
          /*
           * This rule recognizes the union of "cat" and "dog", i.e. either
           * "cat" or "dog".
           */
           REJECT;
        }

ca*t    {
          /*
           * This rule contains a closure operator.  It recognizes a 'c',
           * followed by zero or more 'a's, followed by a 't'.  The following
           * strings (plus others) all match this pattern:
           *
           * ct
           * cat
           * caaaaaat
           * caaaaaaaaaaaaaaaaaaaaaat
           */
          yyterminate();
        }

ca+t    {
          /*
           * This rule contains a positive closure operator.  It recognizes a
           * 'c', followed by one or more 'a's, followed by a 't'.  This
           * pattern matches the same strings as the one above, except for
           * "ct".
           */
        }

ca?t    {
          /*
           * This rule contains an optional operator.  It recognizes a 'c',
           * followed by zero or one 'a's, followed by a 't', i.e, either the
           * string "ct" or the string "cat".
           */
        }

\n      {
          /*
           * This rule contains an escape sequence.  It matches a single
           * newline character.
           */
        }

\r\n    {
          /*
           * This rule contains escape sequences to match a DOS-style newline.
           */
        }

\t      {
          /*
           * This rule contains an escape sequence to match a single tab
           * character.
           */
        }

\?      {
          /*
           * This rule uses an escape sequence to match a single '?' character.
           * The escape is needed because ? is a regular expression operator.
           */
        }

[abc]   {
          /*
           * This rule contains a character class.  It matches a single
           * character that is either 'a', 'b', or 'c'.
           */
        }

[ \t\n] {
          /*
           * This rule contains a character class to match whitespace, i.e. a
           * single character that is either ' ', '\t', or '\n'.
           */
        }

[0-9]   {
          /*
           * This rule contains a character range class.  It matches a single
           * character that is either '0', '1', '2', '3', '4', '5', '6', '7',
           * '8', or '9'.
           */
        }

[0-9a-zA-Z]   {
                /*
                 * This rule contains a character range class to match any
                 * single alphanumeric character.
                 */
              }

[^cat]    {
            /*
             * This rule contains a complement.  It matches any single
             * character that is NOT 'c', 'a', or 't'.
             */
          }

[^ \t\n]  {
            /*
             * This rule contains a complement that matches any single
             * non-whitespace character.
             */
          }

c(a|u)*t  {
            /*
             * This rule uses parentheses to override the order of operations.
             */
           }

{DIGIT}*\.{DIGIT}+  {
                      /*
                       * This rule matches an unsigned floating-point number
                       * using the DIGIT name we defined above.
                       */
                    }

^cat            {

}

cat$            {

}

"c.t"       {

}

.     {
        std::cerr << "Error: invalid token: " << yytext << std::endl;
      }

<<EOF>>   {

}

%%

int main() {
  yylex();
}
