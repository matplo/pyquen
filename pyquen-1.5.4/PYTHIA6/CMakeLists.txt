#
# This is PYTHIA 6.4.28 library
#
# build version 1
#----------------------------------------------------------------------------
# Setup the project

cmake_minimum_required(VERSION 3.5 FATAL_ERROR)	 
project(PYTHIA6 VERSION 6.4.28 LANGUAGES Fortran)
			
#---Compilation and Link options---------------------------------------------
message (STATUS " * PYTHIA * USING Pythia from source: ${PROJECT_NAME} ver. ${PROJECT_VERSION} ")

file(GLOB sources_PYTHIA ${PROJECT_SOURCE_DIR}/src/*.f)
add_library(${PROJECT_NAME} STATIC ${sources_PYTHIA})

# install(TARGETS ${PROJECT_NAME} DESTINATION ${PROJECT_SOURCE_DIR}/lib)
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

