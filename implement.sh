#!/usr/bin/bash
NS1="NS1"
NS2="NS2"
NODE_IP="10.0.20.55"
BRIDGE_SUBNET="172.16.0.0/24"
BRIDGE_IP="172.16.0.1"
IP1="172.16.0.2"
IP2="172.16.0.3"
TO_NODE_IP="10.0.20.146"
TO_BRIDGE_SUBNET="172.16.1.0/24"
TO_BRIDGE_IP="172.16.1.1"
TO_IP1="172.16.1.2"
TO_IP2="172.16.1.3"

sudo ip netns add $NS1
sudo ip netns add $NS2
    ip netns show

sudo ip link add veth10 type veth peer name veth11
sudo ip link add veth20 type veth peer name veth21
    ip link show type veth 

sudo ip link set veth11 netns $NS1
sudo ip link set veth21 netns $NS2

sudo ip netns exec $NS1 ip addr add $IP1/24 dev veth11
sudo ip netns exec $NS2 ip addr add $IP2/24 dev veth21


sudo ip netns exec $NS1 ip link set dev veth11 up
sudo ip netns exec $NS2 ip link set dev veth21 up

echo "Creating the bridge"
sudo ip link add br0 type bridge
    ip link show bridge
        ip link show br0

echo " Adding network namespaces interfaces to the bridge"
sudo ip link set dev veth10 master br0
sudo ip link set dev veth20 master br0

echo "Assigning the IP address to the bridge"
sudo ip addr add $BRIDGE_IP/24 dec br0

echo "Enabling the bridge"
sudo ip link set dev br0 up


echo " Enabling the interfaces connected to the bridge"
sudo ip link set dev veth10 up
sudo ip link set dev veth20 up

echo " Setting the loopback interfaces in the network namespaces"
sudo ip netns exec $NS1 ip link set lo up 
sudo ip netns exec $NS2 ip link set lo up 
    sudo ip netns exec $NS1 ip a
    sudo ip netns exec $NS2 ip a

echo "Setting the default routine in the network namespace"
sudo ip netns exec $NS1 ip route add default via $BRIDGE_IP dev veth11
sudo ip netns exec $NS2 ip route add default via $BRIDGE_IP dev veth21

# ----------------- set 3 specific setup  ------------------------- #

echo "Setting the route on the node to reach the network namespaces"
sudo ip route add $TO_BRIDGE_SUBNET via $TO_NODE_IP dev eth0

echo "Enables IP forwarding on the node"
sudo sysctl -w net.ipv4.ip_forward=1













