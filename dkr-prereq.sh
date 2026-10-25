#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
apt-get -y update
apt-get -y -q install tzdata build-essential git cmake libssl-dev pkg-config
dpkg-reconfigure -f noninteractive tzdata
