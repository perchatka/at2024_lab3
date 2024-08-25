#if !defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "lab3.hh"

namespace lab3 {

class MyLexer: public yyFlexLexer {
public:
	MyLexer(std::istream& arg_yyin, std::ostream& arg_yyout)
        : yyFlexLexer(arg_yyin, arg_yyout) {}
    MyLexer(std::istream* arg_yyin = nullptr, std::ostream* arg_yyout = nullptr)
        : yyFlexLexer(arg_yyin, arg_yyout) {}
	int yylex();
	int yylex(yy::parser::value_type *yylval);
};

};
