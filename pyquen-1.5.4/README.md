# building


`./build.sh [--clean] [--debug] [--prefix=<installation>]`

- --debug is for debug build
- --clean some cleanup
- default installation is <where_cloned>/pyquen-1.5.4/pyquen

--- ORIGNIAL README BELOW - you can ignore it when using the ./build.sh ... ---

	---------------------------------------------------------------------------
	To install PYQUEN the FORTRAN compiler and cmake version >= 3.5 is required
	---------------------------------------------------------------------------
	
	After unpacking .tar archive in native folder one can build it with/without
	binary test file. Shared LIBRARY will be created in lib/ folder. 


	---------------------------------------------------------------------------
	1) Installation on LINUX:
	---------------------------------------------------------------------------
	To use default mode (with binary test file) please use shell command:

		./runconfigure
 
	for CERN's lxplus, in case of usage existing PYTHIA6 and LHAPDF library,
	the LCG should be initialized like:
	
	source /cvmfs/sft.cern.ch/lcg/views/LCG_95/x86_64-slc6-gcc8-opt/setup.(c)sh

	The result would be placed to folder ../PYQUEN:
		lib/ 		- library folder
		PyInput		- input parameters text file for tests
		pyquen_test	- test binary file

	To build PYQUEN library without binary test file please just do

		./configure --lib

	To list all available options do:

		./configure --help

	NOTE!!! Some of the modern compiler using the new linker which has a 
	different behaviour under many respect, and in particular it doesn't
	initialize correctly the common block coming from pydata because of how
	the dependency chain is structured. In this case the following message
	will be showed:

		Fatal error: BLOCK DATA PYDATA has not been loaded!
 		The program execution is stopped now!

	In this case, please use PYTHIA from source (--build-pythia option):

		./configure --build-pythia --build-test

	for PYQUEN library with binary. And for PYQUEN library only:

		./configure --build-pythia


	---------------------------------------------------------------------------
	2) Installation on other platforms: 
	---------------------------------------------------------------------------

	To install on other platforms please use cmake-gui with CMakeLists.txt
