#! /usr/bin/env bash

build_type=Release

mkdir -p _build && cd _build
NETCDF_DIR=$CONDA_PREFIX cmake \
    -DCMAKE_BUILD_TYPE=$build_type \
    -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
    -Dcoretran_DIR=$CONDA_PREFIX/lib/cmake \
    -DBUILD_SHARED_LIBS=ON \
    ../src
make -s
if [ $? != 0 ]; then
    exit 1
else
    make install
fi
exit 0
