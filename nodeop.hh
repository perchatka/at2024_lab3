#ifndef NODEOP_HH
#define NODEOP_HH

#include <queue>

namespace lab3 {

template<class... Args>
varType& get_el(const arrNodeType& arr, Args... args) {
	if(arr.n != sizeof...(args)) throw std::runtime_error("Unaccessible element.");
	std::queue<int> q;
	int ind = 0;
	q.push(args...);
	arrNodeType &cur = arrNodeType;
	for(int i = 1; i < arr.n; ++i) {
		int ind = q.front(); q.pop();
		cur = cur[ind];
	}
	ind = q.front();
	return cur[ind];
}

int& get_memb(const cellNodeType&, int);

}

#endif
