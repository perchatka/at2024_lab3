%option yylineno
%option c++ noyywrap
%option yyclass="lab3::MyLexer"

%{

#include "lab3.tab.hh"
#include "scan.hh"

#undef YY_DECL
#define YY_DECL int lab3::MyLexer::yylex(yy::parser::value_type *yylval)

/*void yyerror(const std::string);*/
dirOpr getDir(char);

typedef yy::parser::token token;
	
%}

%%

"bool"	{ return token::BOOLTYPE; }
"int"	{ return token::INTTYPE; }
"cell"	{ return token::CELLTYPE; }
"array"	{ return token::ARRTYPE; }

"true"|"false"	{
	yylval->emplace<bool>((std::string(YYText()) == "true" ? true : false ));
	return token::BOOL; 
}

[0-9]+ {
    yylval->emplace<int>( atoi(YYText()) );
    return token::INTEGER;
}

"^_^"|"v_v"|"<_<"|">_>"  {
    yylval->emplace<dirOpr>(getDir(YYText()[0]) );
    return token::MOVOPER;
}

[^v<>]"_0"  {
    yylval->emplace<dirOpr>(getDir(YYText()[0]) );
    return token::DISTMEAS;
}

"*_*"   { return token::GETPOS; }
"=>"    { return token::CELLMEMB; }
"||"    { return token::OR; }
"&&"    { return token::AND; }
">="    { return token::GE; }
"<="    { return token::LE; }
"<=>"   { return token::TYPECOMPAR; }
"=="    { return token::EQ; }
"!="    { return token::NE; }
"for"   { return token::FOR; }
"do"    { return token::DO; }
"end"   { return token::END; }
"if"    { return token::IF; }
"else"  { return token::ELSE; }
"print" { return token::PRINT; }
"goto"  { return token::GOTO; }
"return"    { return token::RETURN; }
"sizeof"	{ return token::SIZEOF; }

[A-Za-z][A-Za-z0-9]* {
    yylval->emplace<std::string>(YYText() );
    return token::VARIABLE;
}

[-()~<>=+;:{}.] {
    return YYText()[0];
}

[ \t\n]+    {}
.       { return token::YYerror; }

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
	return dirUp;
}

