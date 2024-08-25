%code requires {

#include <stack>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include "lab3.hh"
#include "in.hh"
#include "nodeop.hh"

using namespace lab3;

}

%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor
%parse-param {lab3::MyLexer &lexer}

%code {

#include "scan.hh"
#define yylex(x) lexer.yylex(x)

typedef yy::parser::token token;

//...
//void AddToVarStor(std::string*, int);
//getfromvarstor

nodeType *opr(int oper, int nops, ...);
nodeType *m_id(typeEnum, const std::string&);
nodeType *con(int value);
typeEnum gettype(const std::string &);
void setlabel (int i ,nodeType *p);
void freeNode(nodeType *p);
int exec(nodeType *p);
//int yylex(void);
void init (void);
//void yyerror(const std::string&);
std::stack< std::map<id, varType, cmpId> > Tabs;
std::map<id, varType, cmpId> *curTab;
std::map<id, nodeType*, cmpId> Funcs;

Grid Maze;

}

%token <bool> BOOL;
%token <int> INTEGER DISTMEAS 'x' 'y' 'f';
%token <std::string> VARIABLE;
%token <typeEnum> BOOLTYPE INTTYPE CELLTYPE ARRTYPE;
%token FOR IF PRINT GOTO DO END RETURN VOID GETPOS;
%nonassoc IFX;
%nonassoc ELSE;
%left TYPECOMPAR ;
%left MOVOPER;
%left OR;
%left AND;
%left GE LE EQ NE '>' '<';
%left '+' '-';
%nonassoc UMINUS NOT;
%nonassoc CELLMEMB;
%nonassoc INITVAR;
%right SIZEOF;

%type <int> cellmemb;
%type <nodeType*> stmt expr stmt_list function arg_list give_args dim_list;
%type <typeEnum> inittype;

%%

program:
function {exec($1); freeNode($1); exit(0); }
;

function:
function stmt { $$ = opr(';', 2, $1, $2);/*ex($2); freeNode($2);*/ }
| function YYerror {}
| /* NULL */ {
	Tabs.push(std::map<id, varType, cmpId>());
	curTab = &Tabs.top();
	init(); $$ = 0;
}
;

stmt:
';' { $$ = opr(typeCon, ';', 2, NULL, NULL); }
| expr ';' { $$ = $1; }
| PRINT expr ';' { $$ = opr(typeCon, token::PRINT, 1, $2); }
| VARIABLE '=' expr ';' { $$ = opr('=', 2, m_id(gettype($1), $1), $3); }
| inittype VARIABLE ';' { $$ = opr('=', 2, m_id($1, $2), 0); }
| inittype VARIABLE '=' expr ';' %prec INITVAR { $$ = opr('=', 2, m_id($1, $2), $4); }
| VARIABLE '[' dim_list ']' '=' expr ';' {$$ = opr('=', 2, get_el($1, $3), $6); }
| VARIABLE CELLMEMB cellmemb '=' expr ';' {$$ = opr('=', 2, get_memb($1, $3), $5); }
| ARRTYPE VARIABLE '=' '{' dim_list '}' ';' { $$ = opr('=', 2, m_id($1, $2), $5); }
| CELLTYPE VARIABLE '=' '{' dim_list '}' ';' { $$ = opr('=', 2, m_id($1, $2), $5); }
| FOR VARIABLE '=' expr ':' expr DO stmt_list END ';' { $$ = opr(token::FOR, 4, $2, $4, $6, $8); }
| IF expr DO stmt_list END ';' %prec IFX { $$ = opr(token::IF, 2, $2, $4); }
| IF expr DO stmt_list ELSE stmt_list END ';' { $$ = opr(token::IF, 3, $2, $4, $6); }
| inittype VARIABLE '(' arg_list ')' DO stmt_list END ';' {
/*	Tabs.push(std::map<id, varType, cmpId>());
	curTab = &Tabs.top();
	$$ = opr('=', 4, $1, $2, $4, $7);
*/}
//| VARIABLE ':' stmt_list END ';' {setlabel($1, $3); $$ = $3;}
//| GOTO VARIABLE ';' { $$ = opr(GOTO, 1, id($2)); }
| RETURN expr ';'   { $$ = opr(token::RETURN, 1, $2); }
;

dim_list:
expr { $$ = $1; }
| dim_list ',' expr { $$ = opr(',', 2, $1, $3); }

inittype:
BOOLTYPE | INTTYPE ;

arg_list:
arg_list inittype VARIABLE { $$ = opr(',', 3, $1, $2, $3); }
| { $$ = NULL; }
;

stmt_list:
stmt { $$ = $1; }
| stmt_list stmt { $$ = opr(';', 2, $1, $2); }
;

give_args:
give_args ',' expr { $$ = opr(',', 2, $1, $3); }
| { $$ = NULL; }
;

expr:
INTEGER { $$ = con($1); }
| VARIABLE { $$ = m_id(gettype($1), $1); }
| VARIABLE '(' give_args ')' { $$ = NULL; }
| '-' expr %prec UMINUS { $$ = opr(token::UMINUS, 1, $2); }
| expr '+' expr { $$ = opr('+', 2, $1, $3); }
| expr '-' expr { $$ = opr('-', 2, $1, $3); }
| BOOL { $$ = con((int)$1); }
| expr '<' expr { $$ = opr('<', 2, $1, $3); }
| expr '>' expr { $$ = opr('>', 2, $1, $3); }
| expr GE expr { $$ = opr(token::GE, 2, $1, $3); }
| expr LE expr { $$ = opr(token::LE, 2, $1, $3); }
| expr NE expr { $$ = opr(token::NE, 2, $1, $3); }
| expr EQ expr { $$ = opr(token::EQ, 2, $1, $3); }
| expr OR expr { $$ = opr(token::OR, 2, $1, $3); }
| expr AND expr {$$ = opr(token::AND, 2, $1, $3); }
| NOT expr { $$ = opr(token::NOT, 1, $2); }
| '(' expr ')' { $$ = $2; }
| DISTMEAS { $$ = opr(token::DISTMEAS, 0); }
| VARIABLE CELLMEMB cellmemb {$$ = opr(token::CELLMEMB, 2, $1, $3); }
| VARIABLE '[' dim_list ']' {$$ = opr('[', 2, $1, $3); }
| SIZEOF '(' VARIABLE ')' {$$ = opr(token::SIZEOF, 1, $3); }
;

cellmemb:
'x' {$$ = (int)$1; } | 'y' {$$ = (int)$1;} | 'f' {$$ = (int)$1;} ;

%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
    conNodeType *p = new conNodeType(value);
    return (nodeType*)p;
}

typeEnum gettype(const std::string &s) {
    auto &Tab = *curTab;
	typeEnum ret;
	bool f = false;
	for(auto &i : Tab)
		if(i.first.s == s) {
			f = true;
			ret = i.first.vartype;
			break;
		}
    if(!f) throw std::runtime_error("Unknown name.");
    //if(it->first.vartype != node.vartype) yyerror("Wrong type.");
    return ret;
}

nodeType *m_id(typeEnum t, const std::string s) {
    idNodeType *p = new idNodeType(t, s);
    return p;
}

template<class... Args>
nodeType *opr(int oper, Args... args) {
	auto *p = new oprNodeType<Args...>(oper, args...);
	return p;
} 

template<class... Args>
void freeNode(oprNodeType<Args...> *p) {
    int i;
    if (!p) return;
    for (i = 0; i < p->opr.nops; i++)
        freeNode(p->opr.op[i]);
    delete p;
}

void setlabel (const id& name, nodeType *p) {
    Funcs.insert( {name, p} );
}

void init () {
	Tabs = std::stack< std::map<id, varType, cmpId> >(); 
    Funcs.clear();
}

void yy::parser::error(const std::string& s) {
    std::cout << s;
}

int main(int argc, const char** argv) {
	std::ifstream fin("./in.txt", std::ios::in);
	import_file(fin);
	fin.close();
    std::ifstream yyin("./test.txt", std::ios::in);
	MyLexer lexer(yyin, std::cerr);
    yy::parser parse(lexer);
	parse();
    yyin.close();
    return 0;
}

