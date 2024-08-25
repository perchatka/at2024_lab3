#include "nodeop.hh"
#include <queue>

using namespace lab3;

int& get_memb(const cellNodeType& c, int memb) {
	switch(memb) {
	case 'x': return c.x;
	case 'y': return c.y;
	case 'f': return (int)c.isfree;
	}
}
