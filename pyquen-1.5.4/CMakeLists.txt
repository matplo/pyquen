# 
# This is PYQUEN 1.5.4 library
#
# build version 11
#----------------------------------------------------------------------------
# Setup the project

cmake_minimum_required(VERSION 3.5 FATAL_ERROR)	
project(pyquen VERSION 1.5.4 LANGUAGES Fortran CXX) 

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/../PYQUEN" CACHE PATH "Path to default install dir" FORCE)
endif()

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")
#----------------------------------------------------------------------------
# Project options and settings
SET(PYTHIA6_LIBRARIES "NOTFOUND")
SET(LHAPDF_LIBRARIES "NOTFOUND")
option(PyTest "Do build PYQUEN test?" OFF)
option(PythiaFromSource "Use PYTHIA from tarball" OFF)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules_cmake_standalone)

#---Compilation and Link options---------------------------------------------
include(CheckFortranCompilerFlag)

if(CMAKE_SYSTEM_NAME MATCHES Darwin) #apple OS
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif(CMAKE_SYSTEM_NAME MATCHES Darwin)

# fortran flags needed for some tests and examples
# FFLAGS depend on the compiler
get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)
if ("${CMAKE_Fortran_FLAGS}" STREQUAL "" )
if ((Fortran_COMPILER_NAME MATCHES "gfortran.*") OR (Fortran_COMPILER_NAME MATCHES "f95.*"))
   set(CMAKE_Fortran_FLAGS            "-ffixed-form -ffixed-line-length-none -fPIC")
elseif (Fortran_COMPILER_NAME MATCHES "ifort.*")
   set(CMAKE_Fortran_FLAGS            "-fno-automatic -fno-backslash -extend-source 132")	
endif()
message(STATUS "Fortran compiler : ${Fortran_COMPILER_NAME}")
elseif()
endif()

SET(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS} -Wall")

# setting linker flags
IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin") 
  SET(CMAKE_EXE_LINKER_FLAGS "-Wl,-dead_strip_dylibs")
  SET(CMAKE_SHARED_LINKER_FLAGS "-Wl,-dead_strip_dylibs") 
  SET(STATIC_LIBRARY_FLAGS "-Wl,-dead_strip_dylibs")
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--as-needed")
  SET(CMAKE_SHARED_LINKER_FLAGS "-Wl,--as-needed -shared")
  SET(STATIC_LIBRARY_FLAGS "-Wl,--as-needed")	
ENDIF()

#----------------------------------------------------------------------------

message(STATUS "PYQUEN: Fortran FLAGS ${CMAKE_Fortran_FLAGS}")
message(STATUS "PYQUEN: Lib linker FLAGS ${CMAKE_SHARED_LINKER_FLAGS}")

#----------------------------------------------------------------------------
# Find PYTHIA, LHAPDF
#

find_package(PYTHIA6)
find_package(LHAPDF)

if((PYTHIA6_LIBRARIES MATCHES "NOTFOUND") OR (PythiaFromSource))
  if(PythiaFromSource OR (EXISTS ${PROJECT_SOURCE_DIR}/${Pythia6_DIR}) )
    add_subdirectory(PYTHIA6) # Using PYTHIA from source
    set(PYTHIA6_LIBRARIES PYTHIA6)
  else()
    message(FATAL_ERROR " * !!!ERROR!!! * PYTHIA library not found, please use -DPythiaFromSource option")
  endif()
endif()
#-----------------------------------------------------------------------------
# Lib and bin 

file(GLOB sources_PYQUEN ${PROJECT_SOURCE_DIR}/src/*.f)

add_library(${PROJECT_NAME} SHARED ${sources_PYQUEN})

if(LHAPDF_LIBRARIES MATCHES "NOTFOUND")
  target_link_libraries(${PROJECT_NAME} ${PYTHIA6_LIBRARIES})
  message (STATUS "LIB: Pythia= ${PYTHIA6_LIBRARIES}")
else()
  target_link_libraries(${PROJECT_NAME} ${PYTHIA6_LIBRARIES} ${LHAPDF_LIBRARIES})
  message (STATUS "LIB: Pythia= ${PYTHIA6_LIBRARIES} LHAPDF= ${LHAPDF_LIBRARIES}")
endif()

message (STATUS "Build test: ${PyTest}")
if(PyTest)
  # not sure what's that
  # install(FILES ${PROJECT_SOURCE_DIR}/test/tunes/${TUNE} DESTINATION ${CMAKE_INSTALL_PREFIX})
  add_executable(${PROJECT_NAME}_test ${PROJECT_SOURCE_DIR}/test/test_pyquen.f) 
  target_link_libraries(${PROJECT_NAME}_test ${PROJECT_NAME})
  install(TARGETS ${PROJECT_NAME}_test DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
endif()

option(custom "Do build custom test?" OFF)
message (STATUS "Build custom: ${custom}")
if(custom)
  # not sure what's that
  # install(FILES ${PROJECT_SOURCE_DIR}/test/tunes/${TUNE} DESTINATION ${CMAKE_INSTALL_PREFIX})
  add_executable(${PROJECT_NAME}_custom ${PROJECT_SOURCE_DIR}/custom/custom_pyquen.f) 
  target_link_libraries(${PROJECT_NAME}_custom ${PROJECT_NAME})
  install(TARGETS ${PROJECT_NAME}_custom DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
endif()

option(csvconvert "Do build csvconvert?" OFF)
if (csvconvert)
  add_subdirectory(csvconvert)
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
# install(TARGETS ${PROJECT_NAME} DESTINATION ${PROJECT_SOURCE_DIR}/lib)
