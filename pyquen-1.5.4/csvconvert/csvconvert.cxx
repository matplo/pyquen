#ifndef __PYQUEN_CSVCONVERT__EXE
#define __PYQUEN_CSVCONVERT__EXE

#include <strutil.hh>
#include <iostream>
using namespace std;

int main(int argc, char const *argv[])
{
	StrUtil::Args args(argc, argv);
	if (args.getBool("-h"))
	{
		cout << "[i] faster convert from pyquen stdout to csv..." << endl;
		cout << "    code not yet C++ developed" << endl;
	}
	return 0;
}

#endif // __PYQUEN_CSVCONVERT__EXE
