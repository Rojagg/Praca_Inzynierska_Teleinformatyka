#!/bin/bash

ip addr add 192.168.11.2/30 dev eth1
ip addr add 192.168.12.2/30 dev eth2

ip addr replace 10.0.2.1/32 dev lo
