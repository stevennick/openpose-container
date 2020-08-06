#!/bin/bash

### INSTALL PREREQUISITES

# Basic
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes update

# General runtime dependencies
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install libgflags2.2 libprotobuf10 libgoogle-glog0v5 libboost-system1.65.1 libboost-thread1.65.1 libboost-filesystem1.65.1 libhdf5-100 libatlas3-base 

# General python3 dependencies
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install python3-pip python3-opencv python3-numpy python3-protobuf

rm -rf /var/lib/apt/lists/*
