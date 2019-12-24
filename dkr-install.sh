# !/bin/bash.sh

apt-get -y -q install build-essential
apt-get -y -q install git
apt-get -y -q install cmake
apt-get -y -q install libssl-dev
apt-get -y -q install pkg-config

export CXX=g++
export CC=gcc

git clone https://github.com/h2o/picotls
cd picotls
git submodule init
git submodule update
cmake .
make
cd ..
git clone https://github.com/private-octopus/picoquic
cd picoquic
cmake .
make
cd ..

