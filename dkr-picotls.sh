# !/bin/bash.sh

export CXX=g++
export CC=gcc

git clone https://github.com/h2o/picotls
cd picotls
git submodule init
git submodule update
cmake .
make


