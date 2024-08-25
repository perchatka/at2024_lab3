#include "in.hh"
#include "lab3.hh"
#include <fstream>

using namespace lab3;

Grid import_file(std::ifstream &fin) {
	Grid g;
	fin>>g.n>>g.m;
	int exs, xs, ys, num, loc;
	fin>>exs;
	for(int i = 0; i < exs; ++i) {
		fin>>xs>>ys;
		cell newnode;
		newnode.x = xs; newnode.y = ys; newnode.isfree = true;
		g.exs.push_front(newnode);
	}

	g.cells = std::vector<std::vector<bool> >(g.n);
	for(int i = 0; i < g.n; ++i) {
		g.cells[i] = std::vector<bool>(g.m, true);
		
		fin>>num;
		for(int j = 0; j < num; ++j) {
			fin>>loc;
			g.cells[i][j] = false;
		}
	}

	fin>>xs>>ys;
	if( !g.cells[xs][ys] ) throw std::runtime_error("Invalid robot location.");
	g.robot = point(xs, ys);
	return g;
}
