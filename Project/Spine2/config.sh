#!/bin/bash

ip addr add 192.168.21.2/30 dev eth1
ip addr add 192.168.22.2/30 dev eth2

ip addr replace 10.0.2.2/32 dev lo
