%option c++
%option noyywrap
%option yylineno

%{

#include "lab3.tab.hh"
#include <fstream>
#include <stdlib.h>

void yyerror(const std::string);
dirOpr getDir(char);
	
%}

%%

"bool"	{ return yy::parser::token::BOOLTYPE; }
"int"	{ return yy::parser::token::INTTYPE; }
"cell"	{ return yy::parser::token::CELLTYPE; }
"array"	{ return yy::parser::token::ARRTYPE; }

"true"|"false"	{
	yy::parser::yylval->emplace<bool>() = (std::string(YYText()) == "true" ? true : false );
	return yy::parser::token::BOOL; 
}

[0-9]+ {
    yy::parser::yylval->emplace<int>() = atoi(yytext);
    return yy::parser::token::INTEGER;
}

"^_^"|"v_v"|"<_<"|">_>"  {
    yy::parser::yylval->emplace<int> = getDir(YYText()[0]);
    return yy::parser::token::MOVOPER;
}

[^v<>]"_0"  {
    yy::parser::yylval->emplace<int> = getDir(YYText()[0]);
    return yy::parser::token::DISTMEAS;
}

"*_*"   { return yy::parser::token::GETPOS; }
"=>"    { return yy::parser::token::CELLMEMB; }
"||"    { return yy::parser::token::OR; }
"&&"    { return yy::parser::token::AND; }
">="    { return yy::parser::token::GE; }
"<="    { return yy::parser::token::LE; }
"<=>"   { return yy::parser::token::TYPECOMPAR; }
"=="    { return yy::parser::token::EQ; }
"!="    { return yy::parser::token::NE; }
"for"   { return yy::parser::token::FOR; }
"do"    { return yy::parser::token::DO; }
"end"   { return yy::parser::token::END; }
"if"    { return yy::parser::token::IF; }
"else"  { return yy::parser::token::ELSE; }
"print" { return yy::parser::token::PRINT; }
"goto"  { return yy::parser::token::GOTO; }
"return"    { return yy::parser::token::RETURN; }

[A-Za-z][A-Za-z0-9]* {
    yy::parser::yylval->emplace<id> = YYText()[0];
    return yy::parser::token::VARIABLE;
}

[-()~<>=+;:{}.] {
    return yy::YYText()[0];
}

[ \t\n]+    {}
.       { yyerror("Unknown character"); }

%%

dirOpr getDir(char c) {
    switch(c) {
    case '^':
        return dirUp;
        break;
    case '>':
        return dirRight;
        break;
    case 'v':
        return dirDown;
        break;
    case '<':
        return dirLeft;
        break;
    }
	yyerror("Unknown direction operator.");
	return dirUp;
}

