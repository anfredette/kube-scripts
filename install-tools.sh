#!/bin/bash
# Display iptables NAT rules and routes for multiple active gateway POC


NODE_NAMES=("cluster1-worker" "cluster1-worker2" "cluster1-control-plane" "cluster2-worker" "cluster2-worker2" "cluster2-control-plane")

for node in "${NODE_NAMES[@]}"
do
  docker exec -it $node apt-get update
  docker exec -it $node apt-get install -y tcpdump
done
