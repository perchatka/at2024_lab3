#ifndef LAB3_H
#define LAB3_H

#include <iostream>
#include <variant>
#include <list>
#include <vector>

namespace lab3 {

class MyLexer;
class cell;
class array;

typedef std::variant<bool*, int*, cell*, array* > varType;

//typedef enum { tBool, tInt, tCell, tArr } varEnum;
//typedef enum { typeCon, typeCell, typeArr, typeId, typeOpr } nodeEnum;
typedef enum { typeBool, typeCon, typeId, typeCell, typeArr, typeOpr } typeEnum;
typedef enum { dirUp, dirRight, dirDown, dirLeft } dirOpr;

class nodeType {
public:
	int label;
	virtual typeEnum getType() = 0;
};

struct point {
	int x;
	int y;
	point(int nx = 0, int ny = 0) : x(nx), y(ny) {}
};

struct cell : public point {
	bool isfree;
	cell(int nx = 0, int ny = 0, bool nf = true) : point(nx, ny), isfree(nf) {}
};

class cellNodeType : public nodeType, public cell {
	typeEnum getType() override { return typeCell; }
	cell ex();
};

class conNodeType : public nodeType {
public:
	int value;

	conNodeType(int setVal = 0) : value(setVal) {}
	typeEnum getType() override { return typeCon; }
	int ex();
};

class id {
public:
	typeEnum vartype;
	std::string s;
	id(typeEnum nv, const std::string& ns) : vartype(nv), s(ns) {}
};

class idNodeType : public nodeType, public id {
public:	
	typeEnum getType() override { return typeId; }
	idNodeType(typeEnum nv, const std::string& ns) : id(nv, ns) {}
	id ex();
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
	oprNodeType(int setOper, int setNops, Args... args) :
			oper(setOper), nops(setNops) {
		op = new nodeType*[nops];
		for(int i = 0; i < nops; ++i) setOneNode(i, (nodeType*)args...) ;
	}
	typeEnum getType() override { return typeOpr; }
	~oprNodeType() {
		for(int i = 0; i < nops; ++i) {
			delete op[i];
		}
		delete [] op;
	}
	template<class T>
	T ex();
	
};

class array {	
public:
	int lvl;
	int n;
	std::vector<varType> valvect;
	std::vector<array> arrvect;
	template<class... Args>
	array(int sn, Args... args) : n(sn) {
		lvl = sizeof...(Args) - 1;
		if(lvl == 0) valvect = std::vector<varType>(sn);
		else {
			arrvect = std::vector<array>(sn);
			for(int i = 0; i < sn; ++i) arrvect[i] = array(args...);
		}
	}
	array(const array& sarr) :
			lvl(sarr.lvl), n(sarr.n), valvect(sarr.valvect), arrvect(sarr.arrvect) {}

	varType& operator[](int i) {
		if( lvl == 0) return valvect[i];
		return arrvect[i];
	}
};

class arrNodeType : public nodeType, public array {
	arrNodeType(const array& sarr) : array(sarr) {}
	typeEnum getType() override { return typeArr; }
	array ex() {
		return *this;
	}
};

struct Grid {
    int m = 0;
    int n = 0;
	std::list<point> exs;
	point robot;
	std::vector<std::vector<bool> > cells;
};

/*void yyerror(const char* s) {
	std::cout<< s << '\n';
}

void yyerror(const char* s, char c) {
	std::cout<< s << c <<'\n';
}
*/

struct cmpId {
	bool operator()(const id &a, const id &b) const {
		return a.s.compare(b.s);
	}
};

}

#endif
