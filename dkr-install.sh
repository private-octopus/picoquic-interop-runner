# !/bin/bash.sh

export CXX=g++
export CC=gcc

cd ..
git clone https://github.com/private-octopus/picoquic
cd picoquic
cmake .
make
cd ..

