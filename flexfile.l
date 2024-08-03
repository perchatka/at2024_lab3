%option c++
%option noyywrap
%option yylineno
%{
#include "bisfile.tab.hh"
#include <iostream>
#include <string>
#include <stdlib.h>
void yyerror(const char*);	
%}

%%

[(int)(bool)(cell)(array)]	{
	yyval.pStr = new std::string(YYText());
	return INITTYPE;
}

[(true)(false)]	{
	yylval.bValue = (YYText() == "true" ? true : false );
	return BOOLEAN; 
}

"for"		{ return FOR; }
"end"		{ return END; }
"do"		{ return DO; }
"if"		{ return IF; }

[a-z]([a-z0-9)])*	{
	yyval.pStr = new std::string(YYText());
	return NAME;
}

[0-9]+	{
	yylval.iValue = std::stoi(YYText());
	yylloc.first_column = yylloc.last_column + 1;
	yylloc.last_column += std::strlen(YYText());
	return INTEGER;
}

"<=>"		{ return TYPECOMPAR; }
"||"		{ return OR; }
"&&"		{ return AND; }
[(^_^)(v_v)(<_<)(>_>)]	{ return MOVOPER;}
[^v<>]_0	{ return DISTMEAS; }
[-+=><~]	{ return *YYText(); }
[ \t\n]		{ yylloc.first_column = ++yyloc.last_column; }
. {
	yylloc.first_column = ++yylloc.last_column;
	yyerror("Unknown character.");
}

%%
