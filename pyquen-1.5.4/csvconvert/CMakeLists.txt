set(MODULE_NAME csvconvert)
set(NAME_EXE ${PROJECT_NAME}_${MODULE_NAME})

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
file(GLOB SOURCES_EXE ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx)
message(STATUS "SOURCES: ${SOURCES_EXE}")
string(REPLACE ".cxx" ".hh" HEADERS_EXE "${SOURCES_EXE}")
add_executable(${NAME_EXE} ${SOURCES_EXE})
set_property(TARGET ${NAME_EXE} PROPERTY CXX_STANDARD 11)
#target_include_directories(${NAME_EXE} PUBLIC ${FASTJET_DIR}/include)
target_link_libraries(${NAME_EXE} PUBLIC "")
install(TARGETS ${NAME_EXE} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(FILES ${NAME_EXE}.py 
		PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_WRITE GROUP_READ
		DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

