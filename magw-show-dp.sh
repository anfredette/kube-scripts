#!/bin/bash
# Display iptables NAT rules and routes for multiple active gateway POC


C1_GW1_NAME='cluster1-worker'
C1_GW2_NAME='cluster1-worker2'
C2_GW1_NAME='cluster2-worker'
C2_GW2_NAME='cluster2-worker2'

echo ""
echo "Cluster1 Gateway1 NAT Rules"
docker exec -it $C1_GW1_NAME iptables -t nat -n -L SM-GN-EGRESS-CLUSTER
echo ""
echo "Cluster1 Gateway2 NAT Rules"
docker exec -it $C1_GW2_NAME iptables -t nat -n -L SM-GN-EGRESS-CLUSTER

echo ""
echo "Cluster2 Gateway1 NAT Rules"
docker exec -it $C2_GW1_NAME iptables -t nat -n -L SM-GN-EGRESS-CLUSTER
echo ""
echo "Cluster2 Gateway2 NAT Rules"
docker exec -it $C2_GW2_NAME iptables -t nat -n -L SM-GN-EGRESS-CLUSTER

echo ""

echo ""
echo "Cluster 1 Gateway 1 vxlan-tunnel routes"
docker exec -it $C1_GW1_NAME ip -c route show table 100
echo ""
echo "Cluster 1 Gateway 1 vxlan-tunnel routes"
docker exec -it $C1_GW2_NAME ip -c route show table 100

echo ""
echo "Cluster 1 Gateway 1 vxlan-tunnel routes"
docker exec -it $C2_GW1_NAME ip -c route show table 100
echo ""
echo "Cluster 1 Gateway 1 vxlan-tunnel routes"
docker exec -it $C2_GW2_NAME ip -c route show table 100
