#!/bin/bash

ip addr replace 100.64.0.2 dev lo
ip addr add 192.168.12.1/30 dev eth1
ip addr add 192.168.22.1/30 dev eth2


#Creation of the bridge interface that is vlan aware and default vlan is set to 0
ip link add br0 type bridge vlan_filtering 1 vlan_default_pvid 0

#Create vxlan interface on the top of the loopback interface:
#	nolearning - because we use EVPN for this purpose
#	external - then device beacomes - SIngle VXLAN Device - multiple VNI can be proccessed
#	vnifilter - only VNI configured for this bridge could be handled
ip link add vxlan0 type vxlan dstport 4789 local 100.64.0.2 nolearning external vnifilter

#These commands disable the autoconfiguration of the IPv6
ip link set br0 addrgenmode none
ip link set vxlan0 addrgenmode none master br0

#br0 faces the local clients, vxlan0 faces the other VTEP - their MAC is conistent, becuase they respresent the same VTEP
ip link set br0 address 11:22:33:44:55:67
ip link set vxlan0 address 11:22:33:44:55:67
ip link set br0 up
ip link set vxlan0 up

#Allows creation of mapping betwwen a VNI and VLAN
bridge link set dev vxlan0 vlan_tunnel on neigh_suppress on learning off

#######################
#	TENANT A
######################
ip link add vrf1 type vrf table 1100
ip link set vrf1 up

##
# Creation how the L3VNI is processed - VLAN is arbitary for L3VNI processing only
# It never leaves the device - but it cannot collide with another VLAN
##

bridge vlan add dev br0 vid 1100 self
bridge vlan add dev vxlan0 vid 1100
bridge vni add dev vxlan0 vni 100
bridge vlan add dev vxlan0 vid 1100 tunnel_info id 100
ip link add vrf1br link br0 type vlan id 1100
ip link set vrf1br address 11:22:33:44:55:67 addrgenmode none
ip link set vrf1br master vrf1

##
#	L2VNI 110 --> VLAN 10
##

bridge vlan add dev br0 vid 10 self
bridge vlan add dev vxlan0 vid 10
bridge vni add dev vxlan0 vni 110
bridge vlan add dev vxlan0 vid 10 tunnel_info id 110

ip link add vlan10 link br0 type vlan id 10
ip link set vlan10 master vrf1
ip link set vlan10 addr aa:bb:cc:00:01:6e
ip addr add 10.0.10.2/24 dev vlan10
ip link set vlan10 up

##
#	L2VNI 120 - VLAN 20
##
bridge vlan add dev br0 vid 11 self
bridge vlan add dev vxlan0 vid 11
bridge vni add dev vxlan0 vni 111
bridge vlan add dev vxlan0 vid 11 tunnel_info id 111

ip link add vlan11 link br0 type vlan id 11
ip link set vlan11 master vrf1
ip link set vlan11 addr aa:bb:cc:00:01:6f
ip addr add 10.0.11.2/24 dev vlan11
ip link set vlan11 up


#######################
#       TENANT B
######################
ip link add vrf2 type vrf table 1200
ip link set vrf2 up

##
# Creation how the L3VNI is processed - VLAN is arbitary for L3VNI processing only
# It never leaves the device - but it cannot collide with another VLAN
##

bridge vlan add dev br0 vid 1200 self
bridge vlan add dev vxlan0 vid 1200
bridge vni add dev vxlan0 vni 200
bridge vlan add dev vxlan0 vid 1200 tunnel_info id 200
ip link add vrf1br link br0 type vlan id 1200
ip link set vrf2br address 11:22:33:44:55:67 addrgenmode none
ip link set vrf2br master vrf2

##
#       L2VNI 120 --> VLAN 20
##

bridge vlan add dev br0 vid 20 self
bridge vlan add dev vxlan0 vid 20
bridge vni add dev vxlan0 vni 120
bridge vlan add dev vxlan0 vid 20 tunnel_info id 120

ip link add vlan20 link br0 type vlan id 20
ip link set vlan20 master vrf2
ip link set vlan20 addr aa:bb:cc:00:01:78
ip addr add 10.0.20.2/24 dev vlan20
ip link set vlan20 up

##
#       L2VNI 121 - VLAN 21
##
bridge vlan add dev br0 vid 21 self
bridge vlan add dev vxlan0 vid 21
bridge vni add dev vxlan0 vni 121
bridge vlan add dev vxlan0 vid 21 tunnel_info id 121

ip link add vlan21 link br0 type vlan id 21
ip link set vlan21 master vrf2
ip link set vlan21 addr aa:bb:cc:00:01:79
ip addr add 10.0.21.2/24 dev vlan21
ip link set vlan21 up

##
# 	Server facing interace
##

ip link set eth10 master br0

bridge vlan add dev eth10 vid 10
bridge vlan add dev eth10 vid 11
bridge vlan add dev eth10 vid 20
bridge vlan add dev eth10 vid 21

