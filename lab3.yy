%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor
%code requires {

#include <stack>
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include "lab3.hh"

using namespace lab3;

typedef std::variant<bool*, int*, cell*, array<>* > varType;
//...
//void AddToVarStor(std::string*, int);
//getfromvarstor

nodeType *opr(int oper, int nops, ...);
nodeType *m_id(id);
nodeType *con(int value);
varEnum gettype(id);
void setlabel (int i ,nodeType *p);
void freeNode(nodeType *p);
int exec(nodeType *p);
int yylex(void);
void init (void);
void yyerror(const std::string);
std::stack< std::map<id, varType> > Tabs;
std::map<id, varType> *curTab;
std::map<id, nodeType*> Funcs;

}

%token <bool> BOOL;
%token <int> INTEGER DISTMEAS;
%token <id> VARIABLE;
%token <varEnum> BOOLTYPE INTTYPE CELLTYPE ARRTYPE;
%token FOR IF PRINT GOTO DO END RETURN VOID GETPOS;
%nonassoc IFX;
%nonassoc ELSE;
%left TYPECOMPAR;
%left MOVOPER;
%left OR;
%left AND;
%left GE LE EQ NE '>' '<';
%left '+' '-';
%nonassoc UMINUS NOT;
%nonassoc CELLMEMB;
%nonassoc INITVAR;
%type <nodeType*> stmt expr stmt_list function arg_list give_args;
%type <varEnum> inittype;

%%

program:
function {exec($1); freeNode($1); exit(0); }
;

function:
function stmt { $$ = opr(';', 2, $1, $2);/*ex($2); freeNode($2);*/ }
| function YYerror {}
| /* NULL */ {
	Tabs.push(std::map<id, varType>());
	curTab = &Tabs.top();
	init(); $$ = 0;
}
;

stmt:
';' { $$ = opr(';', 2, NULL, NULL); }
| expr ';' { $$ = $1; }
| PRINT expr ';' { $$ = opr(PRINT, 1, $2); }
| VARIABLE '=' expr ';' { $$ = opr('=', 2, m_id(gettype($1), $1), $3); }
| inittype VARIABLE ';' { $$ = m_id($1, $2); }
| inittype VARIABLE '=' expr ';' %prec INITVAR { $$ = opr('=', 3, m_id($1, $2), $4); }
| FOR VARIABLE '=' expr ':' expr DO stmt_list END ';' { $$ = opr(FOR, 4, $2, $4, $6, $8); }
| IF expr DO stmt_list END ';' %prec IFX { $$ = opr(IF, 2, $2, $4); }
| IF expr DO stmt_list ELSE stmt_list END ';' { $$ = opr(IF, 3, $2, $4, $6); }
| inittype VARIABLE '(' arg_list ')' DO stmt_list END ';' {
	Tabs.push(std::map<id, varType>());
	curTab = &Tabs.top();
	$$ = opr('=', 4, $1, $2, $4, $7);
}
//| VARIABLE ':' stmt_list END ';' {setlabel($1, $3); $$ = $3;}
//| GOTO VARIABLE ';' { $$ = opr(GOTO, 1, id($2)); }
| RETURN expr ';'   { $$ = opr(RETURN, 1, $2); }
;

inittype:
BOOLTYPE | INTTYPE | CELLTYPE | ARRTYPE ;

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
| '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
| expr '+' expr { $$ = opr('+', 2, $1, $3); }
| expr '-' expr { $$ = opr('-', 2, $1, $3); }
| BOOL { $$ = con($1); }
| expr '<' expr { $$ = opr('<', 2, $1, $3); }
| expr '>' expr { $$ = opr('>', 2, $1, $3); }
| expr GE expr { $$ = opr(GE, 2, $1, $3); }
| expr LE expr { $$ = opr(LE, 2, $1, $3); }
| expr NE expr { $$ = opr(NE, 2, $1, $3); }
| expr EQ expr { $$ = opr(EQ, 2, $1, $3); }
| expr OR expr { $$ = opr(OR, 2, $1, $3); }
| expr AND expr {$$ = opr(AND, 2, $1, $3); }
| NOT expr { $$ = opr(NOT, 1, $2); }
| '(' expr ')' { $$ = $2; }
;

%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
    conNodeType *p = new conNodeType(value);
    return (nodeType*)p;
}

varEnum gettype(idNodeType node) {
    auto it = curTab.find(node.s);
    if(it == curTab.end()) yyerror("Unknown name.");
    if(it->first.vartype != node.vartype) yyerror("Wrong type.");
    return it->first.vartype;
}

nodeType *m_id(varEnum t, const std::string s) {
    idNodeType *p = new idNodeType(t, s);
    return p;
}

template<class... Args>
nodeType *opr(int oper, Args... args) {
	auto *p = new oprNodeType<Args...>(oper, args...);
	return p;
} 

void freeNode(nodeType *p) {
    int i;
    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    delete p;
}

void setlabel (std::string s, nodeType *p) {
    Names.insert(std::pair<std::string, nodeType*>(s, p));
}

void init () {
    Names.clear();
}

void yyerror(const std::string s) {
    std::cout << s;
}

int main(void) {
    std::ifstream yyin("./test.txt", std::ios::in);
    yyparse();
    fclose (yyin);
    return 0;
}
                      
