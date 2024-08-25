#include "lab3.hh"
#include "lab3.tab.hh"

using namespace lab3;

char lbl = 0;

int nodeType::ex() {
	return 0;
}

int conNodeType::ex() {
	return value;
}

id idNodeType::ex() {
	return id(vartype, s); 
}

cell cellNodeType::ex() {
	return cell(x, y, isfree);
}


