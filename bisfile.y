%require "3.2"
%language "c++"
%{
	#include <iostream>
	#include <string>
	#include <vector>
	#include <map>
	#include "logic.h"

	nodeType *opr(int oper, int nops, ...);
	nodeType *id(int i);
	//....
	void yyerror(const char*, char);
	void yyerror(const char*);
	FlexLexer yylexer;
	int (&yylex)() = yylexer.yylex();
	//void AddToVarStor(std::string*, int);
	//getfromvarstor
%}
%union {
	bool bValue;
	int iValue;
	std::string *pStr;
	nodeType *nPtr;
}
%token <bValue> BOOLEAN
%token <iValue> INTEGER
%token <pStr> NAME

%type <iValue> term
%type <bValue> boper
%type <nPtr> expr stmt stmt_list
%left '+' '-' OR AND TYPECOMPAR
%right UMINUS NOT
%nonassoc IF DO FOR MOVOPER INITTYPE DISTMEAS END
//definitions

%%

program:
	function	{ exit(0); }
;

function:
	function stmt {
		ex($2);
		freeNode();
	}
	function error ';' {

	}
|
;

stmt:
	';'			{ $$ = opr(';', 2, NULL, NULL); }
|	expr ';'	{ $$ = $1; }
|	INITTYPE NAME defval ';'	{}
|	MOVOPER ';'{

	}
|	IF expr DO stmt_list END {

	}
|	FOR NAME '=' expr ':' expr DO stmt_list END {

	}
;

stmt_list:
	stmt				{ $$ = $1; }
|	stmt_list stmt		{  } //...
;

defval:
	'=' expr {}
|	'=' boper {}
;

expr:
	'-' expr %prec UMINUS	{$$ = -$2;}
|	expr '+' term	{ $$ = $1 + $3; }
|	expr '-' term	{ $$ = $1 - $3; }
|	term			{ $$ = $1; }
|	DISTMEAS		{ $$ = dist_meas($$); }
;

term:
	INTEGER		{ $$ = $1; }
//|	boper		{ $$ = ($1 ? 1 : 0); }
;

boper:
	BOOLEAN				{ $$ = $1; }
//|	expr				{ $$ = ($1 == 0 ? false : true); }
|	'~' boper %prec NOT	{ $$ = !$2; }
|	boper OR boper		{ $$ = $1 || $3; }
|	boper AND boper		{ $$ = $1 && $3; }
;
//logic

%%

void yyerror(const char *s) {
	std::cerr<<s<<"\n";
}

int main(int argc, char** argv) {
	std::string filename = "prog.txt";
	if(argc > 1)
		filename = argv[1];
	std::ifstream fin(filename, "r");
	FlexLexer yfile(&fin);
	yyparse();
	fin.close();
	return 0;
}
