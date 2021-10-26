#!/usr/bin/bash

function get_opt()
{
    all_opts="$@"
    # echo "options in function: ${all_opts}"
    opt=${1}
    # echo "checking for [${opt}]"
    #opts=("${all_opts[@]:2}")
    opts=$(echo ${all_opts} | cut -d ' ' -f 2-)
    retval=""
    is_set=""
    # echo ".. in [${opts}]"
    for i in ${opts}
    do
    case $i in
        --${opt}=*)
        retval="${i#*=}"
        shift # past argument=value
        ;;
        --${opt})
        is_set=yes
        shift # past argument with no value
        ;;
        *)
            # unknown option
        ;;
    esac
    done
    if [ -z ${retval} ]; then
        echo ${is_set}
    else
        echo ${retval}
    fi
}
export -f get_opt

function thisdir()
{
        SOURCE="${BASH_SOURCE[0]}"
        while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
          DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
          SOURCE="$(readlink "$SOURCE")"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
        done
        DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
        echo ${DIR}
}
THISD=$(thisdir)

echo "[i] using ${THISD} as source directory"

verbose=$(get_opt "verbose" $@)
if [ ! -z ${verbose} ]; then
    export VERBOSE=1
else
    unset VERBOSE
fi

INSTALL_DIR=$(get_opt "prefix" $@)
if [ -z ${INSTALL_DIR} ]; then
	INSTALL_DIR=$PWD/pyquen
fi

echo "[i] installation directory: ${INSTALL_DIR}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then

	rm -rfv ${THISD}/build

	for fn in install_manifest.txt Makefile CMakeFiles CMakeCache.txt cmake_install.cmake pyquen_test pyquen_csvconvert lib
	do
		rm -rfv ${THISD}/${fn}
		rm -rfv ${THISD}/csvconvert/${fn}
	done

	for fn in CMakeFiles cmake_install.cmake lib libPYTHIA6.a  Makefile
	do
		rm -rfv ${THISD}/PYTHIA6/${fn}
	done

	rm -v ${INSTALL_DIR}/bin/*
	rm -v ${INSTALL_DIR}/lib/*

	ofiles=$(find ${INSTALL_DIR} -name "*.o")
	for fn in ${ofiles}
	do
		rm -v ${fn}
	done

	sofiles=$(find ${INSTALL_DIR} -name "*.so")
	for fn in ${sofiles}
	do
		rm -v ${fn}
	done

	exit 0
fi

build_configuration="Release"
debug=$(get_opt "debug" $@)
if [ ! -z ${debug} ]; then
    build_configuration="Debug"
fi

savedir=$PWD
mkdir ${THISD}/build
cd ${THISD}/build
cmake ${THISD} -DCMAKE_BUILD_TYPE=${build_configuration} -DPyTest=ON -DPythiaFromSource=ON -Dcsvconvert=ON -Dcustom=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
&& cmake --build . --target all -- -j && cmake --build . --target install
cd $savedir