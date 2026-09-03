#!/bin/bash

ip link add link eth1 name eth1.10 type vlan id 10
ip add add 10.0.10.52/24 dev eth1.10
ip link set eth1.10 up

ip link add link eth1 name eth1.11 type vlan id 11
ip add add 10.0.11.52/24 dev eth1.11
ip link set eth1.11 up

ip link add link eth1 name eth1.20 type vlan id 20
ip add add 10.0.20.52/24 dev eth1.20
ip link set eth1.20 up

ip link add link eth1 name eth1.21 type vlan id 21
ip add add 10.0.21.52/24 dev eth1.21
ip link set eth1.21 up
