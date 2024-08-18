#ifndef LAB3_H
#define LAB3_H

#include <variant>

namespace lab3 {

class cell;
template<class... Args> class array;

typedef std::variant<bool, int, cell, array<> > varType;

typedef enum { tBool, tInt, tCell, tArr } varEnum;
typedef enum { typeCon, typeCell, typeArr, typeId, typeOpr } nodeEnum;
typedef enum { dirUp, dirRight, dirDown, dirLeft } dirOpr;

class nodeType {
public:
	int label;
	virtual nodeEnum getType() = 0;
};

class cell {
public:
	int x;
	int y;
	bool isfree;

	cell(int nx = 0, int ny = 0, bool nf = true) :
		x(nx), y(ny), isfree(nf) {}
};

class cellNodeType : public nodeType, public cell {
	nodeEnum getType() override { return typeCell; }
};

class conNodeType : public nodeType {
public:
	int value;

	conNodeType(int setVal = 0) : value(setVal) {}
	nodeEnum getType() override { return typeCon; }
};

class id {
public:
	varEnum vartype = tBool;
	std::string s;
	id(std::string setId = "") : s(setId) {}
};

class idNodeType : public nodeType, public id {
public:	
	nodeEnum getType() override { return typeId; }
};

template<class... Args>
class oprNodeType : public nodeType {
public:
	int oper;
	int nops;
	nodeType **op;
	
	void setOneNode(int i, nodeType* p) {
		op[i] = p;
	}
	oprNodeType(int setOper, int setNops, Args... args) : oper(setOper), nops(setNops) {
		op = new nodeType*[nops];
		for(int i = 0; i < nops; ++i) setOneNode(i, (nodeType*)args...) ;
	}
	nodeEnum getType() override { return typeOpr; }
	~oprNodeType() {
		for(int i = 0; i < nops; ++i) {
			delete op[i];
		}
		delete [] op;
	}
};

template<class... Args>
class array {
public:
	int lvl;
	int n;
	std::variant<varType*, array*> cont = nullptr;
	explicit array(int sn, Args... args) : n(sn) {
		lvl = sizeof...(Args) - 1;
		if(lvl == 1) cont = new varType[sn];
		else {
			cont = new array[sn];
			for(int i = 0; i < sn; ++i) cont[i] = array(args...);
		}
	} 
	~array() {
		for(int i = 0; i < n; ++i) delete cont[i];
		delete [] cont;
	}
};

template<class... Args>
class arrNodeType : public nodeType, public array<Args...> {
	nodeEnum getType() override { return typeArr; }
};

struct Grid {
    int m;
    int n;
};

void yyerror(const char* s) {
	std::cout<< s << '\n';
}

void yyerror(const char* s, char c) {
	std::cout<< s << c <<'\n';
}

extern int sym[26];
extern nodeType* addr[26];

}

#endif
