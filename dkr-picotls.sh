# !/bin/bash.sh

apt-get update
apt-get -y install git

export CXX=g++
export CC=gcc

git clone https://github.com/h2o/picotls
cd picotls
git submodule init
git submodule update
cmake .
make


