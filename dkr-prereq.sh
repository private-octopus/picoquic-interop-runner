# !/bin/bash.sh
export DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo?america/New_York /etc/localtime
apt-get install -y tzdata
dkpg-reconfigure
apt-get -y update
apt-get -y -q install build-essential
apt-get -y -q install git
apt-get -y -q install cmake
apt-get -y -q install libssl-dev
apt-get -y -q install pkg-config



