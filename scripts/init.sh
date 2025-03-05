#!/bin/bash

docker network create -d macvlan \
    -o parent=vlan10 vlan10_net

docker network create -d macvlan \
    -o parent=vlan20 vlan20_net

docker network create -d macvlan \
    -o parent=vlan30 vlan30_net
